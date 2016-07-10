defmodule Zmobies.World do
  alias Zmobies.Map, as: Map
  alias Zmobies.Zombie, as: Zombie
  use GenServer

  # iex testing interface
  def test do
    {:ok, pid} = Zmobies.World.start
    Enum.each((1..10), fn (_) -> Zmobies.World.add(pid) end)
    IO.puts(Zmobies.World.read(pid))
    Zmobies.World.fetch
  end

  def stop do
    GenServer.stop(Zmobies.World.fetch)
  end

  def fetch do
    GenServer.whereis(:map)
  end

  def start do
    GenServer.start(Zmobies.World, nil, name: :map)
  end

  # the real stuff!
  def add(pid) do
    GenServer.cast(pid, {:add})
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

  def handle_cast({:add}, current_map) do
    case Map.add(current_map) do
      {:ok, map, being} ->
        Zombie.start({self,being})
        {:noreply, map}
      {:error, _} ->
        {:noreply, current_map}
    end
  end

  def handle_call({:move, old_being, new_being}, _, current_map) do
    case Map.move(current_map, old_being, new_being) do
      {:ok, new_map, _} ->
        IO.puts("\n")
        IO.puts(new_map)
        {:reply, {:ok, new_being}, new_map}
      {:error, message} ->
        {:reply, {:error, message}, current_map}
    end
  end

  def handle_call({:read}, _, map) do
    {:reply, map, map}
  end
end
