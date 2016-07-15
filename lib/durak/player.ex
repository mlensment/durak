defmodule Durak.Player do
  alias __MODULE__

  defstruct id: nil, name: nil

  def create(attrs) do
    attrs = [id: SecureRandom.uuid] ++ attrs
    attrs |> Util.MapHelper.attrs_to_struct(Player)
  end
end
