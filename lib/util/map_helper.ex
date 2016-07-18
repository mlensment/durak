defmodule Util.MapHelper do
  def attrs_to_struct(attrs, type) do
    attrs |> attrs_to_map |> map_to_struct(type)
  end

  def attrs_to_map(attrs) do
    Enum.into(attrs, %{})
  end

  def struct_to_map(struct) do
    map = Map.delete(struct, :__struct__)
  end

  def map_to_struct(map = %{}, type), do: struct(type, map)
  def map_to_struct(nil, type), do: nil

  def map_contains?(supermap, submap) do
    # Convert the submap into a list of key-value pairs where each key
    # is a list representing the keypath of its corresponding value.
    # IO.inspect flatten_with_list_keys(submap)
    flatten_with_list_keys(submap)
    # Check that every keypath has the same value in both maps
    # (assumes that `nil` is not a legitimate value)
    |> Enum.all?(fn
      {keypath, val} when is_list(val) ->
        attrs = Enum.at(val, 0)
        get_in(supermap, keypath) |> Enum.any?(&map_contains?(&1, attrs))
      {keypath, val} when val != nil ->
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
