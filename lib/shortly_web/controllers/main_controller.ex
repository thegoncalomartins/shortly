defmodule ShortlyWeb.Controllers.MainController do
  use ShortlyWeb, :controller
  alias ShortlyWeb.Utils
  alias Shortly.Models.Url
  alias Shortly.Services.UrlService

  def create(conn, %{"url" => url}) do
    remote_ip = conn |> Utils.ControllerUtils.remote_ip()
    rate_limit = 3
    rate_scale_ms = 60_000

    case Hammer.check_rate("create:#{remote_ip}", rate_scale_ms, rate_limit) do
      {:allow, count} ->
        # shorten
        id =
          UUID.uuid5(:url, url, :hex)
          |> String.slice(0..6)

        case UrlService.create(%Url{id: id, url: url}) do
          {:ok, result} ->
            conn
            |> put_status(:created)
            |> put_resp_header("x-ratelimit-remaining", (rate_limit - count) |> to_string())
            |> put_resp_header("x-ratelimit-limit", rate_limit |> to_string())
            |> json(result)

          {:error, error} ->
            conn
            |> put_status(:internal_server_error)
            |> put_resp_header("x-ratelimit-remaining", (rate_limit - count) |> to_string())
            |> put_resp_header("x-ratelimit-limit", rate_limit |> to_string())
            |> json(%{"error" => error})
        end

      {:deny, limit} ->
        # too many requests
        conn
        |> put_status(:too_many_requests)
        |> put_resp_header("x-ratelimit-remaining", "0")
        |> put_resp_header("x-ratelimit-limit", limit |> to_string())
        |> json(%{"error" => "Too many requests"})
    end
  end

  def show(conn, %{"id" => id, "redirect" => "true"}) do
    conn |> redirect_to(id)
  end

  def show(conn, %{"id" => id, "redirect" => "false"}) do
    conn |> find(id)
  end

  def show(conn, %{"id" => id, "redirect" => ""}) do
    conn |> redirect_to(id)
  end

  def show(conn, %{"id" => id}) do
    conn |> find(id)
  end

  defp redirect_to(conn, id) do
    case UrlService.increment_hits_and_get(id) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> json(%{"error" => "URL with '#{id}' not found"})

      {:ok, url} ->
        conn |> redirect(external: url.url)

      {:error, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"error" => error})
    end
  end

  defp find(conn, id) do
    case UrlService.find_one(id) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> json(%{"error" => "URL with '#{id}' not found"})

      {:ok, url} ->
        conn |> json(url)

      {:error, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"error" => error})
    end
  end
end
