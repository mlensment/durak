defmodule GameTest do
  use ExUnit.Case
  alias Durak.Game
  doctest Durak.Game

  test "finding or creating the game" do
    game_1 = Game.find_or_create
    game_2 = Game.find_or_create
    assert game_1 != nil
    assert game_1.__struct__ == Game
    assert game_1 == game_2
  end

  test "starting the game" do
    game_1 = Game.find_or_create
    game_1 = Game.start(game_1)
    assert game_1.status == "started"

    game_2 = Game.find_or_create
    assert game_2.status == "waiting"
  end
end
