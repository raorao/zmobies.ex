defmodule Zmobies.Interface do
  alias Zmobies.World, as: World
  alias Zmobies.Interface, as: Interface

  use GenServer

  def setup({humans, zombies, dimensions}) do
    {:ok, pid} = World.start(dimensions)
    Enum.each((1..humans),  fn (_) -> World.add_human(pid)  end)
    Enum.each((1..zombies), fn (_) -> World.add_zombie(pid) end)
    :timer.send_interval(200, :print)
    pid
  end

  def stop do
    GenServer.stop(GenServer.whereis(:interface))
  end

  def start do
    start(humans: 3, zombies: 10, dimensions: 10)
  end

  def start(humans: humans, zombies: zombies, dimensions: dimensions) do
    GenServer.start(Interface, {humans, zombies, dimensions}, name: :interface)
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init({humans, zombies, dimensions}) do
    world = Interface.setup({humans, zombies, dimensions})
    {:ok, world}
  end

  def handle_info(:print, world_pid) do
    IO.puts(IO.ANSI.clear())
    world = World.read(world_pid)
    IO.puts(world)
    IO.puts("\n")
    {:noreply, world_pid}
  end

  def handle_call({:read}, _, world) do
    {:reply, world, world}
  end
end
