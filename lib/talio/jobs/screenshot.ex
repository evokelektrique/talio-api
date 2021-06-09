defmodule Talio.Jobs.Screenshot do
  use Oban.Worker, queue: :snapshots, max_attempts: 5

  require Logger

  @config Application.fetch_env!(:talio, :screenshot)

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"key" => key, "options" => options} = _args}) do
    case Talio.Screenshot.take(options) do
      {:ok, image} ->
        binary = image[:image]
        filename = key <> ".jpeg"

        # Uplaod Image To MinIO Server
        Talio.Storage.upload(@config.s3.bucket, filename, binary)
        :ok

      {:error, reason} ->
        Logger.error(reason)
        {:error, "Error In Screenshot"}
    end
  end

  # @impl Worker
  # def backoff(%Job{attempt: attempt, unsaved_error: unsaved_error}) do
  #   %{kind: _, reason: reason, stacktrace: _} = unsaved_error
  #   Logger.error(reason)
  #   trunc(10)
  #   # case reason do
  #   #   %MyApp.ApiError{status: 429} -> @five_minutes
  #   #   _ -> 
  #   # end
  # end

  @impl Oban.Worker
  def timeout(_job), do: :timer.minutes(2)
end
