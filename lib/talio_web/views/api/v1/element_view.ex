defmodule TalioWeb.API.V1.ElementView do
  use TalioWeb, :view
  alias __MODULE__

  def render("elements.json", %{elements: elements}) do
    %{data: render_many(elements, ElementView, "element.json")}
  end

  def render("element.json", %{element: element}) do
    %{
      # id: element.id,
      path: element.path,
      tag_name: element.tag_name,
      width: element.width,
      height: element.height,
      top: element.top,
      right: element.right,
      bottom: element.bottom,
      left: element.left,
      x: element.x,
      y: element.y,
      device: element.device
      # clicks: render_many(element.clicks, TalioWeb.API.V1.ClickView, "click.json")
    }
  end
end
