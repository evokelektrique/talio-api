defmodule TalioWeb.API.V1.UserView do
  use TalioWeb, :view
  alias __MODULE__

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      full_name: user.full_name,
      # password_hash: user.password_hash,
      email: user.email,
      role: user.role
    }
  end
end
