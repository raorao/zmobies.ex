defmodule Zmobies.BeingProcess do
  alias Zmobies.BeingProcess, as: BeingProcess
  alias Zmobies.World, as: World
  alias Zmobies.Being, as: Being

  use GenServer

  def start({world_pid, being}) do
    GenServer.start(BeingProcess, {world_pid, being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  def update(pid, type) do
    GenServer.cast(pid, {:update, type})
  end

  def setup(being) do
    :random.seed(:os.timestamp())
    alteration = :random.uniform(500) - 250
    interval = Being.base_speed(being) + alteration
    :timer.send_interval(interval, :move)
  end

  # necessary for GenServer
  def init({world_pid, being}) do
    being_with_process = %{being | pid: self}
    BeingProcess.setup(being_with_process)
    {:ok, {world_pid, being_with_process}}
  end

  def handle_info(:move, {world_pid, old_being}) do

    new_being = case World.find_nearest_enemy(world_pid, old_being) do
      {:ok, enemy} ->
        case old_being.type do
          :human  -> Being.move_away(old_being, enemy)
          :zombie -> Being.move_towards(old_being, enemy)
        end
      {:error, _ } -> Being.move_randomly(old_being)
    end

    move = World.move(world_pid, old_being, new_being)

    being = case move do
      {:ok, new_being} -> new_being
      {:error, _} -> old_being
    end

    {:noreply, {world_pid, being}}
  end

  def handle_cast({:update, type}, {world_pid, being}) do
    new_being = %{being | type: type}
    {:noreply, {world_pid, new_being}}
  end

  def handle_call({:read}, _, state) do
    {:reply, state, state}
  end
end
