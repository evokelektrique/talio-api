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
    Element,
    Screenshot,
    Click
  }

  @required_params [:fingerprint]

  schema "branches" do
    field :fingerprint, :string

    belongs_to :snapshot, Snapshot
    belongs_to :website, Website
    has_many :elements, Element, on_delete: :delete_all
    has_many :screenshots, Screenshot, on_delete: :delete_all
    has_many :clicks, Click, on_delete: :delete_all

    timestamps()
  end

  def changeset(branch, params \\ %{}) do
    branch
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  def find_or_create(website, snapshot, find_attrs \\ [], create_attrs \\ %{}) do
    filters = Map.take(create_attrs, find_attrs) |> Map.to_list()
    query = from(b in Branch, where: ^filters)
    branch = Repo.one(query)

    # Reason: Snapshot type (static, dynamic)
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
          %Branch{}
          |> changeset(create_attrs)
          |> put_assoc(:website, website)
          |> put_assoc(:snapshot, snapshot)
          |> Repo.insert()
        else
          {:ok, branch}
        end

      1 ->
        if branch === nil do
          %Branch{}
          |> changeset(create_attrs)
          |> put_assoc(:website, website)
          |> put_assoc(:snapshot, snapshot)
          |> Repo.insert()
        else
          {:ok, branch}
        end
    end
  end

  # Enqueue Screenshot Job
  def take_screenshot(snapshot, branch, options) do
    # Screenshot device
    device_type = Map.get(options, :device_type)
    # S3 Filename key
    key = Screenshot.get_s3_key(snapshot.id, branch.fingerprint, device_type)

    # Create screenshot statuses
    screenhsot_find_params = [:device]

    screenhsot_create_params = %{
      device: device_type,
      # In Queue
      status: 0,
      # S3 Filename key
      key: key
    }

    screenshot =
      Screenshot.find_or_create(
        branch.id,
        screenhsot_find_params,
        screenhsot_create_params,
        branch
      )

    if screenshot.status === 0 do
      # Insert Job
      %{key: key, options: options, screenshot_id: screenshot.id}
      |> Talio.Jobs.Screenshot.new()
      |> Oban.insert()
    end
  end

  # Check if branch screenshots are all complete 
  def is_screenshot_complete!(screenshot) do
    query =
      from screenshot in Talio.Screenshot,
        where: screenshot.status == 0,
        select: count(screenshot.id)

    if Repo.all(query) |> List.first() > 0, do: false, else: true
  end
end
