defmodule EmployeeManagementSystem.SubmissionsTest do
  use EmployeeManagementSystem.DataCase

  alias EmployeeManagementSystem.Submissions

  describe "submissions" do
    alias EmployeeManagementSystem.Submissions.Submission

    import EmployeeManagementSystem.SubmissionsFixtures

    @invalid_attrs %{description: nil, image: nil, link: nil, pdf: nil, title: nil, type: nil}

    test "list_submissions/0 returns all submissions" do
      submission = submission_fixture()
      assert Submissions.list_submissions() == [submission]
    end

    test "get_submission!/1 returns the submission with given id" do
      submission = submission_fixture()
      assert Submissions.get_submission!(submission.id) == submission
    end

    test "create_submission/1 with valid data creates a submission" do
      valid_attrs = %{
        description: "some description",
        image: "some image",
        link: "some link",
        pdf: "some pdf",
        title: "some title",
        type: "some type"
      }

      assert {:ok, %Submission{} = submission} = Submissions.create_submission(valid_attrs)
      assert submission.description == "some description"
      assert submission.image == "some image"
      assert submission.link == "some link"
      assert submission.pdf == "some pdf"
      assert submission.title == "some title"
      assert submission.type == "some type"
    end

    test "create_submission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Submissions.create_submission(@invalid_attrs)
    end

    test "update_submission/2 with valid data updates the submission" do
      submission = submission_fixture()

      update_attrs = %{
        description: "some updated description",
        image: "some updated image",
        link: "some updated link",
        pdf: "some updated pdf",
        title: "some updated title",
        type: "some updated type"
      }

      assert {:ok, %Submission{} = submission} =
               Submissions.update_submission(submission, update_attrs)

      assert submission.description == "some updated description"
      assert submission.image == "some updated image"
      assert submission.link == "some updated link"
      assert submission.pdf == "some updated pdf"
      assert submission.title == "some updated title"
      assert submission.type == "some updated type"
    end

    test "update_submission/2 with invalid data returns error changeset" do
      submission = submission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Submissions.update_submission(submission, @invalid_attrs)

      assert submission == Submissions.get_submission!(submission.id)
    end

    test "delete_submission/1 deletes the submission" do
      submission = submission_fixture()
      assert {:ok, %Submission{}} = Submissions.delete_submission(submission)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_submission!(submission.id) end
    end

    test "change_submission/1 returns a submission changeset" do
      submission = submission_fixture()
      assert %Ecto.Changeset{} = Submissions.change_submission(submission)
    end
  end
end
