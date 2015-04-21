defmodule OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.PublisherTest do
  use ExUnit.Case

  alias OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.Publisher
  alias OpenAperture.WorkflowOrchestratorApi.Request

  alias OpenAperture.Messaging.ConnectionOptionsResolver
  alias OpenAperture.Messaging.AMQP.ConnectionOptions, as: AMQPConnectionOptions

  alias OpenAperture.Messaging.AMQP.QueueBuilder
  alias OpenAperture.Messaging.AMQP.ConnectionPool
  alias OpenAperture.Messaging.AMQP.ConnectionPools

  #=========================
  # handle_cast({:execute_orchestration, payload}) tests

  test "handle_cast({:execute_orchestration, payload}) - success" do
  	:meck.new(ConnectionPools, [:passthrough])
  	:meck.expect(ConnectionPools, :get_pool, fn _ -> %{} end)

  	:meck.new(ConnectionPool, [:passthrough])
  	:meck.expect(ConnectionPool, :publish, fn _, _, _, _ -> :ok end)

    :meck.new(QueueBuilder, [:passthrough])
    :meck.expect(QueueBuilder, :build, fn _,_,_ -> %OpenAperture.Messaging.Queue{name: ""} end)      

    :meck.new(ConnectionOptionsResolver, [:passthrough])
    :meck.expect(ConnectionOptionsResolver, :get_for_broker, fn _, _ -> %AMQPConnectionOptions{} end)

  	state = %{
  	}

  	request = %Request{}
    assert Publisher.handle_cast({:execute_orchestration, request}, state) == {:noreply, state}
  after
  	:meck.unload(ConnectionPool)
  	:meck.unload(ConnectionPools)
    :meck.unload(QueueBuilder)
    :meck.unload(ConnectionOptionsResolver)        
  end
end
