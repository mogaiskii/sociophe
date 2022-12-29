defmodule Sociophe.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sociophe.Accounts.User

  schema "messages" do
    field :text, :string

    belongs_to :sender, User
    belongs_to :receiver, User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :sender_id, :receiver_id])
    |> validate_required([:text, :sender_id, :receiver_id])
  end
end
