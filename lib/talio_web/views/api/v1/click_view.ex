defmodule TalioWeb.API.V1.ClickView do
  use TalioWeb, :view
  alias __MODULE__

  def render("clicks.json", %{clicks: clicks}) do
    %{data: render_many(clicks, ClickView, "click.json")}
  end

  def render("click.json", %{click: click}) do
    %{
      # id: click.id,
      x: click.x,
      y: click.y,
      # talio_user_id: click.talio_user_id,
      path: click.path
      # device: click.device
    }
  end
end
