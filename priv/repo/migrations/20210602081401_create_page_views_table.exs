defmodule Talio.Repo.Migrations.CreatePageViewsTable do
	use Ecto.Migration

	def up do
		create table(:page_views) do
			add :talio_user_id, :integer, null: false

			add :snapshot_id, references(:snapshots), null: false

			timestamps()
		end

		create unique_index(:page_views, [:snapshot_id, :talio_user_id])
		create index(:page_views, [:snapshot_id])
	end

	def down do
		drop unique_index(:page_views, [:snapshot_id, :talio_user_id])
		drop index(:page_views, [:snapshot_id])

		drop table(:page_views)
	end
end
