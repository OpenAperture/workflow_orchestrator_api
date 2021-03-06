require Logger

defmodule OpenAperture.WorkflowOrchestratorApi.Workflow do

  @moduledoc """
  Methods and Workflow struct that will be received from (and should be sent to) the WorkflowOrchestrator
  """

  alias OpenAperture.WorkflowOrchestratorApi.Notifications.Publisher, as: NotificationsPublisher
  alias OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.Publisher, as: WorkflowOrchestratorPublisher
  alias OpenAperture.WorkflowOrchestratorApi.Request

  alias OpenAperture.ManagerApi
  alias OpenAperture.ManagerApi.Workflow, as: WorkflowAPI
  alias OpenAperture.ManagerApi.Response

  alias OpenAperture.Timex.Extensions, as: TimexExtensions

  defstruct id:                       nil,
            workflow_id:              nil,
            deployment_repo:          nil,
            deployment_repo_git_ref:  nil,
            source_repo:              nil,
            source_repo_git_ref:      nil,
            source_commit_hash:       nil,
            milestones:               nil,
            current_step:             nil,
            elapsed_step_time:        nil,
            elapsed_workflow_time:    nil,
            workflow_duration:        nil,
            workflow_step_durations:  nil,
            workflow_error:           nil,
            workflow_completed:       nil,
            workflow_start_time:      nil,
            step_time:                nil,
            event_log:                nil,
            scheduled_start_time:     nil,
            execute_options:          nil

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Workflow struct

  ## Options

  The `payload` option defines the Map containing the Workflow

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Workflow
  """
  @spec from_payload(map) :: OpenAperture.WorkflowOrchestratorApi.Workflow
  def from_payload(payload) do
    %OpenAperture.WorkflowOrchestratorApi.Workflow{
      id:                      payload[:id],
      workflow_id:             payload[:workflow_id],
      deployment_repo:         payload[:deployment_repo],
      deployment_repo_git_ref: payload[:deployment_repo_git_ref],
      source_repo:             payload[:source_repo],
      source_repo_git_ref:     payload[:source_repo_git_ref],
      source_commit_hash:      payload[:source_commit_hash],
      milestones:              payload[:milestones],
      current_step:            payload[:current_step],
      elapsed_step_time:       payload[:elapsed_step_time],
      elapsed_workflow_time:   payload[:elapsed_workflow_time],
      workflow_duration:       payload[:workflow_duration],
      workflow_step_durations: payload[:workflow_step_durations],
      workflow_error:          payload[:workflow_error],
      workflow_completed:      payload[:workflow_completed],
      event_log:               payload[:event_log],
      workflow_start_time:     payload[:workflow_start_time],
      step_time:               payload[:step_time],
      scheduled_start_time:    payload[:scheduled_start_time],
      execute_options:         payload[:execute_options]
    }
  end

  @doc """
  Method to convert a Workflow struct into a map

  ## Options

  The `workflow` option defines the OpenAperture.WorkflowOrchestratorApi.Workflow

  ## Return Values

  Map
  """
  @spec to_payload(OpenAperture.WorkflowOrchestratorApi.Workflow.t) :: map
  def to_payload(workflow) do
    Map.from_struct(workflow)
  end

  @doc """
  Method to publish a "success" notification

  ## Options

  The `request` option defines the Request

  The `message` option defines the message to publish

  ## Return values

  Request
  """
  @spec publish_success_notification(Request.t, String.t) :: Request.t
  def publish_success_notification(request, message) do
    send_notification(request, true, message)
  end

  @doc """
  Method to publish a "failure" notification

  ## Options

  The `request` option defines the Request

  The `message` option defines the message to publish

  ## Return values

  Request
  """
  @spec publish_failure_notification(Request.t, String.t) :: Request.t
  def publish_failure_notification(request, message) do
    send_notification(request, false, message)
  end

  @doc """
  Method to publish a notification

  ## Options

  The `request` option defines the Request

  The `is_success` option defines failure/success of the message

  The `message` option defines the message to publish

  ## Return values

  Request
  """
  @spec send_notification(Request.t, term, String.t) :: Request.t
  def send_notification(request, is_success, message) do
    prefix = "[OA][#{request.workflow.id}]"
    Logger.debug("#{prefix} #{message}")

    hipchat_room_names =  case request.notifications_config do
                            nil -> []
                            _   -> request.notifications_config["hipchat"]["room_names"]
                          end
    NotificationsPublisher.hipchat_notification(request.notifications_exchange_id,
                                                request.notifications_broker_id,
                                                is_success,
                                                prefix,
                                                message,
                                                hipchat_room_names)
    add_event_to_log(request, message, prefix)
  end

  @doc """
  Method to add an event to the workflow's event log

  ## Options

  The `request` option defines the Request

  The `event` option defines a String containing the event to track

  The `prefix` option defines an optional String prefix for the event

  ## Return Values

  Request
  """
  @spec add_event_to_log(Request.t, String.t, String.t) :: Request.t
  def add_event_to_log(request, event, prefix \\ nil) do
    prefix = prefix || "[OA][#{request.workflow.id}]"

    event_log = request.workflow.event_log
    event_log = event_log || []
    event_log = event_log ++ ["#{prefix} #{event}"]
    workflow  = %{request.workflow | event_log: event_log}
    %{request | workflow: workflow}
  end

  @doc """
  Method to notify the WorkflowOrchestrator that a workflow step has failed

  ## Options

  The `request` option defines the Request

  The `event` option defines a String containing the event to track

  The `reason` option defines an optional String description

  ## Return Values

  Request
  """
  @spec step_failed(Request.t, String.t, String.t) :: Request.t
  def step_failed(request, message, reason) do
    workflow = %{request.workflow | workflow_error: true}
    workflow = %{workflow | workflow_completed: true}
    request  = %{request | workflow: workflow}
    request  = add_event_to_log(request, reason)
    request  = publish_failure_notification(request, message)
    WorkflowOrchestratorPublisher.execute_orchestration(request)

    request
  end

  @doc """
  Method to notify the WorkflowOrchestrator that a workflow step has completed

  ## Options

  The `request` option defines the Request

  ## Return Values

  Request
  """
  @spec step_completed(Request.t) :: Request.t
  def step_completed(request) do
    WorkflowOrchestratorPublisher.execute_orchestration(request)
    request
  end

  @doc """

  Method to save Workflow info to the database

  ## Options

  The `request` option defines the Request

  ## Return Value

  Request
  """
  @spec save(Request.t) :: Request.t
  def save(request) do
    workflow_info = to_payload(request.workflow)

    #try do
      workflow_error = workflow_info[:workflow_error]
      if workflow_error == nil && workflow_info[:workflow_completed] != nil  do
        workflow_error = false
      end

      workflow_payload = %{
        id:                       workflow_info[:id],
        deployment_repo:          workflow_info[:deployment_repo],
        deployment_repo_git_ref:  workflow_info[:deployment_repo_git_ref],
        source_repo:              workflow_info[:source_repo],
        source_repo_git_ref:      workflow_info[:source_repo_git_ref],
        source_commit_hash:       workflow_info[:source_commit_hash],
        milestones:               workflow_info[:milestones],
        current_step:             "#{workflow_info[:current_step]}",
        elapsed_step_time:        TimexExtensions.get_elapsed_timestamp(workflow_info[:step_time]),
        elapsed_workflow_time:    TimexExtensions.get_elapsed_timestamp(workflow_info[:workflow_start_time]),
        workflow_duration:        workflow_info[:workflow_duration],
        workflow_step_durations:  workflow_info[:workflow_step_durations],
        workflow_error:           workflow_error,
        workflow_completed:       workflow_info[:workflow_completed],
        event_log:                workflow_info[:event_log],
        scheduled_start_time:     workflow_info[:scheduled_start_time],
        execute_options:          workflow_info[:execute_options]
      }

      case WorkflowAPI.update_workflow(ManagerApi.get_api, workflow_info[:id], workflow_payload) do
        %Response{status: 204}    -> :ok
        %Response{status: status} -> Logger.error("Failed to save workflow; server returned #{status}")
      end
    #catch
    #  :exit, code   ->
    #    Logger.error("Failed to save workflow; Exited with code #{inspect code}")
    #  :throw, value ->
    #    Logger.error("Failed to save workflow; Throw called with #{inspect value}")
    #  what, value   ->
    #    Logger.error("Failed to save workflow; Caught #{inspect what} with #{inspect value}")
    #end

    request
  end
end
