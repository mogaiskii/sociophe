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
        not_found(conn)
      user ->
        render(conn, "show.html", user: user)
    end

  end
end
