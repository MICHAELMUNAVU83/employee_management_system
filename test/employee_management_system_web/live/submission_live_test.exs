defmodule EmployeeManagementSystemWeb.SubmissionLiveTest do
  use EmployeeManagementSystemWeb.ConnCase

  import Phoenix.LiveViewTest
  import EmployeeManagementSystem.SubmissionsFixtures

  @create_attrs %{
    description: "some description",
    image: "some image",
    link: "some link",
    pdf: "some pdf",
    title: "some title",
    type: "some type"
  }
  @update_attrs %{
    description: "some updated description",
    image: "some updated image",
    link: "some updated link",
    pdf: "some updated pdf",
    title: "some updated title",
    type: "some updated type"
  }
  @invalid_attrs %{description: nil, image: nil, link: nil, pdf: nil, title: nil, type: nil}

  defp create_submission(_) do
    submission = submission_fixture()
    %{submission: submission}
  end

  describe "Index" do
    setup [:create_submission]

    test "lists all submissions", %{conn: conn, submission: submission} do
      {:ok, _index_live, html} = live(conn, Routes.submission_index_path(conn, :index))

      assert html =~ "Listing Submissions"
      assert html =~ submission.description
    end

    test "saves new submission", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.submission_index_path(conn, :index))

      assert index_live |> element("a", "New Submission") |> render_click() =~
               "New Submission"

      assert_patch(index_live, Routes.submission_index_path(conn, :new))

      assert index_live
             |> form("#submission-form", submission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#submission-form", submission: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.submission_index_path(conn, :index))

      assert html =~ "Submission created successfully"
      assert html =~ "some description"
    end

    test "updates submission in listing", %{conn: conn, submission: submission} do
      {:ok, index_live, _html} = live(conn, Routes.submission_index_path(conn, :index))

      assert index_live |> element("#submission-#{submission.id} a", "Edit") |> render_click() =~
               "Edit Submission"

      assert_patch(index_live, Routes.submission_index_path(conn, :edit, submission))

      assert index_live
             |> form("#submission-form", submission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#submission-form", submission: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.submission_index_path(conn, :index))

      assert html =~ "Submission updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes submission in listing", %{conn: conn, submission: submission} do
      {:ok, index_live, _html} = live(conn, Routes.submission_index_path(conn, :index))

      assert index_live |> element("#submission-#{submission.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#submission-#{submission.id}")
    end
  end

  describe "Show" do
    setup [:create_submission]

    test "displays submission", %{conn: conn, submission: submission} do
      {:ok, _show_live, html} = live(conn, Routes.submission_show_path(conn, :show, submission))

      assert html =~ "Show Submission"
      assert html =~ submission.description
    end

    test "updates submission within modal", %{conn: conn, submission: submission} do
      {:ok, show_live, _html} = live(conn, Routes.submission_show_path(conn, :show, submission))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Submission"

      assert_patch(show_live, Routes.submission_show_path(conn, :edit, submission))

      assert show_live
             |> form("#submission-form", submission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#submission-form", submission: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.submission_show_path(conn, :show, submission))

      assert html =~ "Submission updated successfully"
      assert html =~ "some updated description"
    end
  end
end
