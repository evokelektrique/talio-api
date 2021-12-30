defmodule Talio.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :full_name, :string
      add :password_hash, :string
      add :email, :string
      add :is_admin, :boolean, default: false, null: false
      add :is_verified, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop index(:users, [:email])
    drop table(:users)
  end
end
