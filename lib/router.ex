defmodule Router do
  use Plug.Router
  alias Durak.Game

  if Mix.env == :dev do
    use Plug.Debugger
  end

  plug Mw.ContentType
  plug :match
  plug :dispatch

  # Root path
  get "/" do
    game = Game.find_or_create_game
    conn |> send_resp(200, Poison.encode!(game))
  end

  get "/about/:name" when name == "history" do
    send_resp(conn, 200, "Our website has a short, yet colorful history.")
  end

  # Use a variable in the route
  get "/about/:name" do
    send_resp(conn, 200, "#{name} is vital to our website's continued success.")
  end

  get "/about/*glob" do
    [thing, place] = glob
    send_resp(conn, 200, "Yes, we do have #{thing} over there by #{String.capitalize(place)}.")
  end

  get "/json/:name" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{name: name}))
  end

  def respond conn, code, struct do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(struct))
  end

  def set_content_type(conn, _opts) do
    put_resp_content_type(conn, "application/json")
  end
end
