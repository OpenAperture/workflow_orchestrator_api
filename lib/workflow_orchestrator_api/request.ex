defmodule OpenAperture.WorkflowOrchestratorApi.Request do

	@moduledoc """
	Methods and Request struct that will be received from (and should be sent to) the WorkflowOrchestrator
	"""
	
	alias OpenAperture.WorkflowOrchestratorApi.Workflow

  defstruct workflow: nil,
  	force_build: nil,
  	orchestration_queue_name: nil,
  	workflow_orchestration_exchange_id: nil,
  	workflow_orchestration_broker_id: nil,
  	notifications_exchange_id: nil,
  	notifications_broker_id: nil,
  	docker_build_etcd_token: nil,
  	etcd_token: nil,
  	deployable_units: nil

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Request struct

  ## Options

  The `payload` option defines the Map containing the request

  ## Return Values

  OpenAperture.WorkflowOrchestratorApi.Request.t
  """
  @spec from_payload(Map) :: OpenAperture.WorkflowOrchestratorApi.Request.t
  def from_payload(payload) do
  	%OpenAperture.WorkflowOrchestratorApi.Request{
  		workflow: Workflow.from_payload(payload),
  		force_build: payload[:force_build],
	  	orchestration_queue_name: payload[:orchestration_queue_name],
	  	notifications_exchange_id: payload[:notifications_exchange_id],
	  	notifications_broker_id: payload[:notifications_broker_id],
	  	workflow_orchestration_exchange_id: payload[:workflow_orchestration_exchange_id],
	  	workflow_orchestration_broker_id: payload[:workflow_orchestration_broker_id],
	  	docker_build_etcd_token: payload[:docker_build_etcd_token],
	  	etcd_token: payload[:etcd_token],
	  	deployable_units: payload[:deployable_units]
    }
  end

  @doc """
  Method to convert a Request struct into a map

  ## Options

  The `request` option defines the OpenAperture.WorkflowOrchestratorApi.Request.t

  ## Return Values

  Map
  """
  @spec to_payload(OpenAperture.WorkflowOrchestratorApi.Request.t) :: Map
  def to_payload(request) do
  	payload = if request.workflow != nil do 
  		Workflow.to_payload(request.workflow)
  	else
  		%{}
  	end
  	payload = Map.put(payload, :force_build, request.force_build)
  	payload = Map.put(payload, :orchestration_queue_name, request.orchestration_queue_name)
  	payload = Map.put(payload, :workflow_orchestration_exchange_id, request.workflow_orchestration_exchange_id)
  	payload = Map.put(payload, :workflow_orchestration_broker_id, request.workflow_orchestration_broker_id)
  	payload = Map.put(payload, :notifications_exchange_id, request.notifications_exchange_id)
  	payload = Map.put(payload, :notifications_broker_id, request.notifications_broker_id)  	
  	payload = Map.put(payload, :docker_build_etcd_token, request.docker_build_etcd_token)
  	payload = Map.put(payload, :etcd_token, request.etcd_token)
  	payload = Map.put(payload, :deployable_units, request.deployable_units)

  	payload
  end
end