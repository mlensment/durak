defmodule Durak.Game do
  import Util.MapHelper
  alias Durak.Store
  alias Durak.Player
  alias Durak.Deck
  alias __MODULE__

  @waiting "waiting"
  @started "started"
  defstruct status: @waiting, id: nil, in_turn: nil, deck: [], players: []

  @behaviour Access
  def fetch(game, key) do
    Map.fetch(Map.from_struct(game), key)
  end

  def find_or_create do
    game = Store.get_by(status: @waiting)

    if !game || length(game.players) >= 5 do
      game = %Game{id: SecureRandom.uuid, deck: Deck.prepare} |> Store.set
    end

    game
  end

  def find_by(attrs) do
    Store.get_by(attrs)
  end

  def find_game_and_player(token) do
    game = find_by(players: [%{token: token}])
    player = Enum.find(game.players, &map_contains?(&1, %{token: token}))
    {game, player}
  end

  def start(game) do
    player_count = length(game.players)
    cond do
      player_count <= 1 || player_count > 5 ->
        {:error, "Amount of players must be between 2 and 5"}
      Enum.any?(game.players, fn x -> x.status != "ready" end) ->
        {:error, "All players must be ready to start the game"}
      true ->
        %{game | status: @started, in_turn: List.first(game.players) } |> update
    end
  end

  # So we can pipe
  def join({game, _player}, new_player), do: join(game, new_player)
  def join(game, player) do
    {deck, player} = Deck.deal(game.deck, player)

    game = %{game |
      players: game.players ++ [player],
      deck: deck
    } |> update

    {game, player}
  end

  def prepare_player(token, attrs) do
    {game, player} = find_game_and_player(token) # easier to find again instead of trying to hold state all the time
    cards_to_swich = player.hand ++ player.upcards
    upcards = Enum.reduce(attrs[:hand], cards_to_swich, fn (x, acc) -> List.delete(acc, x) end)

    if length(upcards) != 3 do
      {:error, "Player must select from upcards and hand"}
    else
      player = %{player | hand: attrs[:hand], upcards: upcards, status: "ready"}
      game = %{game | players: Player.update_list(game.players, player)} |> update
      {game, player}
    end
  end

  defp update(game) do
    Store.update(game)
  end
end
