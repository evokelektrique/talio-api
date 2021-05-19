defmodule TalioWeb.API.V1.PlanView do
  use TalioWeb, :view
  alias __MODULE__

  def render("index.json", %{plans: plans}) do
    %{data: render_many(plans, PlanView, "plan.json")}
  end

  def render("show.json", %{plan: plan}) do
    %{data: render_one(plan, PlanView, "plan.json")}
  end

  def render("plan.json", %{plan: plan}) do
    %{
      id: plan.id,
      name: plan.name,
      duration: plan.duration,
      price: plan.price,
      limits: plan.limits
    }
  end

  def render("create.json", %{plan: plan}) do
    %{
      status: :ok,
      message: gettext("Plan created successfully."),
      data: render_one(plan, PlanView, "plan.json")
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :plan_not_found ->
        %{status: reason, message: gettext("Plan not found")}
    end
  end
end
