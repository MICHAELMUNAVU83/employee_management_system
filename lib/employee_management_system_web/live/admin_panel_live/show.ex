defmodule EmployeeManagementSystemWeb.AdminPanelLive.Show do
  use EmployeeManagementSystemWeb, :live_view

  alias EmployeeManagementSystem.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:users, Users.list_users())
     |> assign(:user, Users.get_user!(id))}
  end

  def handle_event("promote_to_manager", %{"id" => id}, socket) do
    IO.inspect("promote_to_manager")
    user = Users.get_user!(id)

    {:ok, user} = Users.update_user(user, %{role: "manager"})
    IO.inspect(user)

    {:noreply,
     socket
     |> assign(:user, user)
     |> put_flash(:info, "User promoted to manager successfully")}
  end

  defp page_title(:show), do: "Show User"
end
