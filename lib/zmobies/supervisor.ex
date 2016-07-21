defmodule Zmobies.Supervisor do
  use Supervisor

  def init(_) do
    children = [
      worker(Zmobies.Interface, []),
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
