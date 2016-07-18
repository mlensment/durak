defmodule Durak.Store do
  use GenServer
  import Util.MapHelper
  alias Durak.Store

  def start_link do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set(game) do
    GenServer.call(Store, {:set, game})
  end

  def update(game) do
    GenServer.call(Store, {:update, game})
  end

  def all do
    GenServer.call(Store, :all)
  end

  def get_by(attrs) do
    GenServer.call(Store, {:get_by_attrs, attrs})
  end

  def clear do
    :ok = GenServer.cast(Store  , :clear)
  end

  ### Server Callbacks

  def init(_) do
    {:ok, []}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  def handle_call({:set, game}, _from, state) do
    {:reply, game, [game | state]}
  end

  def handle_call({:update, game}, _form, state) do
    index = state |> Enum.find_index(&map_contains?(&1, %{id: game.id}))
    state = state |> List.update_at(index, fn _x -> game end)
    {:reply, game, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_by_attrs, attrs}, _from, state) do
    attrs = attrs_to_map(attrs)
    game = state |> Enum.find(&map_contains?(&1, attrs))
    {:reply, game, state}
  end
end
