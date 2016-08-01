defmodule GameTest do
  use ExUnit.Case
  alias Durak.Game
  alias Durak.Player
  alias Durak.Store
  doctest Durak.Game

  setup context do
    Store.clear
    before(context)
  end

  defp before(%{with_started_game: true}) do
    game = Game.find_or_create

    {game, player} =
      game |>
      Game.join(Player.create(name: "Player 1")) |>
      Game.join(Player.create(name: "Player 2"))

    Enum.each(game.players, fn x -> Game.prepare_player(x.token, hand: x.upcards) end)

    {game, _player} = Game.find_game_and_player(player.token)
    game = Game.start(game)

    {:ok, game: game}
  end

  defp before(_) do
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
      hd(game.players)

    assert name == "Player 1"
    assert status == "preparing"
    assert length(hand) == 3
    assert length(upcards) == 3
    assert length(downcards) == 3

    players = for n <- 2..5, do: Player.create(name: "Player #{n}")

    {game, _player} =
      players |>
      Enum.reduce(game, fn(x, acc) -> Game.join(acc, x) end)

    assert length(game.players) == 5

    # should not allow more than 5 players into one game
    game_2 = Game.find_or_create
    assert game != game_2
  end

  test "preparing a player", state do
    player = Player.create(name: "Player 1")
    {_game, player} = state[:game] |> Game.join(player)
    hand = player.hand
    upcards = player.upcards
    downcards = player.downcards

    # try to cheat by selecting one of the downcards
    cheating = [hd(downcards)] ++ [hd(upcards)] ++ [hd(hand)]
    {:error, reason} = Game.prepare_player(player.token, hand: cheating)

    assert reason == "Player must select from upcards and hand"

    # switch upcards and downcards
    {_game, player} = Game.prepare_player(player.token, hand: player.upcards)
    assert player.hand == upcards
    assert player.upcards == hand
    assert player.status == "ready"
  end

  test "starting the game", state do
    {:error, reason} = Game.start(state[:game])
    assert reason == "Amount of players must be between 2 and 5"

    {game, player} =
      state[:game] |>
      Game.join(Player.create(name: "Player 1")) |>
      Game.join(Player.create(name: "Player 2"))

    {:error, reason} = Game.start(game)
    assert reason == "All players must be ready to start the game"

    Enum.each(game.players, fn x -> Game.prepare_player(x.token, hand: x.upcards) end)

    {game, _player} = Game.find_game_and_player(player.token)
    game = Game.start(game)
    assert game.status == "started"
    game_2 = Game.find_or_create
    assert game_2.status == "waiting"

    assert game.in_turn == List.first(game.players)
    assert length(game.deck) == 37
  end

  @tag with_started_game: true
  test "making the first move", state do
    assert state[:game].status == "started"
    assert state[:game].in_turn == hd(state[:game].players)

    first_player = state[:game].in_turn
    second_player = List.last(state[:game].players)

    {:error, reason} = Game.move(second_player.token, [hd(second_player.hand)])
    assert reason == "It's not your turn"

    {:error, reason} = Game.move(first_player.token, [hd(second_player.hand)])
    assert reason == "Player must select cards from hand"

    # {game, player} = Game.move(first_player.token, [hd(first_player.hand)])
    # assert game.pile == [hd(first_player.hand)]
    # assert length(player.hand) == 3
  end
end
