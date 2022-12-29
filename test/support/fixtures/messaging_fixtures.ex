defmodule Sociophe.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sociophe.Messaging` context.
  """

  import Sociophe.AccountsFixtures

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    sender = user_fixture()
    receiver = user_fixture()
    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text",
        sender_id: sender.id,
        receiver_id: receiver.id
      })
      |> Sociophe.Messaging.create_message()

    message
  end
end
