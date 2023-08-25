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

    IO.inspect(submission_params)


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
    case socket.assigns.format_selected do
      "image" ->
        uploaded_files =
          consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
            dest =
              Path.join([
                :code.priv_dir(:employee_management_system),
                "static",
                "uploads",
                Path.basename(path)
              ])

            File.cp!(path, dest)
            {:ok, "/uploads/" <> Path.basename(dest)}
          end)

        {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

        new_submission_params = Map.put(submission_params, "image", List.first(uploaded_files))

        save_submission(socket, socket.assigns.action, new_submission_params)

      "pdf" ->
        uploaded_files =
          consume_uploaded_entries(socket, :pdf, fn %{path: path}, _entry ->
            dest =
              Path.join([
                :code.priv_dir(:employee_management_system),
                "static",
                "uploads",
                Path.basename(path)
              ])

            File.cp!(path, dest)
            {:ok, "/uploads/" <> Path.basename(dest)}
          end)

        {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

        new_submission_params = Map.put(submission_params, "pdf", List.first(uploaded_files))
        save_submission(socket, socket.assigns.action, new_submission_params)

      _ ->
        save_submission(socket, socket.assigns.action, submission_params)
    end
  end

  defp save_submission(socket, :edit_submission, submission_params) do
    IO.inspect(submission_params)

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

  defp save_submission(socket, :add_submission, submission_params) do
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
