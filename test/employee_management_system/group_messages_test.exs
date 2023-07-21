defmodule EmployeeManagementSystem.GroupMessagesTest do
  use EmployeeManagementSystem.DataCase

  alias EmployeeManagementSystem.GroupMessages

  describe "group_messages" do
    alias EmployeeManagementSystem.GroupMessages.GroupMessage

    import EmployeeManagementSystem.GroupMessagesFixtures

    @invalid_attrs %{text: nil}

    test "list_group_messages/0 returns all group_messages" do
      group_message = group_message_fixture()
      assert GroupMessages.list_group_messages() == [group_message]
    end

    test "get_group_message!/1 returns the group_message with given id" do
      group_message = group_message_fixture()
      assert GroupMessages.get_group_message!(group_message.id) == group_message
    end

    test "create_group_message/1 with valid data creates a group_message" do
      valid_attrs = %{text: "some text"}

      assert {:ok, %GroupMessage{} = group_message} =
               GroupMessages.create_group_message(valid_attrs)

      assert group_message.text == "some text"
    end

    test "create_group_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GroupMessages.create_group_message(@invalid_attrs)
    end

    test "update_group_message/2 with valid data updates the group_message" do
      group_message = group_message_fixture()
      update_attrs = %{text: "some updated text"}

      assert {:ok, %GroupMessage{} = group_message} =
               GroupMessages.update_group_message(group_message, update_attrs)

      assert group_message.text == "some updated text"
    end

    test "update_group_message/2 with invalid data returns error changeset" do
      group_message = group_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               GroupMessages.update_group_message(group_message, @invalid_attrs)

      assert group_message == GroupMessages.get_group_message!(group_message.id)
    end

    test "delete_group_message/1 deletes the group_message" do
      group_message = group_message_fixture()
      assert {:ok, %GroupMessage{}} = GroupMessages.delete_group_message(group_message)

      assert_raise Ecto.NoResultsError, fn ->
        GroupMessages.get_group_message!(group_message.id)
      end
    end

    test "change_group_message/1 returns a group_message changeset" do
      group_message = group_message_fixture()
      assert %Ecto.Changeset{} = GroupMessages.change_group_message(group_message)
    end
  end
end
