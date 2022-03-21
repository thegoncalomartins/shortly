defmodule Shortly.Utils.Utils do
  def array_to_map(array) do
    array
    |> Enum.chunk_every(2)
    |> Map.new(fn [k, v] -> {k, v} end)
  end
end
