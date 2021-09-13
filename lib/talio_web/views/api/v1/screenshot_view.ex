defmodule TalioWeb.API.V1.ScreenshotView do
  use TalioWeb, :view
  alias __MODULE__

  def render("screenshot.json", %{screenshot: screenshot}) do
    %{
      id: screenshot.id,
      status: screenshot.status,
      device: screenshot.device,
      key: screenshot.key,
      inserted_at: screenshot.inserted_at
    }
  end

  def render("s3_screenshot.json", %{url: url}) do
    %{
      url: url
    }
  end
end
