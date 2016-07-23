defmodule Zmobies.Interface do
  alias Zmobies.World, as: World
  alias Zmobies.Interface, as: Interface

  use GenServer

  def setup({humans, zombies, dimensions}) do
    {:ok, pid} = World.start_link(dimensions)
    Enum.each((1..humans),  fn (_) -> World.add_human(pid)  end)
    Enum.each((1..zombies), fn (_) -> World.add_zombie(pid) end)
    :timer.send_interval(75, :print)
    pid
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def start_link({humans, zombies, dimensions}) do
    GenServer.start_link(Interface, {humans, zombies, dimensions}, name: :interface)
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
    # IO.puts(IO.ANSI.clear())
    world = World.read(world_pid)

    IO.puts(world)
    IO.puts("\n")

    if World.stable?(world) do
      IO.puts("world is stable. The #{World.winner(world)} have won.")
      Interface.stop(self)
    end

    {:noreply, world_pid}
  end

  def handle_call({:read}, _, world) do
    {:reply, world, world}
  end
end
