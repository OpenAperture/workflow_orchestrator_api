defmodule OpenAperture.WorkflowOrchestratorApi.Mixfile do
  use Mix.Project

  def project do
    [app: :openaperture_workflow_orchestrator_api,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: { OpenAperture.WorkflowOrchestratorApi, [] },
      applications: [:logger, :openaperture_messaging, :openaperture_manager_api]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ex_doc, github: "elixir-lang/ex_doc", only: [:test]},
      {:markdown, github: "devinus/markdown", only: [:test]},
      
      {:poison, "~> 1.3.1"},
      {:openaperture_messaging, git: "https://github.com/OpenAperture/messaging.git", ref: "e3247e4fbcc097a3156e3b95ad2115408693ca12", override: true},
      {:openaperture_manager_api, git: "https://github.com/OpenAperture/manager_api.git", ref: "32986942e702dc4b32ab9118362cda992949fa6c", override: true},

      {:timex, "~> 0.12.9"},
      {:timex_extensions, git: "https://github.com/OpenAperture/timex_extensions.git", ref: "904f65f7f9f5d4e52619859e886c2e9a73b96bc0", override: true},

      #test dependencies
      {:exvcr, github: "parroty/exvcr", override: true},
      {:meck, "0.8.2", override: true}
    ]
  end
end
