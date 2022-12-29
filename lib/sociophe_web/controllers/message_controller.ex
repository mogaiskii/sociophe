defmodule SociopheWeb.MessageController do
  use SociopheWeb, :controller

  alias Sociophe.{Messaging, Accounts}
  alias Sociophe.Messaging.Message

  def index(conn, _params) do
    user = conn.assigns.current_user
    messages = Messaging.list_messages(user.id)
    render(conn, "index.html", messages: messages)
  end

  def create(conn, %{"message" => %{"text" => text}, "login" => login}) do
    {user, corresponding_user} = get_users_pair(conn, login)
    message_params = %{text: text, sender_id: user.id, receiver_id: corresponding_user.id}
    case Messaging.create_message(message_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Message created successfully.")
        |> redirect(to: Routes.message_path(conn, :show, corresponding_user.login))

      {:error, _} ->
        conn
        |> put_flash(:info, "Message wasn't sent.")
        |> redirect(to: Routes.message_path(conn, :show, corresponding_user.login))
    end
  end

  def show(conn, %{"login" => login}) do
    {user, corresponding_user} = get_users_pair(conn, login)
    messages = Messaging.list_dialogue_messages(user.id, corresponding_user.id)
    render(
      conn,
      "show.html",
      messages: messages,
      user: user,
      correspondent: corresponding_user,
      changeset: Messaging.change_message(%Message{})
    )
  end

  defp get_users_pair(conn, login) do
    user = conn.assigns.current_user
    case Accounts.get_user_by_login(login) do
      nil ->
        not_found(conn)
      corresponding_user ->
        {user, corresponding_user}
    end
  end

end
