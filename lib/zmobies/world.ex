defmodule Zmobies.World do
  alias Zmobies.Map, as: Map
  alias Zmobies.Zombie, as: Zombie
  use GenServer

  def start do
    GenServer.start(Zmobies.World, nil)
  end

  def add(pid) do
    GenServer.cast(pid, {:add})
  end

  def move(pid, old_being, new_being) do
    GenServer.cast(pid, {:move, old_being, new_being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init(_) do
    {:ok, Map.new}
  end

  def handle_cast({:add}, current_map) do
    case Map.add(current_map) do
      {:ok, map, being} ->
        Zombie.start({self,being})
        {:noreply, map}
      {:error, _} ->
        {:noreply, current_map}
    end
  end

  def handle_cast({:move, old_being, new_being}, current_map) do
    case Map.move(current_map, old_being, new_being) do
      {:ok, new_map, _} -> {:noreply, new_map}
      {:error, _} -> {:noreply, current_map}
    end
  end

  def handle_call({:read}, _, map) do
    {:reply, map, map}
  end
end
