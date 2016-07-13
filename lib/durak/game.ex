defmodule Durak.Game do
  import Plug.Conn
  alias Durak.Store
  alias __MODULE__

  @waiting "waiting"
  @started "started"
  defstruct status: @waiting, id: nil

  def find_or_create do
    game = Store.get_by(status: @waiting)

    unless game do
      game = Store.set(%Game{id: :rand.uniform(50)})
    end

    game
  end

  def start(game) do
    Store.update(%{game | status: @started})
  end

  # def render(conn, controller, action) do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "TODO: Query the database for data about #{action}.")
  # end
end
