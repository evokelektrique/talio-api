defmodule TalioWeb.API.V1.WebsiteView do
  use TalioWeb, :view
  alias __MODULE__

  def render("index.json", %{websites: websites}) do
    %{data: render_many(websites, WebsiteView, "website.json")}
  end

  def render("show.json", %{website: website}) do
    %{data: render_one(website, WebsiteView, "website.json")}
  end

  def render("website.json", %{website: website}) do
    %{
      id: website.id,
      name: website.name,
      url: website.url,
      is_verified: website.is_verified,
      category: %{
        id: website.category.id,
        name: website.category.name
      }
    }
  end

  def render("create.json", %{website: website}) do
    %{
      status: :ok,
      message: gettext("Website created successfully."),
      data: render_one(website, WebsiteView, "website.json")
    }
  end

  def render("verify.json", %{website: website}) do
    %{
      status: :ok,
      message: gettext("Website successfully verified"),
      data: render_one(website, WebsiteView, "website.json")
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :category_not_found ->
        %{status: reason, message: gettext("Category not found")}

      :website_not_found ->
        %{status: reason, message: gettext("Website not found")}

      :script_not_found ->
        %{status: reason, message: gettext("Script tag not found")}
    end
  end
end