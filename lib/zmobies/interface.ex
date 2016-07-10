defmodule Zmobies.Interface do
  alias Zmobies.World, as: World
  alias Zmobies.Interface, as: Interface

  use GenServer

  def setup do
    {:ok, pid} = World.start
    Enum.each((1..3), fn (_) -> World.add_human(pid) end)
    Enum.each((1..10), fn (_) -> World.add_zombie(pid) end)
    :timer.send_interval(200, :print)
    pid
  end

  def start do
    GenServer.start(Interface, nil)
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init(_) do
    world = Interface.setup()
    {:ok, world}
  end

  def handle_info(:print, world_pid) do
    IO.puts(IO.ANSI.clear())
    world = World.read(world_pid)
    IO.inspect(world)
    IO.puts(world)
    {:noreply, world_pid}
  end

  def handle_call({:read}, _, world) do
    {:reply, world, world}
  end
end
