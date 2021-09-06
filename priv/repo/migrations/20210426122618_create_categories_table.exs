defmodule Talio.Repo.Migrations.CreateCategoriesTable do
  use Ecto.Migration

  def up do
  	create table(:categories) do
  		add :name, :string, null: false
  		
  		timestamps()
  	end
  end

  def down do
  	drop table(:categories)
  end
end
