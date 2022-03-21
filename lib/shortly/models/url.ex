defmodule Shortly.Models.Url do
  @derive Jason.Encoder
  defstruct [
    :id,
    :url,
    hits: 0
  ]

  def from_map(map) do
    opts = for {key, val} <- map, into: %{} do
      {String.to_existing_atom(key), val}
    end

   struct(Shortly.Models.Url, opts)
  end

  @type id :: String.t()
  @type url :: String.t()
  @type hits :: Integer.t()

  @type t :: %__MODULE__{
    id: id,
    url: url,
    hits: hits
        }
end
