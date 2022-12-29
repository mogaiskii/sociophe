defmodule Sociophe.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias Sociophe.Repo

  alias Sociophe.Messaging.Message

  @doc """
  Returns the list of messages related to the given user.

  ## Examples

      iex> list_messages(123)
      [%Message{}, ...]

  """
  def list_messages(user_id) do
    query = from m in Message,
              where: m.sender_id == ^user_id,
              or_where: m.receiver_id == ^user_id,
              order_by: [desc: m.inserted_at]
    Repo.all(query)
  end

  def list_dialogues(user_id) do
    # select users.id, users.login
    # from users inner join messages on messages.sender_id = users.id or messages.receiver_id = users.id
    # where messages.sender_id = ^user_id or messages.receiver_id = ^user_id

    # with dialogues as (
    #    select users.id, users.login
    #    from users inner join messages on messages.sender_id = users.id or messages.receiver_id = users.id
    #    where messages.sender_id = ^user_id or messages.receiver_id = ^user_id
    # ),
    # messages as (
    #    select messages.text from messages
    #    where messages.receiver_id = dialogues.id and messages.sender_id = ^user_id
    #    or messages.sender_id = dialogues.id and messages.receiver_id = ^user_id
    #    order by inserted at desc
    #    limit 1
    # )
  end

  @doc """
  Returns the list of messages related to the communication between given users.

  ## Examples

      iex> list_dialogue_messages(123, 456)
      [%Message{}, ...]

  """
  def list_dialogue_messages(user_id, correspondent_user_id) do
    query = from m in Message,
              where: m.sender_id == ^user_id and m.receiver_id == ^correspondent_user_id,
              or_where: m.receiver_id == ^user_id and m.sender_id == ^correspondent_user_id,
              order_by: m.inserted_at
    Repo.all(query)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
