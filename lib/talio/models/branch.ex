defmodule Talio.Branch do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext
  import Ecto.Query

  alias __MODULE__

  alias Talio.{
    Repo,
    Website,
    Snapshot,
    Element
  }

  schema "branches" do
    field :fingerprint, :string

    belongs_to :snapshot, Snapshot
    belongs_to :website, Website
    has_many :elements, Element

    timestamps()
  end

  def changeset(branch, params \\ %{}) do
    branch
    |> cast(params, [:fingerprint])
    |> validate_required([:fingerprint])
  end

  def find_or_create(website, snapshot, find_attrs \\ [], create_attrs \\ %{}) do
    filters = Map.take(create_attrs, find_attrs) |> Map.to_list()
    query = from(b in Branch, where: ^filters)
    branch = Repo.one(query)

    if branch === nil do
      %Branch{}
      |> changeset(create_attrs)
      |> put_assoc(:website, website)
      |> put_assoc(:snapshot, snapshot)
      |> Repo.insert()
    else
      branch
    end
  end
end
