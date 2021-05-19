defmodule Talio.Repo.Migrations.AddUniqueIndexToSnapshotsTable do
  use Ecto.Migration

  def up do
	create unique_index(:snapshots, [:path, :website_id])
  end

  def down do
	drop index(:snapshots, [:path, :website_id])  	
  end
end
