#
# == supervisor.ex
#
# This module contains the supervisor for the dispatcher
#
require Logger

defmodule OpenAperture.WorkflowOrchestratorApi.Supervisor do
  use Supervisor

  @moduledoc """
  This module contains the supervisor for the dispatcher
  """  
  
  @doc """
  Specific start_link implementation 

  ## Options

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t()} 
  def start_link do
    Logger.info("Starting OpenAperture.WorkflowOrchestratorApi.Supervisor...")
    :supervisor.start_link(__MODULE__, [])
  end

  @doc """
  GenServer callback - invoked when the server is started.

  ## Options

  The `args` option represents the args to the GenServer.

  ## Return Values

  {:ok, state} | {:ok, state, timeout} | :ignore | {:stop, reason}
  """  
  @spec init(term) :: {:ok, term} | {:ok, term, term} | :ignore | {:stop, String.t()}
  def init([]) do
    import Supervisor.Spec

    children = [
      # Define workers and child supervisors to be supervised
      worker(OpenAperture.WorkflowOrchestratorApi.Notifications.Publisher, []),
      worker(OpenAperture.WorkflowOrchestratorApi.WorkflowOrchestrator.Publisher, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    supervise(children, opts)
  end
end