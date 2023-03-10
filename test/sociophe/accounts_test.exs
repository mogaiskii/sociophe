defmodule Sociophe.AccountsTest do
  use Sociophe.DataCase

  alias Sociophe.Accounts

  import Sociophe.AccountsFixtures
  alias Sociophe.Accounts.{User, UserToken}

  describe "get_user_by_login/1" do
    test "does not return the user if the login does not exist" do
      refute Accounts.get_user_by_login("unknown@example.com")
    end

    test "returns the user if the login exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_login(user.login)
    end
  end

  describe "search_users_by_login/1" do
    test "does not return any users if the login does not match any" do
      assert length(Accounts.search_users_by_login("unknown")) == 0
    end

    test "returns list of users if the login matches anything" do
      user = user_fixture()
      part_of_login = common_user_prefix()
      accounts = Accounts.search_users_by_login(part_of_login)
      assert Enum.member?(accounts, user)
    end

    test "returns only matching users" do
      user = user_fixture()
      user2 = user_fixture()
      accounts = Accounts.search_users_by_login(user.login)
      assert Enum.member?(accounts, user)
      refute Enum.member?(accounts, user2)
    end
  end

  describe "get_user_by_login_and_password/2" do
    test "does not return the user if the login does not exist" do
      refute Accounts.get_user_by_login_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_login_and_password(user.login, "invalid")
    end

    test "returns the user if the login and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_login_and_password(user.login, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires login and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               login: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates maximum values for login and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{login: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).login
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates login uniqueness" do
      %{login: login} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{login: login})
      assert "has already been taken" in errors_on(changeset).login

      # Now try with the upper cased login too, to check that login case is ignored.
      {:error, changeset} = Accounts.register_user(%{login: String.upcase(login)})
      assert "has already been taken" in errors_on(changeset).login
    end

    test "registers users with a hashed password" do
      login = unique_user_login()
      {:ok, user} = Accounts.register_user(valid_user_attributes(login: login))
      assert user.login == login
      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :login]
    end

    test "allows fields to be set" do
      login = unique_user_login()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(login: login, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :login) == login
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_login_and_password(user.login, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
