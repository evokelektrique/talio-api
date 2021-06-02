defmodule Talio.Repo.Migrations.CreateForgotPasswordsTable do
  use Ecto.Migration

  def up do
  	create table(:forgot_passwords) do
  		add :user_id, references(:users), on_delete: :delete_all
  		add :status, :boolean, default: false
  		add :code, :integer, null: false
  	end
    
    create index(:forgot_passwords, [:code])
  end

  def down do
    drop index(:forgot_passwords, [:code])
  	drop table(:forgot_passwords)
  end
end
