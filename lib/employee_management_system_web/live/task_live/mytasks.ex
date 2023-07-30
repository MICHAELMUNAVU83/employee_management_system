defmodule EmployeeManagementSystemWeb.TaskLive.Mytasks do
  use EmployeeManagementSystemWeb, :live_view

  alias EmployeeManagementSystem.Users

  alias EmployeeManagementSystem.Tasks
  alias EmployeeManagementSystem.Tasks.Task
  alias EmployeeManagementSystem.Messages
  alias EmployeeManagementSystem.Messages.Message
  alias EmployeeManagementSystem.Submissions
  alias EmployeeManagementSystem.Submissions.Submission
  @impl true
  def mount(_params, session, socket) do
    current_user = Users.get_user_by_session_token(session["user_token"])

    {:ok,
     socket
     |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_params(params, _, socket) do
    tasks = Tasks.list_tasks_for_user(socket.assigns.current_user.id)

    IO.inspect(params)

    pending_tasks =
      tasks
      |> Enum.filter(fn task -> task.status == "pending" end)

    completed_tasks =
      tasks
      |> Enum.filter(fn task -> task.status == "complete" end)

    task =
      if params["task_id"] do
        Tasks.get_task!(params["task_id"])
      else
        %Task{}
      end

    task_submission_for = String.to_integer(params["id"])

    IO.inspect(task_submission_for)

    submission =
      if params["submission_id"] do
        Submissions.get_submission!(params["submission_id"])
      else
        %Submission{}
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:task, task)
     |> assign(:tasks, tasks)
     |> assign(:pending_tasks, pending_tasks)
     |> assign(:completed_tasks, completed_tasks)
     |> assign(:submission, submission)
     |> assign(:task_submission_for, task_submission_for)
     |> assign(:task_changeset, Tasks.change_task(%Task{}))
     |> assign(:user, Users.get_user!(params["id"]))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, assign(socket, :tasks, Tasks.list_tasks())}
  end

  defp page_title(:show), do: "Show Task"
  defp page_title(:add_submission), do: "Add Submission"
  defp page_title(:edit_submission), do: "Edit Submission"
end
