defmodule Talio.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :full_name, :string
      add :password_hash, :string
      add :email, :string
      add :role, :integer, default: 1, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop index(:users, [:email])
    drop table(:users)
  end
end
