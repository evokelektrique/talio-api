defmodule TalioWeb.API.V1.WebsiteController do
  use TalioWeb, :controller

  alias Talio.{Repo, Website, Category}
  alias Talio.Guards.Website, as: WebsiteGuard

  action_fallback TalioWeb.API.V1.FallbackController

  def index(conn, _params) do
    current_user =
      Talio.Guardian.Plug.current_resource(conn)
      |> Repo.preload(websites: :category)

    conn
    |> render("index.json", %{websites: current_user.websites})
  end

  def show(conn, %{"id" => website_id}) do
    case Repo.get(Website, website_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :website_not_found)

      website ->
        current_user = Talio.Guardian.Plug.current_resource(conn)
        website = website |> Repo.preload(:category)

        with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
          conn
          |> put_status(:ok)
          |> render("show.json", website: website)
        end
    end
  end

  def create(conn, %{"website" => website_params, "category" => category_params}) do
    case Repo.get(Category, category_params["id"]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :category_not_found)

      category ->
        current_user = Talio.Guardian.Plug.current_resource(conn)
        changeset = Website.changeset(%Website{}, website_params)

        changeset =
          changeset
          |> Ecto.Changeset.put_assoc(:category, category)
          |> Ecto.Changeset.put_assoc(:user, current_user)

        case Repo.insert(changeset) do
          {:ok, website} ->
            conn
            |> put_status(:created)
            |> render("create.json", website: website)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(TalioWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  def update(conn, %{
        "id" => website_id,
        "website" => website_params,
        "category" => category_params
      }) do
    case Repo.get(Category, category_params["id"]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :category_not_found)

      category ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        case Repo.get(Website, website_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render("error.json", reason: :website_not_found)

          website ->
            website = website |> Repo.preload(:category)

            update_changeset =
              website
              |> Website.changeset(website_params)
              |> Ecto.Changeset.change()
              |> Ecto.Changeset.put_assoc(:category, category)

            with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
              case Repo.update(update_changeset) do
                {:ok, website} ->
                  conn
                  |> put_status(:created)
                  |> render("create.json", website: website)

                {:error, changeset} ->
                  conn
                  |> put_status(:unprocessable_entity)
                  |> put_view(TalioWeb.ChangesetView)
                  |> render("error.json", changeset: changeset)
              end
            end
        end
    end
  end

  def delete(conn, %{"id" => website_id}) do
    case Repo.get(Website, website_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :website_not_found)

      website ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
          Repo.delete(website)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(204, "")
        end
    end
  end

  def verify(conn, %{"id" => website_id}) do
    case Repo.get(Website, website_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :website_not_found)

      website ->
        website = website |> Repo.preload(:category)

        case HTTPoison.get(website.url) do
          {:error, %HTTPoison.Error{reason: _reason}} ->
            conn
            |> put_status(:not_found)
            |> render("error.json", reason: :website_not_found)

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            conn
            |> put_status(:not_found)
            |> render("error.json", reason: :website_not_found)

          {:ok, %HTTPoison.Response{body: body}} ->
            if Website.matched?(body) do
              current_user = Talio.Guardian.Plug.current_resource(conn)

              update_changeset =
                website
                |> Website.verify_changeset(%{is_verified: true})
                |> Ecto.Changeset.change()

              with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
                case Repo.update(update_changeset) do
                  {:error, changeset} ->
                    conn
                    |> put_status(:unprocessable_entity)
                    |> put_view(TalioWeb.ChangesetView)
                    |> render("error.json", changeset: changeset)

                  {:ok, website} ->
                    conn
                    |> put_status(:ok)
                    |> render("verify.json", website: website)
                end
              end
            else
              conn
              |> put_status(:not_found)
              |> render("error.json", reason: :script_not_found)
            end
        end
    end
  end
end
