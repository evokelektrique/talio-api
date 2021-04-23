defmodule TalioWeb.API.V1.UserController do
  use TalioWeb, :controller

  alias Talio.Accounts
  alias Talio.Accounts.User
  alias Talio.Guards.User, as: UserGuard

  action_fallback TalioWeb.API.V1.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(UserGuard, :list_users, current_user) do
      render(conn, "index.json", users: users)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
