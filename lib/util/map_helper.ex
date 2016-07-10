defmodule Util.MapHelper do
  def contains?(supermap, submap) do
    # Convert the submap into a list of key-value pairs where each key
    # is a list representing the keypath of its corresponding value.
    flatten_with_list_keys(submap)
    # Check that every keypath has the same value in both maps
    # (assumes that `nil` is not a legitimate value)
    |> Enum.all?(fn {keypath, val} when val != nil ->
      get_in(supermap, keypath) == val
    end)
  end

  defp flatten_with_list_keys(map) do
    Enum.flat_map(map, fn
      {key, map} when is_map(map) ->
        for {subkey, val} <- flatten_with_list_keys(map), do: {[key | subkey], val}
      {key, val} ->
        [{[key], val}]
    end)
  end
end
