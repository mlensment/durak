defmodule Durak.Deck do
  alias __MODULE__

  def prepare do
    deck = for suit <- ~w(H C D S),
      face <- [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"],
      do: "#{suit}#{face}"

    deck = deck ++ ["J", "J", "J"] # 3 jokers
    Enum.shuffle(deck)
  end

  def deal(deck, player) do
    card_to_give = Enum.take(deck, 9) |> Enum.chunk(3)
    remaining_deck = Enum.drop(deck, 9)

    player = %{player |
      downcards: Enum.at(card_to_give, 0),
      upcards: Enum.at(card_to_give, 1),
      hand: Enum.at(card_to_give, 2)
    }

    {remaining_deck, player}
  end
end
