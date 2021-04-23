defmodule Talio.Repo.Migrations.CreateVerificationCodesTable do
  use Ecto.Migration

  def up do
  	create table(:verification_codes) do
  		add :user_id, references(:users), on_delete: :delete_all
  		add :code, :integer

  		timestamps()
  	end
  end

  def down do
    drop table(:verification_codes)
  end
end
