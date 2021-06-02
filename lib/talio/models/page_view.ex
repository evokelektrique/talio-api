defmodule Talio.PageView do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Website,
    Snapshot
  }

  @required_params [:talio_user_id]

  schema "page_views" do
    field :talio_user_id, :integer

    belongs_to :snapshot, Snapshot

    timestamps()
  end

  def changeset(page_view, params \\ %{}) do
    page_view
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:snapshot_id, :talio_user_id])
  end
end
