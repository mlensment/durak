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

  test "joining the game", state do
    player = Player.create(name: "Player 1")
    game = state[:game] |> Game.join(player)
    assert length(game.players) == 1

    %{name: name} = Enum.at(game.players, 0)
    assert name == "Player 1"
  end

  test "starting the game", state do
    {:error, reason} = Game.start(state[:game])
    assert reason == "Amount of players must be between 2 and 5"

    game =
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
    game =
      players |>
      Enum.reduce(state[:game], fn(x, game) -> Game.join(game, x) end)

    assert length(game.players) == 4
    assert game.status == "waiting"

    game_2 = Game.find_or_create
    assert game == game_2

    # when we have 5 players, game should start automatically
    game = game |> Game.join(Player.create(name: "Player 5"))
    assert length(game.players) == 5
    assert game.status == "started"

    game_2 = Game.find_or_create
    assert game != game_2
  end
end
