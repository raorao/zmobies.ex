defmodule Zmobies.Supervisor do
  use Supervisor

  def init(humans: humans, zombies: zombies, dimensions: dimensions) do
    children = [
      supervisor(Zmobies.BeingSupervisor, [], restart: :transient),
      worker(Zmobies.Interface, [{humans, zombies, dimensions}], restart: :transient),
    ]

    opts = [strategy: :one_for_all, name: :zmobies_supervisor]
    Supervisor.start_link(children, opts)
  end
end
