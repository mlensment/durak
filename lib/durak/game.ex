defmodule Durak.Game do
  import Plug.Conn
  alias Durak.Store
  alias Durak.Deck
  alias __MODULE__

  @waiting "waiting"
  @started "started"
  defstruct status: @waiting, id: nil, in_turn: nil, deck: [], players: []

  def find_or_create do
    game = Store.get_by(status: @waiting)

    unless game do
      game = %Game{id: SecureRandom.uuid, deck: Deck.prepare} |> Store.set
    end

    game
  end

  def start(game) do
    player_count = length(game.players)
    if player_count > 1 && player_count < 6 do
      %{game | status: @started, in_turn: List.first(game.players) } |> update
    else
      {:error, "Amount of players must be between 2 and 5"}
    end
  end

  def join(game, player) do
    {deck, player} = Deck.deal(game.deck, player)

    game = %{game |
      players: game.players ++ [player],
      deck: deck
    }

    update(game)

    if length(game.players) == 5 do
      game = game |> start
    end

    game
  end

  defp update(game) do
    Store.update(game)
  end

  # def render(conn, controller, action) do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "TODO: Query the database for data about #{action}.")
  # end
end
