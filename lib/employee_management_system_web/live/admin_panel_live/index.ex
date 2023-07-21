defmodule EmployeeManagementSystemWeb.AdminPanelLive.Index do
  use EmployeeManagementSystemWeb, :live_view

  alias EmployeeManagementSystem.Users

  def mount(_params, session, socket) do
    current_user = Users.get_user_by_session_token(session["user_token"])

    user = Users.get_user!(current_user.id)
    IO.inspect(user)

    # case Users.update_user(user, %{first_name: "John"}) do
    #   {:ok, user} ->
    #     IO.inspect("User updated successfully")

    #     {:ok,
    #      socket
    #      |> assign(:page_title, "Listing Users")
    #      |> assign(:current_user, user)}

    #   {:error, _changeset} ->
    #     IO.inspect("User not updated successfully")
    #     {:error, %{reason: "User not found"}}
    # end

    {:ok,
     socket
     |> assign(:page_title, "Listing Events")
     |> assign(:users, Users.list_users())
     |> assign(:current_user, user)}
  end
end
