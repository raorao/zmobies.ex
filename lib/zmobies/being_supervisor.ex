defmodule Zmobies.BeingSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :being_supervisor)
  end

  def start_child(args) do
    Supervisor.start_child(:being_supervisor, [args])
  end

  def init(_) do
    supervise(
      [worker(Zmobies.BeingProcess, [])],
      strategy: :simple_one_for_one
    )
  end
end
