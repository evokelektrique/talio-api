defmodule TalioWeb.API.V1.BranchController do
  use TalioWeb, :controller

  alias Talio.{Accounts, Repo, Branch, Element, Click}
  alias Talio.Guards.Website, as: WebsiteGuard

  import Ecto.Query

  action_fallback TalioWeb.API.V1.FallbackController

  def clicks(
        conn,
        %{"website_id" => website_id, "branch_id" => branch_id, "device" => device} = _params
      ) do
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website_id) do
      clicks =
        Repo.all(
          from clicks in Click,
            join: elements in Element,
            on:
              clicks.path == elements.path and
                clicks.device == elements.device and
                elements.branch_id == ^branch_id and
                elements.device == ^device
        )

      if is_nil(clicks) do
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.ErrorView)
        |> render("404.json")
      else
        conn
        |> put_status(:ok)
        |> put_view(TalioWeb.API.V1.ClickView)
        |> render("clicks.json", %{clicks: clicks})
      end
    end
  end

  def elements(
        conn,
        %{"website_id" => website_id, "branch_id" => branch_id, "device" => device} = _params
      ) do
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website_id) do
      elements =
        from branch in Branch,
          where: branch.id == ^branch_id,
          left_join: elements in assoc(branch, :elements),
          where: elements.device == ^device,
          preload: [elements: elements]

      results = Repo.one(elements)

      if is_nil(results) do
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.ErrorView)
        |> render("404.json")
      else
        conn
        |> put_status(:ok)
        |> put_view(TalioWeb.API.V1.ElementView)
        |> render("elements.json", %{elements: results.elements})
      end
    end
  end

  # def index(conn, _params) do
  #   users = Accounts.list_users()
  #   current_user = Talio.Guardian.Plug.current_resource(conn)

  #   with :ok <- Bodyguard.permit(BranchGuard, :list_users, current_user) do
  #     render(conn, "index.json", users: users)
  #   end
  # end

  # def create(conn, %{"user" => user_params}) do
  #   with {:ok, %Branch{} = user} <- Accounts.create_user(user_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.user_path(conn, :show, user))
  #     |> render("show.json", user: user)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   user = Accounts.get_user(id)
  #   render(conn, "show.json", user: user)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Accounts.get_user(id)

  #   with {:ok, %Branch{} = user} <- Accounts.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Accounts.get_user(id)

  #   with {:ok, %Branch{}} <- Accounts.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
