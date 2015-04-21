# OpenAperture.WorkflowOrchestratorApi

This reusable Elixir messaging library provides an application for interacting with the WorkflowOrchestrator system module.  It provides the following features:

* Provides a Publisher to send events to the Notifications module
* Provides a Publisher to send events to the WorkflowOrchestrator module
* Provides a Request and Workflow struct for interacting with payloads from the WorkflowOrchestrator module

## Usage

Add the :openaperture_workflow_orchestrator_api application to your Elixir application or module.

### Workflow

The Workflow module can be used to interact with the payload from a Workflow Orchestrator:

```iex
request = OpenAperture.WorkflowOrchestratorApi.Request.from_payload(payload)
OpenAperture.WorkflowOrchestratorApi.Workflow.step_completed(request)
```

## Module Configuration

The following configuration values must be defined as part of your application's environment configuration files:

n/a

This module also depends on [Messaging](https://github.com/OpenAperture/messaging) and [ManagerApi](https://github.com/OpenAperture/manager_api), so those configuration values must be present as well.

## Building & Testing

The normal elixir project setup steps are required:

```iex
mix do deps.get, deps.compile
```

You can then run the tests

```iex
MIX_ENV=test mix test test/
```
