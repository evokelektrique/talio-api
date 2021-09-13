defmodule TalioWeb.API.V1.BranchView do
  use TalioWeb, :view
  alias __MODULE__

  # Branch with screenshots
  def render("index.json", %{branch: branch}) do
    unless is_nil(branch) do
      %{
        data: %{
          id: branch.id,
          screenshots:
            render_many(branch.screenshots, TalioWeb.API.V1.ScreenshotView, "screenshot.json"),
          fingerprint: branch.fingerprint,
          inserted_at: branch.inserted_at
        }
      }
    else
      BranchView.render("error.json", %{reason: :branch_not_found})
    end
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

  def render("error.json", %{reason: reason}) do
    case reason do
      :branch_not_found ->
        %{status: reason, message: gettext("Branch not found")}
    end
  end
end
