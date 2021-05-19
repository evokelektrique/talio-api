defmodule TalioWeb.API.V1.PlanController do
  use TalioWeb, :controller

  alias Talio.{Repo, Plan}
  alias Talio.Guards.Plan, as: PlanGuard

  action_fallback TalioWeb.API.V1.FallbackController

  def index(conn, _params) do
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(PlanGuard, :admin_plan, current_user) do
      plans = Repo.all(Plan)

      conn
      |> render("index.json", %{plans: plans})
    end
  end

  def show(conn, %{"id" => plan_id}) do
    case Repo.get(Plan, plan_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :plan_not_found)

      plan ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        with :ok <- Bodyguard.permit(PlanGuard, :admin_plan, current_user) do
          conn
          |> put_status(:ok)
          |> render("show.json", plan: plan)
        end
    end
  end

  def create(conn, %{"plan" => plan_params}) do
    changeset = Plan.changeset(%Plan{}, plan_params)
    current_user = Talio.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(PlanGuard, :admin_plan, current_user) do
      case Repo.insert(changeset) do
        {:ok, plan} ->
          conn
          |> put_status(:created)
          |> render("create.json", plan: plan)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(TalioWeb.ChangesetView)
          |> render("error.json", changeset: changeset)
      end
    end
  end

  def update(conn, %{"id" => plan_id, "plan" => plan_params}) do
    case Repo.get(Plan, plan_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :plan_not_found)

      plan ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        update_changeset =
          plan
          |> Plan.changeset(plan_params)
          |> Ecto.Changeset.change()

        with :ok <- Bodyguard.permit(PlanGuard, :admin_plan, current_user) do
          case Repo.update(update_changeset) do
            {:ok, plan} ->
              conn
              |> put_status(:created)
              |> render("create.json", plan: plan)

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> put_view(TalioWeb.ChangesetView)
              |> render("error.json", changeset: changeset)
          end
        end
    end
  end

  def delete(conn, %{"id" => plan_id}) do
    case Repo.get(Plan, plan_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :plan_not_found)

      plan ->
        current_user = Talio.Guardian.Plug.current_resource(conn)

        with :ok <- Bodyguard.permit(PlanGuard, :admin_plan, current_user) do
          Repo.delete(plan)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(204, "")
        end
    end
  end
end
