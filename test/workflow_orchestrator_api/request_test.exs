defmodule OpenAperture.WorkflowOrchestratorApi.RequestTest do
  use ExUnit.Case

  alias OpenAperture.WorkflowOrchestratorApi.Request
  alias OpenAperture.WorkflowOrchestratorApi.Workflow

  test "from_payload" do
  	payload = %{
	  	force_build: false,
      build_messaging_exchange_id: 123,
      deploy_messaging_exchange_id: 234,
	  	orchestration_queue_name: "orchestration_queue_name",
	  	workflow_orchestration_exchange_id: "workflow_orchestration_exchange_id",
	  	workflow_orchestration_broker_id: "workflow_orchestration_broker_id",
	  	notifications_exchange_id: "notifications_exchange_id",
	  	notifications_broker_id: "notifications_broker_id",
	  	docker_build_etcd_token: "docker_build_etcd_token",
	  	etcd_token: "etcd_token",
	  	deployable_units: [%{"name" => "test", "options" => []}],
      notifications_config: "notifications_config",
      aws_config: %{"name" => "test"},
      ecs_task_definition: "something something"
  	}

    request = Request.from_payload(payload)
    assert request != nil
    assert request.workflow != nil
    assert request.force_build == payload[:force_build]
    assert request.build_messaging_exchange_id == payload[:build_messaging_exchange_id]
    assert request.deploy_messaging_exchange_id == payload[:deploy_messaging_exchange_id]
    assert request.orchestration_queue_name == payload[:orchestration_queue_name]
    assert request.workflow_orchestration_exchange_id == payload[:workflow_orchestration_exchange_id]
    assert request.workflow_orchestration_broker_id == payload[:workflow_orchestration_broker_id]
    assert request.notifications_exchange_id == payload[:notifications_exchange_id]
    assert request.notifications_broker_id == payload[:notifications_broker_id]
    assert request.docker_build_etcd_token == payload[:docker_build_etcd_token]
    assert request.etcd_token == payload[:etcd_token]
    assert request.deployable_units == [%FleetApi.Unit{currentState: nil, desiredState: nil, machineID: nil, name: "test", options: []}]
    assert request.notifications_config == payload[:notifications_config] 
    assert request.aws_config == payload[:aws_config] 
    assert request.ecs_task_definition == payload[:ecs_task_definition]
  end

  test "to_payload" do
  	request = %Request{
	  	force_build: false,
      build_messaging_exchange_id: 123,
      deploy_messaging_exchange_id: 234,      
	  	orchestration_queue_name: "orchestration_queue_name",
	  	workflow_orchestration_exchange_id: "workflow_orchestration_exchange_id",
	  	workflow_orchestration_broker_id: "workflow_orchestration_broker_id",
	  	notifications_exchange_id: "notifications_exchange_id",
	  	notifications_broker_id: "notifications_broker_id",
	  	docker_build_etcd_token: "docker_build_etcd_token",
	  	etcd_token: "etcd_token",
	  	deployable_units: [%FleetApi.Unit{name: "test"}],
      notifications_config: "notifications_config",
      aws_config: %{"name" => "test"},
  	}

    payload = Request.to_payload(request)
    assert payload != nil
    assert request.force_build == payload[:force_build]
    assert request.build_messaging_exchange_id == payload[:build_messaging_exchange_id]
    assert request.deploy_messaging_exchange_id == payload[:deploy_messaging_exchange_id]
    assert request.orchestration_queue_name == payload[:orchestration_queue_name]
    assert request.workflow_orchestration_exchange_id == payload[:workflow_orchestration_exchange_id]
    assert request.workflow_orchestration_broker_id == payload[:workflow_orchestration_broker_id]
    assert request.notifications_exchange_id == payload[:notifications_exchange_id]
    assert request.notifications_broker_id == payload[:notifications_broker_id]
    assert request.docker_build_etcd_token == payload[:docker_build_etcd_token]
    assert request.etcd_token == payload[:etcd_token]
    assert payload[:deployable_units] == [%{"currentState" => nil, "desiredState" => nil, "machineID" => nil, "name" => "test", "options" => []}]
    assert request.notifications_config == payload[:notifications_config] 
    assert request.aws_config == payload[:aws_config] 
    assert request.ecs_task_definition == payload[:ecs_task_definition]
  end  
end
