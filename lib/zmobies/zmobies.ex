defmodule Zmobies do
  use Application

  def start(_type, _args) do
    %{humans: humans, zombies: zombies, dimensions: dimensions} = Application.get_all_env(:zmobies) |> Enum.into(%{})
    Zmobies.Supervisor.init({humans, zombies, dimensions})
  end
end
