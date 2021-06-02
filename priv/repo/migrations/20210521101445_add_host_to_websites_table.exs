defmodule Talio.Repo.Migrations.AddHostToWebsitesTable do
  use Ecto.Migration

  def up do
  	alter table(:websites) do
  		add :host, :string, null: false
  	end
	create index(:websites, [:host])
  end

  def down do
  	alter table(:websites) do
  		remove :host
  	end
	drop index(:websites, [:host])  	
  end
end
