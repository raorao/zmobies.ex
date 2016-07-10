defmodule Zmobies.World do
  alias Zmobies.Map, as: Map
  alias Zmobies.BeingProcess, as: BeingProcess
  use GenServer

  def start do
    GenServer.start(Zmobies.World, nil)
  end

  def add_zombie(pid) do
    GenServer.cast(pid, {:add, :zombie})
  end

  def add_human(pid) do
    GenServer.cast(pid, {:add, :human})
  end

  def move(pid, old_being, new_being) do
    GenServer.call(pid, {:move, old_being, new_being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init(_) do
    {:ok, Map.new}
  end

  def handle_cast({:add, type}, current_map) do
    add = case type do
      :zombie -> Map.add_zombie(current_map)
      :human  -> Map.add_human(current_map)
    end

    case add do
      {:ok, map, being} ->
        BeingProcess.start({self,being})
        {:noreply, map}
      {:error, _} ->
        {:noreply, current_map}
    end
  end

  def handle_call({:move, old_being, new_being}, _, current_map) do
    case Map.move(current_map, old_being, new_being) do
      {:ok, new_map, _} ->
        {:reply, {:ok, new_being}, new_map}
      {:error, message} ->
        {:reply, {:error, message}, current_map}
    end
  end

  def handle_call({:read}, _, map) do
    {:reply, map, map}
  end
end
