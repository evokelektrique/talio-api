defmodule TalioWeb.API.V1.SnapshotView do
  use TalioWeb, :view
  alias __MODULE__

  def render("index.json", %{snapshots: snapshots, website: website}) do
    %{data: render_many(snapshots, SnapshotView, "single_snapshot.json")}
  end

  def render("show.json", %{snapshot: snapshot, website: website}) do
    %{data: render(SnapshotView, "snapshot.json", %{snapshot: snapshot, website: website})}
  end

  # Includes :website
  def render("snapshot.json", %{snapshot: snapshot, website: website}) do
    %{
      id: snapshot.id,
      name: snapshot.name,
      path: snapshot.path,
      status: snapshot.status,
      type: Talio.Snapshot.get_type(snapshot.type),
      branches: render_many(snapshot.branches, TalioWeb.API.V1.BranchView, "branch.json"),
      website: render_one(website, TalioWeb.API.V1.WebsiteView, "single_website.json"),
      inserted_at: snapshot.inserted_at
    }
  end

  # Excludes :website
  def render("single_snapshot.json", %{snapshot: snapshot}) do
    %{
      id: snapshot.id,
      name: snapshot.name,
      path: snapshot.path,
      status: snapshot.status,
      type: Talio.Snapshot.get_type(snapshot.type)
    }
  end

  def render("create.json", %{snapshot: snapshot}) do
    %{
      status: :ok,
      message: gettext("Snapshot created successfully."),
      data: render_one(snapshot, SnapshotView, "single_snapshot.json")
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :snapshot_not_found ->
        %{status: reason, message: gettext("Snapshot not found")}
    end
  end
end
