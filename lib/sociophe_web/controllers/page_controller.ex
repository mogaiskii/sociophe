defmodule SociopheWeb.PageController do
  use SociopheWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
