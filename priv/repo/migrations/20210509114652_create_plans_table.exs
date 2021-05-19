defmodule Talio.Repo.Migrations.CreatePlansTable do
  use Ecto.Migration

  def up do
  	create table(:plans) do
  		add :name, :string, null: false
  		add :duration, :integer, null: false
  		add :price, :integer, default: 0, null: false
  		add :limits, :map, default: %{}, null: false

		timestamps()
  	end
  end

  def down do
  	drop table(:plans)
  end
end
