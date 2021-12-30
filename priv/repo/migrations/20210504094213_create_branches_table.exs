defmodule Talio.Repo.Migrations.CreateBranchesTable do
  use Ecto.Migration
  def up do
  	create table(:branches) do
  		add :snapshot_id, references(:snapshots, on_delete: :delete_all), null: false
  		add :fingerprint, :string, null: false
      add :website_id, references(:websites, on_delete: :delete_all)

  		timestamps()
  	end

  	create index(:branches, [:snapshot_id])
    create index(:branches, [:website_id])    

  end

  def down do
    drop index(:branches, [:snapshot_id])
    drop index(:branches, [:website_id])
    
  	drop table(:branches)
  end
end
