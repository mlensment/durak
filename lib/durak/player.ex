defmodule Durak.Player do
  import Util.MapHelper
  alias __MODULE__

  defstruct id: nil, name: nil

  def create(attrs) do
    attrs = [id: SecureRandom.uuid] ++ attrs
    attrs |> attrs_to_struct(Player)
  end
end
