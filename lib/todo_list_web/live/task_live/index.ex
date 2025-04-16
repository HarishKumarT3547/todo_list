defmodule TodoListWeb.TaskLive.Index do
  use TodoListWeb, :live_view

  alias TodoList.Tasks
  alias TodoList.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tasks, Tasks.list_tasks())}
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
    {:noreply, stream_insert(socket, :tasks, task)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  # Sorting
  @impl true
  def handle_event("sort", %{"by" => sort_by}, socket) do
    sorted_tasks =
      case sort_by do
        "due_date" -> Enum.sort_by(socket.assigns.tasks, & &1.due_date)
        "completed" -> Enum.scan(socket.assigns.tasks, & &1.completed)
        _ -> socket.assigns.tasks
      end
    {:noreply, assign(socket, tasks: sorted_tasks)}
  end

  def handle_event("toggle_complete", %{"id" => id}, socket) do
    task = TodoList.Tasks.get_task!(id)

    # Toggle the completion status
    updated_attrs = %{completed: !task.completed}
    {:ok, updated_task} = TodoList.Tasks.update_task(task, updated_attrs)

    # Replace the task in the stream
    {:noreply, stream_insert(socket, :tasks, updated_task)}
  end

  # def export_csv(conn, _params) do
  #   tasks = Tasks.list_tasks()
  #   csv = [["Title", "Description", "Due Date", "Completed"]] ++
  #         Enum.map(tasks, fn task ->
  #           [task.title, task.description, task.due_date, task.completed]
  #         end)

  #   conn
  #   |> put_resp_content_type("text/csv")
  #   |> put_resp_header("content-disposition", "attachment; filename=\"tasks.csv\"")
  #   |> send_resp(200, CSV.encode_to_iodata(csv))
  # end


end
