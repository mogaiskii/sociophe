defmodule Sociophe.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :text, :string
    field :sender_id, :id
    field :receiver_id, :id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :sender_id, :receiver_id])
    |> validate_required([:text, :sender_id, :receiver_id])
  end
end
