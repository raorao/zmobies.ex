defmodule Zmobies.World do
  alias Zmobies.Map, as: Map
  alias Zmobies.Being, as: Being

  alias Zmobies.BeingProcess, as: BeingProcess
  use GenServer

  def start(dimensions) do
    GenServer.start(Zmobies.World, dimensions)
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

  def find_nearest_enemy(pid, being) do
    GenServer.call(pid, {:find_nearest_enemy, being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init(dimensions) do
    {:ok, Map.new(dimensions, dimensions)}
  end

  def handle_cast({:add, type}, current_map) do
    add = case type do
      :zombie -> Map.add_zombie(current_map)
      :human  -> Map.add_human(current_map)
    end

    case add do
      {:ok, map, being} ->
        {:ok, being_pid} = BeingProcess.start({self,being})
        {:ok, map, being} = Map.update_being(map, %{ being | pid: being_pid })
        {:noreply, map}
      {:collision, _, _} ->
        {:noreply, current_map}
      {:error, _} ->
        {:noreply, current_map}
    end
  end

  def handle_call({:move, old_being, new_being}, _, current_map) do
    case Map.move(current_map, old_being, new_being) do
      {:ok, new_map, _} ->
        {:reply, {:ok, new_being}, new_map}
      {:collision, being, other} ->
        cond do
          being.type == other.type ->
            {:reply, {:error, "collision"}, current_map}

          being.type == :human ->
            {:ok, new_map, _} = Map.update_being(current_map, %{ being | type: :zombie })
            BeingProcess.update(being.pid, :zombie)

            {:reply, {:error, "collision"}, new_map}

          other.type == :human ->
            {:ok, new_map, _} = Map.update_being(current_map, %{ other | type: :zombie })
            BeingProcess.update(other.pid, :zombie)

            {:reply, {:error, "collision"}, new_map}
        end
      {:error, message} ->
        {:reply, {:error, message}, current_map}
    end
  end

  def handle_call({:find_nearest_enemy, being}, _, current_map) do
    enemies = current_map.beings
      |> Enum.reject(Being.same_location?(being))
      |> Enum.reject(Being.same_type?(being))

    reply = if Enum.empty?(enemies) do
      {:error, "#{being} is alone on the map"}
    else
      enemy = Enum.min_by(enemies, Being.distance_from(being))
      if Being.can_see?(being, enemy) do
        {:ok, enemy}
      else
        {:error, "no beings nearby."}
      end
    end

    {:reply, reply, current_map }
  end


  def handle_call({:read}, _, map) do
    {:reply, map, map}
  end
end
