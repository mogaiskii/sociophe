defmodule Sociophe.MessagingTest do
  use Sociophe.DataCase

  alias Sociophe.Messaging

  describe "messages" do
    alias Sociophe.Messaging.Message

    import Sociophe.MessagingFixtures
    import Sociophe.AccountsFixtures

    @invalid_attrs %{text: nil}

    test "list_messages/1 returns all messages" do
      message = message_fixture()
      assert Messaging.list_messages(message.sender_id) == [message]
      assert Messaging.list_messages(message.receiver_id) == [message]
    end

    test "list_dialogue_messages/2 returns related messages" do
      message = message_fixture()
      assert Messaging.list_dialogue_messages(message.sender_id, message.receiver_id) == [message]
      assert Messaging.list_dialogue_messages(message.receiver_id, message.sender_id) == [message]
    end

    test "list_dialogues/1 returns related dialogues" do
      user = user_fixture()
      corr_1 = user_fixture()
      corr_2 = user_fixture()
      message_1 = message_fixture(%{sender_id: user.id, receiver_id: corr_1.id})
      message_2 = message_fixture(%{receiver_id: user.id, sender_id: corr_2.id})
      message_3 = message_fixture(%{sender_id: corr_2.id, receiver_id: corr_1.id})

      dialogues = Messaging.list_dialogues(user.id)
      assert Enum.any?(dialogues, fn x -> x.id == message_1.id end)
      assert Enum.any?(dialogues, fn x -> x.id == message_2.id end)
      refute Enum.any?(dialogues, fn x -> x.id == message_3.id end)
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      sender = user_fixture()
      receiver = user_fixture()
      valid_attrs = %{text: "some text", sender_id: sender.id, receiver_id: receiver.id}

      assert {:ok, %Message{} = message} = Messaging.create_message(valid_attrs)
      assert message.text == "some text"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{text: "some updated text"}

      assert {:ok, %Message{} = message} = Messaging.update_message(message, update_attrs)
      assert message.text == "some updated text"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(message, @invalid_attrs)
      assert message == Messaging.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messaging.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messaging.change_message(message)
    end
  end
end
