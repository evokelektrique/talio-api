defmodule Talio.Repo.Migrations.CreateVerificationCodesTable do
  use Ecto.Migration

  def up do
  	create table(:verification_codes) do
  		add :user_id, references(:users, on_delete: :delete_all)
  		add :code, :integer
      # Is code has been used before?
      add :is_expired, :boolean, default: false

  		timestamps()
  	end

    create index(:verification_codes, [:code])
    create unique_index(:verification_codes, [:code, :user_id])
  end

  def down do
    drop index(:verification_codes, [:code])
    drop index(:verification_codes, [:code, :user_id])

    drop table(:verification_codes)
  end
end
