defmodule TalioWeb.API.V1.BranchView do
  use TalioWeb, :view
  alias __MODULE__

  # def render("index.json", %{branches: branches}) do
  #   %{data: render_many(branches, BranchView, "branch.json")}
  # end

  # def render("show.json", %{branch: branch}) do
  #   %{data: render_one(branch, BranchView, "branch.json")}
  # end

  def render("branch.json", %{branch: branch}) do
    %{
      id: branch.id,
      fingerprint: branch.fingerprint,
      inserted_at: branch.inserted_at
    }
  end

  # # Excludes :category
  # def render("single_branch.json", %{branch: branch}) do
  #   %{
  #     id: branch.id,
  #     name: branch.name,
  #     url: branch.url,
  #     host: branch.host,
  #     is_verified: branch.is_verified,
  #     inserted_at: branch.inserted_at,
  #     updated_at: branch.updated_at
  #     # inserted_at: format_time!(branch.inserted_at) |> DateTime.to_unix(),
  #     # updated_at: format_time!(branch.updated_at) |> DateTime.to_unix()
  #   }
  # end

  # def render("create.json", %{branch: branch}) do
  #   %{
  #     status: :ok,
  #     message: gettext("Branch created successfully."),
  #     data: render_one(branch, BranchView, "branch.json")
  #   }
  # end

  # def render("verify.json", %{branch: branch}) do
  #   %{
  #     status: :ok,
  #     message: gettext("Branch successfully verified"),
  #     data: render_one(branch, BranchView, "branch.json")
  #   }
  # end

  # def render("error.json", %{reason: reason}) do
  #   case reason do
  #     :category_not_found ->
  #       %{status: reason, message: gettext("Category not found")}

  #     :branch_not_found ->
  #       %{status: reason, message: gettext("Branch not found")}

  #     :script_not_found ->
  #       %{status: reason, message: gettext("Script tag not found")}
  #   end
  # end
end
