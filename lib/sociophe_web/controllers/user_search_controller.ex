defmodule SociopheWeb.UserSearchController do
  use SociopheWeb, :controller

  alias Sociophe.Accounts

  def index(conn, %{"login" => login}) do
    render(conn, "index.html", users: Accounts.search_users_by_login(login))
  end
  def index(conn, _) do
    render(conn, "index.html", users: nil)
  end

  def show(conn, %{"login" => login}) do
    case Accounts.get_user_by_login(login) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.put_view(SociopheWeb.ErrorView)
        |> Phoenix.Controller.render(:"404")
        |> halt()
      user ->
        render(conn, "show.html", user: user)
    end

  end
end
