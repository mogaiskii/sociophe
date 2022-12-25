defmodule SociopheWeb.HelloController do
  use SociopheWeb, :controller

  def index(conn, _params) do
    data = %{title: "here it comes"}

    render(conn, "index.json", data: data)
  end

end
