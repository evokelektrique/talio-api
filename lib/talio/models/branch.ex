defmodule Talio.Branch do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Snapshot,
    Accounts.User
  }

  schema "branches" do
    field :fingerprint, :string

    belongs_to :snapshot, Snapshot

    timestamps()
  end

  def changeset(branch, params \\ %{}) do
    branch
    |> cast(params, [:fingerprint])
    |> validate_required([:fingerprint])
  end
end
