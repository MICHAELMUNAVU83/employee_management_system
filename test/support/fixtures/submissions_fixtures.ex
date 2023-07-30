defmodule EmployeeManagementSystem.SubmissionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmployeeManagementSystem.Submissions` context.
  """

  @doc """
  Generate a submission.
  """
  def submission_fixture(attrs \\ %{}) do
    {:ok, submission} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        link: "some link",
        pdf: "some pdf",
        title: "some title",
        type: "some type"
      })
      |> EmployeeManagementSystem.Submissions.create_submission()

    submission
  end
end
