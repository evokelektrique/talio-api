defmodule Talio.Snapshot do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Website,
    Branch,
    Accounts.User
  }

  @types %{
    0 => gettext("Dynamic"),
    1 => gettext("Static")
  }

  schema "snapshots" do
    field :type, :integer, default: 0
    field :status, :integer, default: 0
    field :path, :string
    field :name, :string

    belongs_to :website, Website
    has_many :branches, Branch

    timestamps()
  end

  def changeset(snapshot, params \\ %{}) do
    snapshot
    |> cast(params, [:name, :path, :type])
    |> validate_required([:name, :path, :type])
    |> validate_changeset()
    |> unique_constraint([:path, :website_id])
  end

  def get_type(type), do: @types[type]

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:name, min: 1, max: 255)
    |> update_change(:path, &String.trim/1)
  end
end
