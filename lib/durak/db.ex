defmodule Durak.Db do
  use GenServer
  alias Durak.Db

  def start_link do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set(k, v) do
    :ok = GenServer.cast(Db, {:set, k, v})
  end

  def get(k) do
    GenServer.call(Db, {:get, k})
  end

  def clear do
    :ok = GenServer.cast(Db, :clear)
  end

  ### Server Callbacks

  def init(_) do
    {:ok, zero_state}
  end

  def handle_cast({:set, k, v}, state) do
    {:noreply, state |> Map.put(k, v)}
  end

  def handle_cast(:clear, _state) do
    {:noreply, zero_state}
  end

  def handle_call({:get, k}, _from, state) do
    {:reply, state |> Map.get(k), state}
  end

  defp zero_state, do: %{}
end
