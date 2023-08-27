defmodule EmployeeManagementSystemWeb.EventLive.Index do
  use EmployeeManagementSystemWeb, :live_view

  alias EmployeeManagementSystem.Events
  alias EmployeeManagementSystem.Events.Event
  alias EmployeeManagementSystem.Users

  @impl true
  def mount(_params, session, socket) do
    user = Users.get_user_by_session_token(session["user_token"])
    today = Timex.today()

    {_ok, todays_date} = Timex.format(today, "{YYYY}-{M}-{D}")

    todays_date =
      todays_date
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.map_join("", &Integer.to_string(&1))
      |> String.to_integer()

    {:ok,
     socket
     |> assign(:page_title, "Listing Events")
     |> assign(:todays_date, todays_date)
     |> assign(:current_user, user)
     |> assign(:events, Events.list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  defp list_events do
    Events.list_events()
  end
end
