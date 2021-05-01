defmodule TalioWeb.API.V1.CategoryView do
  use TalioWeb, :view
  alias __MODULE__

  def render("index.json", %{categories: categories}) do
    %{data: render_many(categories, CategoryView, "category.json")}
  end

  def render("show.json", %{category: category}) do
    %{data: render_one(category, CategoryView, "category.json")}
  end

  def render("category.json", %{category: category}) do
    %{
      id: category.id,
      name: category.name
    }
  end

  def render("create.json", %{category: category}) do
    %{
      status: :ok,
      message: gettext("Category created successfully."),
      data: render_one(category, CategoryView, "category.json")
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :category_not_found ->
        %{status: reason, message: gettext("Category not found")}
    end
  end
end
