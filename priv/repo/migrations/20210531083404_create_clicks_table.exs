defmodule Talio.Repo.Migrations.CreateClicksTable do
  use Ecto.Migration
  
  def up do
  	create table(:clicks) do
  		add :x, :integer, null: false
  		add :y, :integer, null: false
      add :talio_user_id, :integer, null: false
      add :path,    :text, null: false
      ## Device Types:
      # 0 => Desktop
      # 1 => Tablet
      # 2 => Mobile
      add :device,  :integer, null: false
      add :branch_id, references(:branches, on_delete: :delete_all), null: false
  		timestamps()
  	end

    create index(:clicks, [:x, :y, :talio_user_id, :device], unique: true)
    create index(:clicks, [:talio_user_id])
  end

  def down do
    drop index(:clicks, [:x, :y, :talio_user_id, :device], unique: true)
    drop index(:clicks, [:talio_user_id])
  	
  	drop table(:clicks)
  end
end
