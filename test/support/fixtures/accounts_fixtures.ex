defmodule Sociophe.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sociophe.Accounts` context.
  """
  @users_prefix "user"

  def common_user_prefix, do: @users_prefix

  def unique_user_login, do: "#{@users_prefix}#{System.unique_integer()}"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      login: unique_user_login(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Sociophe.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_login} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_login.text_body, "[TOKEN]")
    token
  end
end
