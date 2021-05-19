defmodule Talio.Repo.Migrations.AddUniqueIndexToWebsitesTable do
	use Ecto.Migration

	def up do
		create unique_index(:websites, [:url, :user_id])
	end

	def down do
		drop index(:websites, [:url, :user_id])  	
	end
end
