defmodule OpenAperture.WorkflowOrchestratorApi.WorkflowTest do
  use ExUnit.Case

  alias OpenAperture.WorkflowOrchestratorApi.Workflow
  alias OpenAperture.WorkflowOrchestratorApi.Request
  alias OpenAperture.WorkflowOrchestratorApi.Notifications.Publisher, as: NotificationsPublisher
  alias OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.Publisher, as: WorkflowOrchestratorPublisher

  test "from_payload" do
  	payload = %{
			id: "id",
			workflow_id: "workflow_id",
			deployment_repo: "deployment_repo",
			deployment_repo_git_ref: "deployment_repo_git_ref",
			source_repo: "source_repo",
			source_repo_git_ref: "source_repo_git_ref",
			source_commit_hash: "source_commit_hash",
			milestones: "milestones",
			current_step: "current_step",
			elapsed_step_time: "elapsed_step_time",
			elapsed_workflow_time: "elapsed_workflow_time",
			workflow_duration: "workflow_duration",
			workflow_step_durations: "workflow_step_durations",
			workflow_error: "workflow_error",
			workflow_completed: "workflow_completed",
			event_log: "event_log"
  	}

    workflow = Workflow.from_payload(payload)
    assert workflow != nil
    assert workflow.id == payload[:id]
    assert workflow.workflow_id == payload[:workflow_id]
    assert workflow.deployment_repo == payload[:deployment_repo]
    assert workflow.deployment_repo_git_ref == payload[:deployment_repo_git_ref]
    assert workflow.source_repo == payload[:source_repo]
    assert workflow.source_repo_git_ref == payload[:source_repo_git_ref]
    assert workflow.source_commit_hash == payload[:source_commit_hash]
    assert workflow.milestones == payload[:milestones]
    assert workflow.current_step == payload[:current_step] 
    assert workflow.elapsed_step_time == payload[:elapsed_step_time] 
    assert workflow.elapsed_workflow_time == payload[:elapsed_workflow_time] 
    assert workflow.workflow_duration == payload[:workflow_duration] 
    assert workflow.workflow_step_durations == payload[:workflow_step_durations] 
    assert workflow.workflow_error == payload[:workflow_error] 
    assert workflow.workflow_completed == payload[:workflow_completed] 
    assert workflow.event_log == payload[:event_log] 
  end

  test "to_payload" do
  	workflow = %Workflow{
			id: "id",
			workflow_id: "workflow_id",
			deployment_repo: "deployment_repo",
			deployment_repo_git_ref: "deployment_repo_git_ref",
			source_repo: "source_repo",
			source_repo_git_ref: "source_repo_git_ref",
			source_commit_hash: "source_commit_hash",
			milestones: "milestones",
			current_step: "current_step",
			elapsed_step_time: "elapsed_step_time",
			elapsed_workflow_time: "elapsed_workflow_time",
			workflow_duration: "workflow_duration",
			workflow_step_durations: "workflow_step_durations",
			workflow_error: "workflow_error",
			workflow_completed: "workflow_completed",
			event_log: "event_log"
  	}

    payload = Workflow.to_payload(workflow)
    assert payload != nil
    assert workflow.id == payload[:id]
    assert workflow.workflow_id == payload[:workflow_id]
    assert workflow.deployment_repo == payload[:deployment_repo]
    assert workflow.deployment_repo_git_ref == payload[:deployment_repo_git_ref]
    assert workflow.source_repo == payload[:source_repo]
    assert workflow.source_repo_git_ref == payload[:source_repo_git_ref]
    assert workflow.source_commit_hash == payload[:source_commit_hash]
    assert workflow.milestones == payload[:milestones]
    assert workflow.current_step == payload[:current_step] 
    assert workflow.elapsed_step_time == payload[:elapsed_step_time] 
    assert workflow.elapsed_workflow_time == payload[:elapsed_workflow_time] 
    assert workflow.workflow_duration == payload[:workflow_duration] 
    assert workflow.workflow_step_durations == payload[:workflow_step_durations] 
    assert workflow.workflow_error == payload[:workflow_error] 
    assert workflow.workflow_completed == payload[:workflow_completed] 
    assert workflow.event_log == payload[:event_log]
  end 

  test "publish_success_notification" do
  	:meck.new(NotificationsPublisher, [:passthrough])
  	:meck.expect(NotificationsPublisher, :hipchat_notification, fn _, _, _, _, _ -> :ok end)

  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.publish_success_notification(request, "test message")
  	assert returned_request != nil
  	assert returned_request.workflow != nil
  	assert returned_request.workflow.event_log != nil
  	assert length(returned_request.workflow.event_log) == 1
  	assert String.contains?(List.first(returned_request.workflow.event_log), "test message")
  after
  	:meck.unload(NotificationsPublisher)
  end

  test "publish_failure_notification" do
  	:meck.new(NotificationsPublisher, [:passthrough])
  	:meck.expect(NotificationsPublisher, :hipchat_notification, fn _, _, _, _, _ -> :ok end)

  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.publish_failure_notification(request, "test message")
  	assert returned_request != nil
  	assert returned_request.workflow != nil
  	assert returned_request.workflow.event_log != nil
  	assert length(returned_request.workflow.event_log) == 1
  	assert String.contains?(List.first(returned_request.workflow.event_log), "test message")
  after
  	:meck.unload(NotificationsPublisher)
  end  

  test "send_notification" do
  	:meck.new(NotificationsPublisher, [:passthrough])
  	:meck.expect(NotificationsPublisher, :hipchat_notification, fn _, _, _, _, _ -> :ok end)

  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.send_notification(request, true, "test message")
  	assert returned_request != nil
  	assert returned_request.workflow != nil
  	assert returned_request.workflow.event_log != nil
  	assert length(returned_request.workflow.event_log) == 1
  	assert String.contains?(List.first(returned_request.workflow.event_log), "test message")
  after
  	:meck.unload(NotificationsPublisher)
  end  

  test "add_event_to_log" do
  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.add_event_to_log(request, "test message")
  	assert returned_request != nil
  	assert returned_request.workflow != nil
  	assert returned_request.workflow.event_log != nil
  	assert length(returned_request.workflow.event_log) == 1
  	assert String.contains?(List.first(returned_request.workflow.event_log), "test message")
  end  

  test "step_failed" do
  	:meck.new(NotificationsPublisher, [:passthrough])
  	:meck.expect(NotificationsPublisher, :hipchat_notification, fn _, _, _, _, _ -> :ok end)

  	:meck.new(WorkflowOrchestratorPublisher, [:passthrough])
  	:meck.expect(WorkflowOrchestratorPublisher, :execute_orchestration, fn _ -> :ok end)

  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.step_failed(request, "test message", "something more detailed")
  	assert returned_request != nil
  after
  	:meck.unload(NotificationsPublisher)
  	:meck.unload(WorkflowOrchestratorPublisher)
  end    

  test "step_completed" do
  	:meck.new(NotificationsPublisher, [:passthrough])
  	:meck.expect(NotificationsPublisher, :hipchat_notification, fn _, _, _, _, _ -> :ok end)

  	:meck.new(WorkflowOrchestratorPublisher, [:passthrough])
  	:meck.expect(WorkflowOrchestratorPublisher, :execute_orchestration, fn _ -> :ok end)

  	request = %Request{
  		workflow: %Workflow{
  			event_log: []
  		},
  	}

  	returned_request = Workflow.step_completed(request)
  	assert returned_request != nil
  after
  	:meck.unload(NotificationsPublisher)
  	:meck.unload(WorkflowOrchestratorPublisher)
  end    
end