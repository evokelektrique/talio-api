defmodule Talio.Branch do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext
  import Ecto.Query

  require Logger

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
    has_many :elements, Element, on_delete: :delete_all

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

    total_branches =
      Repo.one(
        from branch in Branch,
          join: s in Snapshot,
          on: s.id == ^snapshot.id,
          select: count("*")
      )

    case snapshot.type do
      0 ->
        if total_branches == 0 || is_nil(branch) do
          branch =
            %Branch{}
            |> changeset(create_attrs)
            |> put_assoc(:website, website)
            |> put_assoc(:snapshot, snapshot)
            |> Repo.insert!()

          {:created, branch}
        else
          {:found, branch}
        end

      1 ->
        if branch === nil do
          branch =
            %Branch{}
            |> changeset(create_attrs)
            |> put_assoc(:website, website)
            |> put_assoc(:snapshot, snapshot)
            |> Repo.insert!()

          {:created, branch}
        else
          {:found, branch}
        end
    end
  end

  # Enqueue Screenshot Job
  def take_screenshot(snapshot, branch, options) do
    config = Application.fetch_env!(:talio, :screenshot)
    device_type = Map.get(options, :device_type)
    key = "#{snapshot.id}_#{branch.fingerprint}_#{device_type}"
    bucket = config.s3.bucket

    # Insert Job
    %{key: key, options: options}
    |> Talio.Jobs.Screenshot.new()
    |> Oban.insert()
  end
end
