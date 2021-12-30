defmodule Talio.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def up do
  	create table(:transactions) do
  		add :user_id, references(:users, on_delete: :delete_all), null: false
  		add :website_id, references(:websites, on_delete: :delete_all), null: false
  		add :plan_id, references(:plans, on_delete: :delete_all), null: false
  		add :expire, :naive_datetime, null: false
      add :status, :boolean, default: false, null: false

  		timestamps()
  	end

  	create index(:transactions, [:user_id])
  	create index(:transactions, [:website_id])
  	create index(:transactions, [:plan_id])
  end

  def down do
  	drop index(:transactions, [:user_id])
  	drop index(:transactions, [:website_id])
  	drop index(:transactions, [:plan_id])
    
  	drop table(:transactions)
  end
end
