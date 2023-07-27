defmodule EmployeeManagementSystemWeb.UserRegistrationController do
  use EmployeeManagementSystemWeb, :controller

  alias EmployeeManagementSystem.Users
  alias EmployeeManagementSystem.Users.User
  alias EmployeeManagementSystemWeb.UserAuth

  def new(conn, _params) do
    changeset = Users.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    if user_params["email"] != "admin@gmail.com" do
      IO.inspect(user_params)

      case Users.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Users.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :edit, &1)
            )

          conn
          |> put_flash(:info, "User created successfully.")
          |> UserAuth.log_in_user(user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      new_user_params = Map.put(user_params, "role", "manager")

      case Users.register_user(new_user_params) do
        {:ok, user} ->
          {:ok, _} =
            Users.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :edit, &1)
            )

          conn
          |> put_flash(:info, "User created successfully.")
          |> UserAuth.log_in_user(user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end
end
