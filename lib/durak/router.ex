defmodule Durak.Router do
  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger
  end

  plug Mw.ContentType
  plug :match
  plug :dispatch

  # Root path
  get "/" do
    # game = Durak.Game.find_or_create_game
    # game_id = game...
    # player_count = game...
    conn |> send_resp(200, Poison.encode!(%{game_id: 123, player_count: 0}))
  end
end
