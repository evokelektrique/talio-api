defmodule Talio.Repo.Migrations.AddEmailVerificationToUsers do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :is_verified, :boolean, default: false
  	end
  end
end
