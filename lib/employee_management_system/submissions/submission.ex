defmodule EmployeeManagementSystem.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset
  alias EmployeeManagementSystem.Tasks.Task

  schema "submissions" do
    field(:description, :string)
    field(:image, :string)
    field(:link, :string)
    field(:pdf, :string)
    field(:title, :string)
    field(:type, :string)
    belongs_to(:task, Task)

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:title, :description, :type, :image, :pdf, :link, :task_id])
    |> validate_required([:title, :description, :type, :task_id])
    |> validate_format(:link, ~r/https:\/\//, message: "must start with 'https://'")
  end
end
