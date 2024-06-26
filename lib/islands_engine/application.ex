defmodule IslandsEngine.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IslandsEngine.GamesRepository.new()

    children = [
      {Registry, keys: :unique, name: Registry.Game},
      IslandsEngine.GameSupervisor
    ]
    opts = [strategy: :one_for_one, name: IslandsEngine.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
