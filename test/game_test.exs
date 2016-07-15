defmodule GameTest do
  doctest Durak.Game
  use ExUnit.Case
  alias Durak.Game
  alias Durak.Player
  alias Durak.Store

  setup do
    Store.clear
    {:ok, game: Game.find_or_create}
  end

  test "finding or creating the game", state do
    game_2 = Game.find_or_create
    assert state[:game] != nil
    assert state[:game].__struct__ == Game
    assert state[:game] == game_2
  end

  test "joining the game", state do
    player = Player.create(name: "Player 1")
    game = state[:game] |> Game.join(player)
    assert game.players == [player]
  end

  test "starting the game", state do
    game_1 = Game.start(state[:game])
    assert game_1.status == "started"

    game_2 = Game.find_or_create
    assert game_2.status == "waiting"
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