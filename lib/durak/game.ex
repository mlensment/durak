defmodule Durak.Game do
  import Plug.Conn
  alias Durak.Store
  alias __MODULE__

  @waiting "waiting"
  defstruct status: @waiting, game_id: nil

  def find_or_create_game do
    game = Store.get_by(status: @waiting)

    unless game do
      game = %Game{game_id: :rand.uniform(50)}
      Store.set(game)
    end

    game
  end

  # def render(conn, controller, action) do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "TODO: Query the database for data about #{action}.")
  # end
end
