defmodule Mw.ContentType do
  import Plug.Conn
  def init([]), do: false
  def call(conn, _opts), do: conn |> put_resp_content_type("application/json")
end
