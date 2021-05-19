defmodule Talio.Repo.Migrations.CreateBranchesTable do
  use Ecto.Migration
  def up do
  	create table(:branches) do
  		add :snapshot_id, references(:snapshots), null: false
  		add :fingerprint, :string, null: false

  		timestamps()
  	end

  	create index(:branches, [:snapshot_id])
  end

  def down do
  	drop table(:branches)
  end
end
