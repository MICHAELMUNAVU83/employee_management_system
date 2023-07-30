defmodule EmployeeManagementSystemWeb.SubmissionLive.FormComponent do
  use EmployeeManagementSystemWeb, :live_component

  alias EmployeeManagementSystem.Submissions

  @impl true
  def update(%{submission: submission} = assigns, socket) do
    changeset = Submissions.change_submission(submission)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:format_selected, "")
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:image, accept: ~w(.jpg .png .jpeg), max_entries: 1)
     |> allow_upload(:pdf, accept: ~w(.pdf), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"submission" => submission_params}, socket) do
    changeset =
      socket.assigns.submission
      |> Submissions.change_submission(submission_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:format_selected, submission_params["type"])}
  end

  def handle_event("save", %{"submission" => submission_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:art_store), "static", "uploads", Path.basename(path)])

        # The `static/uploads` directory must exist for `File.cp!/2`
        # and MyAppWeb.static_paths/0 should contain uploads to work,.
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    case socket.assigns.format_selected do
      "link" ->
        new_submission_params = Map.put(submission_params, "link", List.first(uploaded_files))
        save_submission(socket, socket.assigns.action, new_submission_params)

      "pdf" ->
        new_submission_params = Map.put(submission_params, "pdf", List.first(uploaded_files))
        save_submission(socket, socket.assigns.action, new_submission_params)

      "link" ->
        new_submission_params = Map.put(submission_params, "link", List.first(uploaded_files))
        save_submission(socket, socket.assigns.action, new_submission_params)
    end
  end

  defp save_submission(socket, :edit, submission_params) do
    case Submissions.update_submission(socket.assigns.submission, submission_params) do
      {:ok, _submission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Submission updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_submission(socket, :new, submission_params) do
    case Submissions.create_submission(submission_params) do
      {:ok, _submission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Submission created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
