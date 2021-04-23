defmodule Talio.Repo.Migrations.CreateForgotPasswordsTable do
  use Ecto.Migration

  def up do
  	create table(:forgot_passwords) do
  		add :user_id, references(:users), on_delete: :delete_all
  		add :status, :boolean, default: false
  		add :code, :integer, null: false
  	end
  end

  def down do
  	drop table(:forgot_passwords)
  end
end
