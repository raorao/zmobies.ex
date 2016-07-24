defmodule Zmobies do
  use Application

  def start(_type, _args) do
    Zmobies.Supervisor.init(humans: 450, zombies: 10, dimensions: 40)
  end
end
