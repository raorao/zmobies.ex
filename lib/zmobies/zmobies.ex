defmodule Zmobies do
  def start, do: start(humans: 3, zombies: 10, dimensions: 10)
  def start(humans, zombies), do: start(humans: humans, zombies: zombies, dimensions: 40)
  def start(humans: humans, zombies: zombies, dimensions: dimensions) do
    Zmobies.Supervisor.init(humans: humans, zombies: zombies, dimensions: dimensions)
  end

  def stop do
    Supervisor.stop(:zmobies_supervisor)
  end
end
