defmodule SociopheWeb.UserSearchControllerTest do
  use SociopheWeb.ConnCase, async: true
  setup :register_and_log_in_user

  describe "GET /users/search" do
    test "renders search page", %{conn: conn} do
      conn = get(conn, Routes.user_search_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "<h1>Search</h1>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_search_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "searches for users", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_search_path(conn, :index, login: user.login))
      response = html_response(conn, 200)
      assert response =~ user.login <> "</a>"
      assert response =~ user.login <> "\""
    end
  end

  describe "GET /users/:login" do
    test "renders user page", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_search_path(conn, :show, user.login))
      response = html_response(conn, 200)
      assert response =~ user.login <> "</h1>"
    end

    test "raises not found on unknown login", %{conn: conn} do
      conn = get(conn, Routes.user_search_path(conn, :show, "unknown"))
      html_response(conn, 404)
    end
  end
end
