defmodule Zmobies.Zombie do
  alias Zmobies.Zombie, as: Zombie
  alias Zmobies.World, as: World
  alias Zmobies.Being, as: Being

  use GenServer

  def start({world_pid, being}) do
    GenServer.start(Zombie, {world_pid, being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init({world_pid, being}) do
    :timer.send_interval(1000, :move_randomly)
    {:ok, {world_pid, being}}
  end

  def handle_info(:move_randomly, {world_pid, old_being}) do
    move = World.move(world_pid, old_being, Being.move_randomly(old_being))

    being = case move do
      {:ok, new_being} -> new_being
      {:error, _} -> old_being
    end

    {:noreply, {world_pid, being}}
  end

  def handle_call({:read}, _, state) do
    {:reply, state, state}
  end
end
