defmodule TodoList.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoList.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        completed: true,
        description: "some description",
        due_date: ~D[2025-04-15],
        title: "some title"
      })
      |> TodoList.Tasks.create_task()

    task
  end
end
