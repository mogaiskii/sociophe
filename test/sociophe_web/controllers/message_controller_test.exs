defmodule SociopheWeb.MessageControllerTest do
  use SociopheWeb.ConnCase

  import Sociophe.AccountsFixtures

  setup :register_and_log_in_user

  describe "index" do
    test "lists all messages", %{conn: conn} do
      conn = get(conn, Routes.message_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Messages"
    end
  end

  describe "create message" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      second_user = user_fixture()
      message_attrs = %{text: "Message Text", sender_id: user.id, receiver_id: second_user.id}

      conn = post(conn, Routes.message_path(conn, :create, second_user.login), message: message_attrs)

      assert redirected_to(conn) == Routes.message_path(conn, :show, second_user.login)

      conn = get(conn, Routes.message_path(conn, :show, second_user.login))
      assert html_response(conn, 200) =~ "Message Text"
    end
  end
end
