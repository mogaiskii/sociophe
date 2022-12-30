defmodule SociopheWeb.MessageView do
  use SociopheWeb, :view

  def correspondent(message, user) do
    cond do
      message.sender == user ->
        message.receiver
      true ->
        message.sender
    end
  end

end
