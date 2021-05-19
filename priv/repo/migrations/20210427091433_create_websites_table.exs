defmodule Talio.Repo.Migrations.CreateWebsitesTable do
  use Ecto.Migration

  def up do
  	create table(:websites) do
  		add :category_id, references(:categories)
  		add :user_id, references(:users)
  		add :name, :string, null: false
  		add :url, :string, null: false
  		add :is_verified, :boolean, default: false, null: false

  		timestamps()
  	end

    create index(:websites, [:user_id])
    create index(:websites, [:category_id])
  end

  def down do
  	drop table(:websites)
  end
end
