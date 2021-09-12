defmodule TalioWeb.API.V1.SnapshotController do
  use TalioWeb, :controller

  alias Talio.{Repo, Snapshot, Website}
  # We only one the users to have access to their websites
  # So we use WebsiteGuard instead of SnapshotGuard
  alias Talio.Guards.Website, as: WebsiteGuard

  import Ecto.Query

  action_fallback TalioWeb.API.V1.FallbackController

  plug :find_website

  def index(conn, _) do
    current_user = Talio.Guardian.Plug.current_resource(conn)
    website = conn.assigns.website
    # plan = conn.assigns.plan
    # IO.inspect(current_user)
    # IO.inspect(website)
    # IO.inspect(plan)

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
      website = website |> Repo.preload(:snapshots)

      conn
      |> render("index.json", %{snapshots: website.snapshots, website: website})
    end
  end

  def show(conn, %{"id" => snapshot_id}) do
    current_user = Talio.Guardian.Plug.current_resource(conn)
    website = conn.assigns.website

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
      website = website |> Repo.preload(:snapshots)

      query = from snapshot in Snapshot, where: [website_id: ^website.id, id: ^snapshot_id]

      case Repo.one(query) do
        nil ->
          conn
          |> put_status(:not_found)
          |> render("error.json", reason: :snapshot_not_found)

        snapshot ->
          snapshot = snapshot |> Repo.preload(branches: :screenshots)

          conn
          |> put_status(:ok)
          |> render("show.json", %{snapshot: snapshot, website: website})
      end
    end
  end

  def create(conn, %{"snapshot" => snapshot_params}) do
    current_user = Talio.Guardian.Plug.current_resource(conn)
    website = conn.assigns.website

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
      changeset =
        Ecto.build_assoc(website, :snapshots, snapshot_params)
        |> Snapshot.changeset(snapshot_params)

      case Repo.insert(changeset) do
        {:ok, snapshot} ->
          conn
          |> put_status(:created)
          |> render("create.json", %{snapshot: snapshot, website: website})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(TalioWeb.ChangesetView)
          |> render("error.json", changeset: changeset)
      end
    end
  end

  def update(conn, %{
        "id" => snapshot_id,
        "snapshot" => snapshot_params
      }) do
    current_user = Talio.Guardian.Plug.current_resource(conn)
    website = conn.assigns.website

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
      website = website |> Repo.preload(:snapshots)

      case Repo.get(Snapshot, snapshot_id) do
        nil ->
          conn
          |> put_status(:not_found)
          |> render("error.json", reason: :snapshot_not_found)

        snapshot ->
          update_changeset =
            snapshot
            |> Snapshot.changeset(snapshot_params)
            |> Ecto.Changeset.change()

          case Repo.update(update_changeset) do
            {:ok, snapshot} ->
              snapshot = snapshot |> Repo.preload(:branches)

              conn
              |> put_status(:created)
              |> render("show.json", %{snapshot: snapshot, website: website})

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> put_view(TalioWeb.ChangesetView)
              |> render("error.json", changeset: changeset)
          end
      end
    end
  end

  def delete(conn, %{"id" => snapshot_id}) do
    current_user = Talio.Guardian.Plug.current_resource(conn)
    website = conn.assigns.website

    with :ok <- Bodyguard.permit(WebsiteGuard, :user_website, current_user, website) do
      case Repo.get(Snapshot, snapshot_id) do
        nil ->
          conn
          |> put_status(:not_found)
          |> render("error.json", reason: :snapshot_not_found)

        snapshot ->
          Repo.delete(snapshot)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(204, "")
      end
    end
  end

  # Find and assign website to conn
  defp find_website(conn, _) do
    %{"website_id" => website_id} = conn.params

    case Repo.get(Website, website_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.API.V1.WebsiteView)
        |> render("error.json", reason: :website_not_found)

      website ->
        conn
        |> assign(:website, website)
    end
  end
end
