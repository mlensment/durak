defmodule Durak.Player do
  import Util.MapHelper
  alias __MODULE__

  @preparing "preparing"
  @ready "ready"
  defstruct token: nil, name: nil, game: nil, status: @preparing, downcards: [], upcards: [], hand: []

  @behaviour Access
  def fetch(game, key) do
    Map.fetch(Map.from_struct(game), key)
  end

  def create(attrs) do
    attrs = [token: SecureRandom.uuid] ++ attrs
    attrs |> attrs_to_struct(Player)
  end

  def update_list(list, player) do
    index = list |> Enum.find_index(&map_contains?(&1, %{token: player.token}))
    list |> List.update_at(index, fn _x -> player end)
  end
end
