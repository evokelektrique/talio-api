defmodule Talio.Repo.Migrations.CreateVerificationCodesTable do
  use Ecto.Migration

  def up do
  	create table(:verification_codes) do
  		add :user_id, references(:users), on_delete: :delete_all
  		add :code, :integer

  		timestamps()
  	end

    create index(:verification_codes, [:code])
  end

  def down do
    drop index(:verification_codes, [:code])
    drop table(:verification_codes)
  end
end
