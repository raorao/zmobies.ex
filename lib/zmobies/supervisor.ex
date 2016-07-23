defmodule Zmobies.Supervisor do
  use Supervisor

  def init(_) do
    children = [
      worker(Zmobies.Interface, [], restart: :transient),
      supervisor(Zmobies.BeingSupervisor, [])
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
