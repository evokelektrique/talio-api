defmodule Talio.Repo.Migrations.CreateClicksTable do
  use Ecto.Migration
  
  def up do
  	create table(:clicks) do
  		add :x, :integer, null: false
  		add :y, :integer, null: false
      add :talio_user_id, :integer, null: false

  		add :element_id, references(:elements), null: false

  		timestamps()
  	end

    create unique_index(:clicks, [:x, :talio_user_id])
    create unique_index(:clicks, [:y, :talio_user_id])
  	create index(:clicks, [:element_id])
    create index(:clicks, [:talio_user_id])
  end

  def down do
    drop unique_index(:clicks, [:y, :talio_user_id])
    drop unique_index(:clicks, [:x, :talio_user_id])
    drop index(:clicks, [:talio_user_id])
  	drop index(:clicks, [:element_id])
  	
  	drop table(:clicks)
  end
end
