defmodule ShortlyWeb.MainController do
  use ShortlyWeb, :controller

  def create(conn, %{"url" => url}) do
    hash =
      UUID.uuid5(:url, url, :hex)
      |> String.slice(0..6)

    case Redix.command(:redix, ["SET", hash, url]) do
      {:ok, _} ->
        conn
        |> put_status(:created)
        |> json(%{
          "hash" => hash
        })

      {:error, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"error" => error})
    end
  end

  def show(conn, %{"hash" => hash}) do
    case Redix.command(:redix, ["GET", hash]) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> json(%{"error" => "'#{hash}' not found"})

      {:ok, url} ->
        conn
        |> redirect(external: url)

      {:error, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"error" => error})
    end
  end
end
