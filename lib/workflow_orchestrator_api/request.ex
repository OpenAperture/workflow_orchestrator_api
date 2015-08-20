defmodule OpenAperture.WorkflowOrchestratorApi.Request do

  @moduledoc """
  Methods and Request struct that will be received from (and should be sent to) the WorkflowOrchestrator
  """

  alias OpenAperture.WorkflowOrchestratorApi.Workflow

  defstruct workflow:                            nil,
            force_build:                         nil,
            build_messaging_exchange_id:         nil,
            deploy_messaging_exchange_id:        nil,
            orchestration_queue_name:            nil,
            workflow_orchestration_exchange_id:  nil,
            workflow_orchestration_broker_id:    nil,
            notifications_exchange_id:           nil,
            notifications_broker_id:             nil,
            docker_build_etcd_token:             nil,
            etcd_token:                          nil,
            deployable_units:                    nil,
            notifications_config:                nil,
            fleet_config:                        nil

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Request struct

  ## Options

  The `payload` option defines the Map containing the request

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Request.t
  """
  @spec from_payload(map) :: OpenAperture.WorkflowOrchestratorApi.Request.t
  def from_payload(payload) do
    deployable_units = case payload[:deployable_units] do
      nil -> nil
      []  -> []
      _   ->
        Enum.reduce payload[:deployable_units], [], fn deployable_unit, new_units ->
          case deployable_unit do
            nil -> new_units
            _   -> new_units ++ [FleetApi.Unit.from_map(deployable_unit)]
          end
        end
    end

    %OpenAperture.WorkflowOrchestratorApi.Request{
      workflow:                           Workflow.from_payload(payload),
      force_build:                        payload[:force_build],
      build_messaging_exchange_id:        payload[:build_messaging_exchange_id],
      deploy_messaging_exchange_id:       payload[:deploy_messaging_exchange_id],
      orchestration_queue_name:           payload[:orchestration_queue_name],
      notifications_exchange_id:          payload[:notifications_exchange_id],
      notifications_broker_id:            payload[:notifications_broker_id],
      workflow_orchestration_exchange_id: payload[:workflow_orchestration_exchange_id],
      workflow_orchestration_broker_id:   payload[:workflow_orchestration_broker_id],
      docker_build_etcd_token:            payload[:docker_build_etcd_token],
      etcd_token:                         payload[:etcd_token],
      deployable_units:                   deployable_units,
      notifications_config:               payload[:notifications_config],
      fleet_config:                       payload[:fleet_config]
    }
  end

  @doc """
  Method to convert a Request struct into a map

  ## Options

  The `request` option defines the OpenAperture.WorkflowOrchestratorApi.Request.t

  ## Return Values

  Map
  """
  @spec to_payload(OpenAperture.WorkflowOrchestratorApi.Request.t) :: map
  def to_payload(request) do
    deployable_units = case request.deployable_units do
      nil -> nil
      []  -> []
      _   ->
        Enum.reduce request.deployable_units, [], fn deployable_unit, new_units ->
          # FleetApi.Unit.from_map requires keys to be strings
          atom_map = Map.from_struct(deployable_unit)
          json     = Poison.encode!(atom_map)
          new_units ++ [Poison.decode!(json)]
        end
    end

    payload = case request.workflow do
      nil -> %{}
      _   -> Workflow.to_payload(request.workflow)
    end

    payload = Map.put(payload, :force_build, request.force_build)
    payload = Map.put(payload, :build_messaging_exchange_id, request.build_messaging_exchange_id)
    payload = Map.put(payload, :deploy_messaging_exchange_id, request.deploy_messaging_exchange_id)
    payload = Map.put(payload, :orchestration_queue_name, request.orchestration_queue_name)
    payload = Map.put(payload, :workflow_orchestration_exchange_id, request.workflow_orchestration_exchange_id)
    payload = Map.put(payload, :workflow_orchestration_broker_id, request.workflow_orchestration_broker_id)
    payload = Map.put(payload, :notifications_exchange_id, request.notifications_exchange_id)
    payload = Map.put(payload, :notifications_broker_id, request.notifications_broker_id)
    payload = Map.put(payload, :docker_build_etcd_token, request.docker_build_etcd_token)
    payload = Map.put(payload, :etcd_token, request.etcd_token)
    payload = Map.put(payload, :deployable_units, deployable_units)
    payload = Map.put(payload, :notifications_config, request.notifications_config)
    payload = Map.put(payload, :fleet_config, request.fleet_config)
    payload
  end
end
