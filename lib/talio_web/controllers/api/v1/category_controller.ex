defmodule TalioWeb.API.V1.CategoryController do
  use TalioWeb, :controller

  alias Talio.{Repo, Category}
  alias Talio.Guards.Category, as: CategoryGuard

  action_fallback TalioWeb.API.V1.FallbackController

  def index(conn, _params) do
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(CategoryGuard, :admin_category, current_user) do
      categories = Repo.all(Category)

      conn
      |> render("index.json", %{categories: categories})
    end
  end

  def show(conn, %{"id" => category_id}) do
    case Repo.get(Category, category_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :category_not_found)

      category ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        with :ok <- Bodyguard.permit(CategoryGuard, :admin_category, current_user) do
          conn
          |> put_status(:ok)
          |> render("show.json", category: category)
        end
    end
  end

  def create(conn, %{"category" => category_params}) do
    changeset = Category.changeset(%Category{}, category_params)

    case Repo.insert(changeset) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> render("create.json", category: category)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(TalioWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => category_id, "category" => category_params}) do
    case Repo.get(Category, category_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :category_not_found)

      category ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        update_changeset =
          category
          |> Category.changeset(category_params)
          |> Ecto.Changeset.change()

        with :ok <- Bodyguard.permit(CategoryGuard, :admin_category, current_user) do
          case Repo.update(update_changeset) do
            {:ok, category} ->
              conn
              |> put_status(:created)
              |> render("create.json", category: category)

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> put_view(TalioWeb.ChangesetView)
              |> render("error.json", changeset: changeset)
          end
        end
    end
  end

  def delete(conn, %{"id" => category_id}) do
    case Repo.get(Category, category_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :category_not_found)

      category ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        with :ok <- Bodyguard.permit(CategoryGuard, :admin_category, current_user) do
          Repo.delete(category)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(204, "")
        end
    end
  end
end
