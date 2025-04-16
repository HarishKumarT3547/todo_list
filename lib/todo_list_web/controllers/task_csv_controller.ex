defmodule TodoListWeb.TaskCSVController do
  use TodoListWeb, :controller
  alias TodoList.Tasks
  alias NimbleCSV.RFC4180, as: CSV

  def download_csv(conn, _params) do
    tasks = Tasks.list_tasks()

    rows = [
      ["Title", "Description", "Due Date", "Completed"]
      | Enum.map(tasks, fn task ->
          [
            task.title,
            task.description,
            task.due_date |> to_string(),
            if(task.completed, do: "Yes", else: "No")
          ]
        end)
    ]

    csv_binary = CSV.dump_to_iodata(rows)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="tasks.csv"])
    |> send_resp(200, csv_binary)
  end

end
