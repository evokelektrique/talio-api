defmodule Talio.Repo.Migrations.AddNameToSnapshots do
  use Ecto.Migration

  def up do
    alter table(:snapshots) do
      add :name, :string, null: false
    end
  end

  def down do
    alter table(:snapshots) do
      remove :name
    end
  end
end
