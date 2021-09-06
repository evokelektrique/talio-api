defmodule Talio.Repo.Migrations.CreateSnapshotsTable do
  use Ecto.Migration

  def up do
  	create table(:snapshots) do
  		add :website_id, references(:websites), null: false
  		add :type, :integer, default: 0, null: false
  		add :status, :integer, default: 0, null: false
  		add :path, :string, null: false
      add :name, :string, null: false
  		
  		timestamps()
  	end
  	create index(:snapshots, [:website_id])
    create unique_index(:snapshots, [:path, :website_id])
  end

  def down do
    drop index(:snapshots, [:website_id])
    drop index(:snapshots, [:path, :website_id])    

  	drop table(:snapshots)
  end
end
