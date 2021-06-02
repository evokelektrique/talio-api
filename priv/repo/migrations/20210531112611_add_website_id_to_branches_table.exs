defmodule Talio.Repo.Migrations.AddWebsiteIdToBranchesTable do
  use Ecto.Migration
  
  def up do
    alter table(:branches) do
		add :website_id, references(:websites)
    end

  	create index(:branches, [:website_id])    
  end

  def down do
  	drop index(:branches, [:website_id])

    alter table(:branches) do
      remove :website_id
    end
  end
end
