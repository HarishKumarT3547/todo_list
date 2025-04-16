defmodule TodoListWeb.TaskLive.Index do
  use TodoListWeb, :live_view

  alias TodoList.Tasks
  alias TodoList.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    tasks = Tasks.list_tasks()
    {:ok,
     socket
     |> assign(:tasks, tasks) # Explicitly assign tasks
     |> stream(:tasks, tasks)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_info({TodoListWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    updated_tasks = [task | socket.assigns.tasks] # Add the new task to the list
    {:noreply,
     socket
     |> assign(:tasks, updated_tasks) # Update the :tasks key
     |> stream(:tasks, updated_tasks, reset: true)} # Reset the stream with the updated list
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  def handle_event("toggle_complete", %{"id" => id}, socket) do
    task = TodoList.Tasks.get_task!(id)

    # Toggle the completion status
    updated_attrs = %{completed: !task.completed}
    {:ok, updated_task} = TodoList.Tasks.update_task(task, updated_attrs)

    # Update the tasks list
    updated_tasks =
      socket.assigns.tasks
      |> Enum.map(fn t -> if t.id == updated_task.id, do: updated_task, else: t end)

    {:noreply,
     socket
     |> assign(:tasks, updated_tasks) # Update the :tasks key
     |> stream(:tasks, updated_tasks, reset: true)} # Reset the stream with the updated list
  end

  # Sort the tasks by completion status
  def handle_event("sort_by_completed", _params, socket) do
    # Get the current sort order or default to ascending
    current_order = socket.assigns[:sort_order] || :asc

    # Toggle the sort order
    new_order = if current_order == :asc, do: :desc, else: :asc

    # Sort the tasks based on the new order
    sorted =
      case new_order do
        :asc -> Enum.sort_by(socket.assigns.tasks, & &1.completed)
        :desc -> Enum.sort_by(socket.assigns.tasks, & &1.completed, :desc)
      end

    # Update the socket with the new sort order and sorted tasks
    {:noreply,
     socket
     |> assign(:tasks, sorted) # Update the :tasks key
     |> assign(:sort_order, new_order) # Update the sort order
     |> stream(:tasks, sorted, reset: true)} # Reset the stream with the sorted list
  end

  def handle_event("sort_by_due_date", _params, socket) do
    # Get the current sort order or default to ascending
    current_order = socket.assigns[:sort_order_due_date] || :asc

    # Toggle the sort order
    new_order = if current_order == :asc, do: :desc, else: :asc

    # Sort the tasks based on the new order
    sorted =
      case new_order do
        :asc -> Enum.sort_by(socket.assigns.tasks, & &1.due_date)
        :desc -> Enum.sort_by(socket.assigns.tasks, & &1.due_date, :desc)
      end

    # Update the socket with the new sort order and sorted tasks
    {:noreply,
     socket
     |> assign(:tasks, sorted) # Update the :tasks key
     |> assign(:sort_order_due_date, new_order) # Update the sort order for due date
     |> stream(:tasks, sorted, reset: true)} # Reset the stream with the sorted list
  end
end
