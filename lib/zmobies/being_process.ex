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

  def feed(pid) do
    GenServer.cast(pid, {:feed})
  end

  def turn(pid) do
    GenServer.cast(pid, {:turn})
  end

  def stop(pid) do
    GenServer.cast(pid, {:stop})
  end

  def setup(being) do
    :random.seed(:os.timestamp())
    alteration = :random.uniform(500) - 250
    interval = Being.base_speed(being) + alteration
    {:ok, tref} = :timer.send_interval(interval, :move)
    tref
  end

  # necessary for GenServer
  def init({world_pid, being}) do
    being_with_process = %{being | pid: self}
    tref = BeingProcess.setup(being_with_process)
    {:ok, {world_pid, being_with_process, tref, 0}}
  end

  def handle_info(:move, {world_pid, old_being, tref, lifetime}) do

    if Being.starved?(old_being, lifetime) do
      BeingProcess.stop(old_being.pid)
    end

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

    {:noreply, {world_pid, being, tref, lifetime + 1}}
  end

  def handle_cast({:stop}, {world_pid, being, tref, _}) do
    :timer.cancel(tref)
    Zmobies.World.remove(world_pid, being)
    GenServer.stop(being.pid)
    {:noreply, {world_pid, nil, nil, nil}}
  end

  def handle_cast({:feed}, {world_pid, being, tref, _}) do
    {:noreply, {world_pid, being, tref, 0}}
  end

  def handle_cast({:turn}, {world_pid, being, tref, _}) do
    new_being = %{being | type: :zombie}
    :timer.cancel(tref)
    new_tref = setup(new_being)
    {:noreply, {world_pid, new_being, new_tref, 0}}
  end

  def handle_call({:read}, _, state) do
    {:reply, state, state}
  end
end
