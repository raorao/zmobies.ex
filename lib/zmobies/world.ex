defmodule Zmobies.World do
  alias Zmobies.Map, as: Map
  use GenServer

  def start do
    GenServer.start(Zmobies.World, nil)
  end

  def add(pid) do
    GenServer.cast(pid, {:add})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init(_) do
    {:ok, Map.new}
  end

  def handle_cast({:add}, current_map) do
    new_map = case Map.add(current_map) do
      {:ok, map} -> map
      {:error, _} -> current_map
    end

    {:noreply, new_map}
  end

  def handle_call({:read}, _, map) do
    {:reply, map, map}
  end
end
