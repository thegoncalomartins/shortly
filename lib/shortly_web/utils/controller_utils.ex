defmodule ShortlyWeb.Utils.ControllerUtils do
  def remote_ip(conn) do
    conn.remote_ip |> :inet_parse.ntoa() |> to_string()
  end
end
