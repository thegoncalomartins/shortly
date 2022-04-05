defmodule Shortly.Models.Url do
  @derive Jason.Encoder
  defstruct [
    :id,
    :url,
    hits: 0,
    created_at: DateTime.to_iso8601(DateTime.utc_now(), :extended),
    updated_at: DateTime.to_iso8601(DateTime.utc_now(), :extended)
  ]

  def from_map(map) do
    opts =
      for {key, val} <- map, into: %{} do
        {String.to_existing_atom(key), val}
      end

    struct(Shortly.Models.Url, opts)
  end

  @type id :: String.t()
  @type url :: String.t()
  @type hits :: Integer.t()
  @type created_at :: String.t()
  @type updated_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          url: url,
          hits: hits,
          created_at: created_at,
          updated_at: updated_at
        }

  @spec build(%{
          optional(:id) => id,
          required(:url) => url,
          optional(:hits) => hits,
          optional(:created_at) => created_at,
          optional(:updated_at) => updated_at
        }) :: t

  def build(
        %{
          url: url
        } = params
      ) do
    %__MODULE__{
      id:
        Map.get(params, :id) ||
          UUID.uuid5(:url, url, :hex) |> ShortUUID.encode!() |> String.slice(0..8),
      url: url,
      hits: Map.get(params, :hits) || 0,
      created_at:
        Map.get(params, :created_at) || DateTime.to_iso8601(DateTime.utc_now(), :extended),
      updated_at:
        Map.get(params, :updated_at) || DateTime.to_iso8601(DateTime.utc_now(), :extended)
    }
  end
end
