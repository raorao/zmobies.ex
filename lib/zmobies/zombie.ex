defmodule Zmobies.Zombie do
  alias Zmobies.Zombie, as: Zombie
  use GenServer

  def start({world_pid, being}) do
    GenServer.start(Zombie, {world_pid, being})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  # necessary for GenServer
  def init({world_pid, being}) do
    {:ok, {world_pid, being}}
  end

  def handle_call({:read}, _, state) do
    {:reply, state, state}
  end
end
