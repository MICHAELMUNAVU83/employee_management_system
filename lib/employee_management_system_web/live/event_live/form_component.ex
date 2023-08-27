defmodule EmployeeManagementSystemWeb.EventLive.FormComponent do
  use EmployeeManagementSystemWeb, :live_component

  alias EmployeeManagementSystem.Events

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Events.change_event(event)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> assign(:date_error, "")
     |> allow_upload(:event_image, accept: ~w(.jpg .png .jpeg .pdf), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref, "value" => value}, socket) do
    {:noreply, cancel_upload(socket, :event_image, ref)}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :event_image, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:employee_management_system),
            "static",
            "uploads",
            Path.basename(path)
          ])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    new_event_params = Map.put(event_params, "image", List.first(uploaded_files))
    save_event(socket, socket.assigns.action, new_event_params)
  end

  defp save_event(socket, :edit, event_params) do
    today = Timex.today()

    {_ok, todays_date} = Timex.format(today, "{YYYY}-{M}-{D}")

    todays_date =
      todays_date
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.map_join("", &Integer.to_string(&1))
      |> String.to_integer()

    event_date =
      event_params["date"]
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.map_join("", &Integer.to_string(&1))
      |> String.to_integer()

    IO.inspect(event_date)
    IO.inspect(todays_date)

    if event_date < todays_date do
      {:noreply,
       socket
       |> assign(:date_error, "Date must be in the future")}
    else
      case Events.update_event(socket.assigns.event, event_params) do
        {:ok, _event} ->
          {:noreply,
           socket
           |> put_flash(:info, "Event updated successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_event(socket, :new, event_params) do
    today = Timex.today()

    {_ok, todays_date} = Timex.format(today, "{YYYY}-{M}-{D}")

    todays_date =
      todays_date
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.map_join("", &Integer.to_string(&1))
      |> String.to_integer()

    event_date =
      event_params["date"]
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.map_join("", &Integer.to_string(&1))
      |> String.to_integer()

    IO.inspect(event_date)
    IO.inspect(todays_date)

    if event_date < todays_date do
      {:noreply,
       socket
       |> assign(:date_error, "Date must be in the future")}
    else
      case Events.create_event(event_params) do
        {:ok, _event} ->
          {:noreply,
           socket
           |> put_flash(:info, "Event created successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end
end
