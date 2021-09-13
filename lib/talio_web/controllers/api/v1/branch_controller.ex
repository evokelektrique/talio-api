defmodule TalioWeb.API.V1.BranchController do
  use TalioWeb, :controller

  alias Talio.{Repo, Branch, Element, Click}
  alias Talio.Guards.Website, as: WebsiteGuard
  alias Talio.Guards.Branch, as: BranchGuard

  import Ecto.Query

  action_fallback TalioWeb.API.V1.FallbackController

  # Get branch and its relative screenshots by its ID
  # TODO: Create user permission (Guard)
  def index(conn, %{"branch_id" => branch_id}) do
    branch = Repo.get(Branch, branch_id) |> Repo.preload(:screenshots)

    case branch do
      branch ->
        conn
        |> put_status(:ok)
        |> put_view(TalioWeb.API.V1.BranchView)
        |> render("index.json", %{branch: branch})

      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.ErrorView)
        |> render("404.json")
    end
  end

  # Get all clicks relative to the device ID
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
end
