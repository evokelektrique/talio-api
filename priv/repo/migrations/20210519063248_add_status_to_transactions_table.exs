defmodule Talio.Repo.Migrations.AddStatusToTransactionsTable do
	use Ecto.Migration

	def up do
		alter table(:transactions) do
			add :status, :boolean, default: false, null: false
		end
	end

	def down do
		alter table(:transactions) do
			remove :status
		end
	end
end