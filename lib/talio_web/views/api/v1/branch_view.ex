defmodule TalioWeb.API.V1.BranchView do
  use TalioWeb, :view
  alias __MODULE__

  # Branch with screenshots
  def render("index.json", %{branch: branch}) do
    %{
      id: branch.id,
      screenshots:
        render_many(branch.screenshots, TalioWeb.API.V1.ScreenshotView, "screenshot.json"),
      fingerprint: branch.fingerprint,
      inserted_at: branch.inserted_at
    }
  end

  def render("branch.json", %{branch: branch}) do
    %{
      id: branch.id,
      screenshots:
        render_many(branch.screenshots, TalioWeb.API.V1.ScreenshotView, "screenshot.json"),
      fingerprint: branch.fingerprint,
      inserted_at: branch.inserted_at
    }
  end
end
