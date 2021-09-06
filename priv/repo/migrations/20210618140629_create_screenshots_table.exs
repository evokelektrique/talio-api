defmodule Talio.Repo.Migrations.CreateScreenshotsTable do
  use Ecto.Migration

  def up do
    create table(:screenshots) do
      # Status
      # 0: None
      # 1: Complete
      add :status, :integer, default: 0, null: false
      add :device, :integer, null: false

      add :branch_id, references(:branches, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:screenshots, [:branch_id, :device])
    create index(:screenshots, [:status])
    create index(:screenshots, [:device])
  end

  def down do
    drop unique_index(:screenshots, [:branch_id, :device])
    drop index(:screenshots, [:status])
    drop index(:screenshots, [:device])
    
    drop table(:screenshots)
  end
end
