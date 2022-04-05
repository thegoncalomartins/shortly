defmodule Shortly.Repositories.UrlRepository do
  alias Shortly.Models.Url
  alias Shortly.Utils.Utils

  def find_one(id) do
    case Redix.command(:redix, ["HGETALL", "urls::#{id}"]) do
      {:ok, []} ->
        {:ok, nil}

      {:ok, result} ->
        {:ok, Url.from_map(Map.put(Utils.array_to_map(result), "id", id))}

      {:error, error} ->
        {:error, error}
    end
  end

  def save(%Url{id: id, url: url, hits: hits, created_at: created_at, updated_at: updated_at}) do
    case Redix.transaction_pipeline(:redix, [
           [
             "HSET",
             "urls::#{id}",
             "url",
             url,
             "hits",
             hits |> to_string(),
             "created_at",
             created_at |> to_string(),
             "updated_at",
             updated_at |> to_string()
           ],
           ["HGETALL", "urls::#{id}"]
         ]) do
      {:ok, [_, result]} ->
        {:ok, Url.from_map(Map.put(Utils.array_to_map(result), "id", id))}

      {:error, error} ->
        {:error, error}
    end
  end

  def increment_hits_and_get(id) do
    case Redix.transaction_pipeline(:redix, [
           ["HINCRBY", "urls::#{id}", "hits", "1"],
           [
             "HSET",
             "urls::#{id}",
             "updated_at",
             DateTime.to_iso8601(DateTime.utc_now(), :extended) |> to_string()
           ],
           ["HGETALL", "urls::#{id}"]
         ]) do
      {:ok, [_, _, result]} ->
        {:ok, Url.from_map(Map.put(Utils.array_to_map(result), "id", id))}

      {:error, error} ->
        {:error, error}
    end
  end
end
