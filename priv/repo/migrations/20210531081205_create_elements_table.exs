defmodule Talio.Repo.Migrations.CreateElementsTable do
  use Ecto.Migration
  
  def up do
  	create table(:elements) do
  		add :width, 	:decimal, null: false
  		add :height, 	:decimal, null: false
  		add :top, 		:decimal, null: false
  		add :right, 	:decimal, null: false
  		add :bottom, 	:decimal, null: false
  		add :left, 		:decimal, null: false
  		add :x, 		  :decimal, null: false
  		add :y, 		  :decimal, null: false
  		add :path, 		:text, null: false
  		add :tag_name,:string, null: false
  		## Device Types:
  		# 0 => Desktop
  		# 1 => Tablet
  		# 2 => Mobile
  		add :device, 	:integer, null: false

  		add :branch_id, references(:branches), null: false

  		timestamps()
  	end

  	create index(:elements, [:branch_id])
  	create index(:elements, [:device])
  	create index(:elements, [:tag_name])
  	create index(:elements, [:path])
  end

  def down do
  	drop index(:elements, [:branch_id])
  	drop index(:elements, [:device])
  	drop index(:elements, [:tag_name])
  	drop index(:elements, [:path])
  	
  	drop table(:elements)
  end
end
