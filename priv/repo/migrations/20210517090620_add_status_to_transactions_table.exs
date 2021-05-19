defmodule Talio.Repo.Migrations.AddStatusToTransactionsTable do
	use Ecto.Migration

	def up do
		alter table(:transactions) do
			add :status, :integer, default: 0, null: false
		end
	end

	def down do
		alter table(:transactions) do
			add :status, :integer, default: 0, null: false
		end
	end
end
