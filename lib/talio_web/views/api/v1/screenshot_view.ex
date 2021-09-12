defmodule TalioWeb.API.V1.ScreenshotView do
  use TalioWeb, :view
  alias __MODULE__

  def render("screenshot.json", %{screenshot: screenshot}) do
    %{
      id: screenshot.id,
      status: screenshot.status,
      device: screenshot.device,
      inserted_at: screenshot.inserted_at
    }
  end
end
