defmodule Talio.Jobs.Screenshot do
  use Oban.Worker,
    queue: :snapshots,
    max_attempts: 3,
    unique: [period: 300, keys: [:key]]

  alias Talio.{Repo, Branch, Screenshot}

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"key" => key, "options" => options, "screenshot_id" => screenshot_id} = _args
      }) do
    screenshot = Repo.get(Screenshot, screenshot_id)

    case Talio.Helpers.Screenshot.take(options) do
      {:ok, image} ->
        binary = image[:image]
        filename = key <> ".jpeg"

        # Change Screenshot 'status' column to 'Completed'
        screenshot_params = %{
          # Completed
          status: 1
        }

        screenshot
        |> Screenshot.changeset(screenshot_params)
        |> Ecto.Changeset.change()
        |> Repo.update!()

        # Uplaod Image To MinIO Server
        config = Application.fetch_env!(:talio, :screenshot)
        Talio.Helpers.Storage.upload(config.s3.bucket, filename, binary)

        :ok

      {:error, reason} ->
        Logger.error(reason)
        {:error, "Error In Screenshot: #{inspect(reason)}"}
    end
  end

  # @impl Worker
  # def backoff(%Job{attempt: attempt, unsaved_error: unsaved_error}) do
  #   %{kind: _, reason: reason, stacktrace: _} = unsaved_error
  #   Logger.error(reason)
  #   trunc(10)
  # end

  @impl Oban.Worker
  def timeout(%Job{args: %{"options" => options, "screenshot_id" => screenshot_id} = _args}) do
    # screenshot = Repo.get(Screenshot, screenshot_id)

    # screenshot_params = %{
    #   # Completed
    #   status: 2
    # }

    # screenshot
    # |> Screenshot.changeset(screenshot_params)
    # |> Ecto.Changeset.change()
    # |> Repo.update!()

    # IO.inspect(args)
    # branch = Repo.get(Branch, options["branch_id"])

    # # Change Branch screenshot_status to "Failed"
    # branch
    # |> Branch.changeset(%{screenshot_status: 3})
    # |> Ecto.Changeset.change()
    # |> Repo.update()

    :timer.minutes(2)
  end
end
