defmodule GameTest do
  use ExUnit.Case
  alias Durak.Game
  alias Durak.Player
  alias Durak.Store
  doctest Durak.Game

  setup do
    Store.clear
    {:ok, game: Game.find_or_create}
  end

  test "finding or creating the game", state do
    game_2 = Game.find_or_create
    assert state[:game] != nil
    assert state[:game].__struct__ == Game
    assert state[:game] == game_2

    assert length(state[:game].deck) == 55
  end

  test "finding a game by nested attributes", state do
    game = Game.find_by(players: [%{name: "Player 1"}])
    assert game == nil

    player = Player.create(name: "Player 1")
    {game, _player} = state[:game] |> Game.join(player)
    game_from_store = Game.find_by(players: [%{name: "Player 1"}])
    assert game == game_from_store
  end

  test "joining the game", state do
    player = Player.create(name: "Player 1")
    {game, _player} = state[:game] |> Game.join(player)
    assert length(game.players) == 1

    %{name: name, hand: hand, upcards: upcards, downcards: downcards, status: status} =
      Enum.at(game.players, 0)

    assert name == "Player 1"
    assert status == "preparing"
    assert length(hand) == 3
    assert length(upcards) == 3
    assert length(downcards) == 3
  end

  test "preparing a player", state do
    player = Player.create(name: "Player 1")
    {game, player} = state[:game] |> Game.join(player)
    hand = player.hand
    upcards = player.upcards
    downcards = player.downcards

    # try to cheat by selecting one of the downcards
    cheating = [Enum.at(downcards, 0)] ++ [Enum.at(upcards, 0)] ++ [Enum.at(hand, 0)]
    {:error, reason} = Game.prepare_player(game, player, hand: cheating)

    assert reason == "Player must select from upcards and hand"

    # switch upcards and downcards
    {_game, player} = Game.prepare_player(game, player, hand: player.upcards)
    assert player.hand == upcards
    assert player.upcards == hand
    assert player.status == "ready"
  end

  test "starting the game", state do
    {:error, reason} = Game.start(state[:game])
    assert reason == "Amount of players must be between 2 and 5"

    {game, _player} =
      state[:game] |>
      Game.join(Player.create(name: "Player 1")) |>
      Game.join(Player.create(name: "Player 2"))

    game = Game.start(game)
    assert game.status == "started"
    game_2 = Game.find_or_create
    assert game_2.status == "waiting"

    assert game.in_turn == List.first(game.players)
    assert length(game.deck) == 37
  end

  test "automatically starting the game", state do
    players = for n <- 1..4, do: Player.create(name: "Player #{n}")
    {game, _player} =
      players |>
      Enum.reduce(state[:game], fn(x, acc) -> Game.join(acc, x) end)

    assert length(game.players) == 4
    assert game.status == "waiting"

    game_2 = Game.find_or_create
    assert game == game_2

    # when we have 5 players, game should start automatically
    {game, _player} = game |> Game.join(Player.create(name: "Player 5"))
    assert length(game.players) == 5
    assert game.status == "started"

    game_2 = Game.find_or_create
    assert game != game_2
  end
end
