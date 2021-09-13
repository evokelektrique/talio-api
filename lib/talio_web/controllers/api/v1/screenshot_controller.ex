defmodule TalioWeb.API.V1.ScreenshotController do
  use TalioWeb, :controller

  alias Talio.Repo
  alias Talio.Helpers.Storage

  action_fallback TalioWeb.API.V1.FallbackController

  def get_image(conn, %{"key" => key}) do
    IO.inspect(key)

    bucket = "screenshots"
    destination = key <> ".jpeg"

    with :ok <- Storage.exists?(bucket, destination) do
      {:ok, url} = Storage.get(bucket, destination)

      conn
      |> put_status(:ok)
      |> put_view(TalioWeb.API.V1.ScreenshotView)
      |> render("s3_screenshot.json", %{url: url})
    else
      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.ErrorView)
        |> render("404.json")
    end
  end
end
