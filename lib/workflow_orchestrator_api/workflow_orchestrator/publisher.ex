require Logger

defmodule OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.Publisher do
  use GenServer

  @moduledoc """
  This module contains the logic to publish messages to the WorkflowOrchestrator system module
  """

  alias OpenAperture.ManagerApi

  alias OpenAperture.Messaging.AMQP.QueueBuilder
  alias OpenAperture.Messaging.ConnectionOptionsResolver

  alias OpenAperture.ManagerApi
  alias OpenAperture.WorkflowOrchestratorApi.Request

  @connection_options nil
  use OpenAperture.Messaging

  @doc """
  Specific start_link implementation (required by the supervisor)

  ## Options

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t}
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Method to publish to the WorkflowOrchestrator

  ## Options

  The `request` option defines the `OpenAperture.WorkflowOrchestratorApi.Request`

  ## Return Values

  :ok | {:error, reason}
  """
  @spec execute_orchestration(Request.t) :: :ok | {:error, String.t}
  def execute_orchestration(request) do
    GenServer.cast(__MODULE__, {:execute_orchestration, request})
  end

  @doc """
  Call handler to publish to the WorkflowOrchestrator

  ## Options

  The `request` option defines the `OpenAperture.WorkflowOrchestratorApi.Request`

  The `_from` option defines the tuple {from, ref}

  The `state` option represents the server's current state

  ## Return Values

  {:reply, {messaging_exchange_id, machine}, resolved_state}
  """
  @spec handle_cast({:execute_orchestration, Request.t}, map) :: {:noreply, map}
  def handle_cast({:execute_orchestration, request}, state) do
    workflow_orchestration_queue = QueueBuilder.build(ManagerApi.get_api, request.orchestration_queue_name, request.workflow_orchestration_exchange_id)
    options = ConnectionOptionsResolver.get_for_broker(ManagerApi.get_api, request.workflow_orchestration_broker_id)
    payload = Request.to_payload(request)
    case publish(options, workflow_orchestration_queue, payload) do
      :ok -> Logger.debug("[WorkflowOrchestratorApi][Publisher] Successfully published to the WorkflowOrchestrator")
      {:error, reason} -> Logger.error("[WorkflowOrchestratorApi][Publisher] Failed to publish to the WorkflowOrchestrator:  #{inspect reason}")
    end
    {:noreply, state}
  end
end
