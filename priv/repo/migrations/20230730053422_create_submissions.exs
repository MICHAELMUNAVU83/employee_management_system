defmodule EmployeeManagementSystem.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add(:title, :string)
      add(:description, :string)
      add(:type, :string)
      add(:image, :string)
      add(:pdf, :string)
      add(:link, :string)
      add(:task_id, references(:tasks, on_delete: :nothing))

      timestamps()
    end
  end
end
