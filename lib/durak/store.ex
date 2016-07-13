defmodule Durak.Store do
  use GenServer
  alias Durak.Store
  alias Durak.Game
  alias Util.MapHelper

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
    {:reply, game, [struct_to_map(game) | state]}
  end

  def handle_call({:update, game}, _form, state) do
    index = state |> Enum.find_index(&MapHelper.contains?(&1, %{id: game.id}))
    state = state |> List.update_at(index, fn _x -> struct_to_map(game) end)
    {:reply, game, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_by_attrs, attrs}, _from, state) do
    attrs = Enum.into(attrs, %{})
    game = state |> Enum.find(&MapHelper.contains?(&1, attrs)) |> map_to_struct
    {:reply, game, state}
  end


  defp struct_to_map(struct) do
    Map.delete(struct, :__struct__)
  end

  defp map_to_struct(map = %{}) do
    struct(Game, map)
  end

  defp map_to_struct(nil) do
    nil
  end
end
