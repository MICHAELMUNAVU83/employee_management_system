defmodule EmployeeManagementSystemWeb.ChatShowLive.Index do
  use EmployeeManagementSystemWeb, :live_view

  alias EmployeeManagementSystem.Users
  alias EmployeeManagementSystem.Messages
  alias EmployeeManagementSystem.Messages.Message

  alias EmployeeManagementSystem.Groups
  alias EmployeeManagementSystem.Groups.Group

  def mount(params, session, socket) do
    changeset = Messages.change_message(%Message{})
    user = Users.get_user_by_session_token(session["user_token"])
    search_changeset = Messages.change_message(%Message{})

    image_changeset = Messages.change_message(%Message{})

    first_4_users =
      Users.list_users_except_current_user(user.id)
      |> Enum.take(4)
      |> Enum.filter(fn user -> user.email != "admin@gmail.com" end)

    users =
      Users.list_users_except_current_user(user.id)
      |> Enum.filter(fn user -> user.email != "admin@gmail.com" end)

    receiver_id = String.to_integer(params["id"])

    messages = Messages.list_messages_for_a_receiver_and_sender(user.id, receiver_id)

    if connected?(socket) do
      Messages.subcribe()

      {:ok,
       socket
       |> assign(:message, %Message{})
       |> assign(:image_message, %Message{})
       |> assign(:image_changeset, image_changeset)
       |> assign(:sender_id, user.id)
       |> assign(:current_user, user)
       |> assign(:search_changeset, search_changeset)
       |> assign(:users, users)
       |> assign(:receiver_id, receiver_id)
       |> assign(:first_4_users, first_4_users)
       |> assign(:messages, messages)
       |> assign(:user, Users.get_user!(params["id"]))
       |> assign(:changeset, changeset)}
    else
      {:ok,
       socket
       |> assign(:message, %Message{})
       |> assign(:image_message, %Message{})
       |> assign(:image_changeset, image_changeset)
       |> assign(:sender_id, user.id)
       |> assign(:user, Users.get_user!(params["id"]))
       |> assign(:current_user, user)
       |> assign(:search_changeset, search_changeset)
       |> assign(:users, users)
       |> assign(:first_4_users, first_4_users)
       |> assign(:messages, messages)
       |> assign(:changeset, changeset)}
    end
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    changeset = Messages.change_message(%Message{})

    receiver_id = socket.assigns.receiver_id

    sender_id = socket.assigns.sender_id

    new_message_params =
      Map.put(message_params, "receiver_id", receiver_id)
      |> Map.put("sender_id", sender_id)

    if new_message_params["text"] != "" do
      case Messages.create_message(new_message_params) do
        {:ok, _message} ->
          {:noreply,
           socket
           |> assign(
             :messages,
             Messages.list_messages_for_a_receiver_and_sender(sender_id, receiver_id)
           )
           |> assign(:changeset, changeset)}
      end
    else
      {:noreply,
       socket
       |> put_flash(:info, "Message cannot be empty")}
    end
  end

  @spec handle_info(any, any) :: {:noreply, any}
  def handle_info({:create, message}, socket) do
    if (message.receiver_id == socket.assigns.receiver_id and
          message.sender_id == socket.assigns.sender_id) or
         (message.receiver_id == socket.assigns.sender_id and
            message.sender_id == socket.assigns.receiver_id) do
      {:noreply, assign(socket, :messages, socket.assigns.messages ++ [message])}
    else
      {:noreply, socket}
    end
  end

  def handle_event("search", %{"message" => message_params}, socket) do
    {:noreply,
     socket
     |> assign(
       :users,
       Users.get_user_search_results(socket.assigns.current_user, message_params["search"])
     )}
  end
end
