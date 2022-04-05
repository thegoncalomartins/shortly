defmodule Shortly.Services.UrlService do
  alias Shortly.Models.Url
  alias Shortly.Repositories.UrlRepository

  def create(url = %Url{}) do
    case UrlRepository.find_one(url.id) do
      {:ok, nil} ->
        UrlRepository.save(url)

      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error, error}
    end
  end

  def increment_hits_and_get(id) do
    case UrlRepository.find_one(id) do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, _} ->
        UrlRepository.increment_hits_and_get(id)

      {:error, error} ->
        {:error, error}
    end
  end
end
