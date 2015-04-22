defmodule OpenAperture.WorkflowOrchestratorApi.RequestTest do
  use ExUnit.Case

  alias OpenAperture.WorkflowOrchestratorApi.Request
  alias OpenAperture.WorkflowOrchestratorApi.Workflow

  test "from_payload" do
  	payload = %{
	  	force_build: false,
	  	orchestration_queue_name: "orchestration_queue_name",
	  	workflow_orchestration_exchange_id: "workflow_orchestration_exchange_id",
	  	workflow_orchestration_broker_id: "workflow_orchestration_broker_id",
	  	notifications_exchange_id: "notifications_exchange_id",
	  	notifications_broker_id: "notifications_broker_id",
	  	docker_build_etcd_token: "docker_build_etcd_token",
	  	etcd_token: "etcd_token",
	  	deployable_units: "deployable_units",
      notifications_config: "notifications_config",
  	}

    request = Request.from_payload(payload)
    assert request != nil
    assert request.workflow != nil
    assert request.force_build == payload[:force_build]
    assert request.orchestration_queue_name == payload[:orchestration_queue_name]
    assert request.workflow_orchestration_exchange_id == payload[:workflow_orchestration_exchange_id]
    assert request.workflow_orchestration_broker_id == payload[:workflow_orchestration_broker_id]
    assert request.notifications_exchange_id == payload[:notifications_exchange_id]
    assert request.notifications_broker_id == payload[:notifications_broker_id]
    assert request.docker_build_etcd_token == payload[:docker_build_etcd_token]
    assert request.etcd_token == payload[:etcd_token]
    assert request.deployable_units == payload[:deployable_units] 
    assert request.notifications_config == payload[:notifications_config] 
  end

  test "to_payload" do
  	request = %Request{
	  	force_build: false,
	  	orchestration_queue_name: "orchestration_queue_name",
	  	workflow_orchestration_exchange_id: "workflow_orchestration_exchange_id",
	  	workflow_orchestration_broker_id: "workflow_orchestration_broker_id",
	  	notifications_exchange_id: "notifications_exchange_id",
	  	notifications_broker_id: "notifications_broker_id",
	  	docker_build_etcd_token: "docker_build_etcd_token",
	  	etcd_token: "etcd_token",
	  	deployable_units: "deployable_units",
      notifications_config: "notifications_config",
  	}

    payload = Request.to_payload(request)
    assert payload != nil
    assert request.force_build == payload[:force_build]
    assert request.orchestration_queue_name == payload[:orchestration_queue_name]
    assert request.workflow_orchestration_exchange_id == payload[:workflow_orchestration_exchange_id]
    assert request.workflow_orchestration_broker_id == payload[:workflow_orchestration_broker_id]
    assert request.notifications_exchange_id == payload[:notifications_exchange_id]
    assert request.notifications_broker_id == payload[:notifications_broker_id]
    assert request.docker_build_etcd_token == payload[:docker_build_etcd_token]
    assert request.etcd_token == payload[:etcd_token]
    assert request.deployable_units == payload[:deployable_units] 
    assert request.notifications_config == payload[:notifications_config] 
  end  
end
