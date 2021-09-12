defmodule Talio.Screenshot do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import TalioWeb.Gettext

  alias __MODULE__

  alias Talio.{
    Branch,
    Repo
  }

  @required_params [:status, :device]

  schema "screenshots" do
    # Screenshot status:
    # 0: In queue
    # 1: Completed
    field :status, :integer, default: 0
    field :device, :integer, null: false

    belongs_to :branch, Branch

    timestamps()
  end

  def changeset(screenshot, params \\ %{}) do
    screenshot
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:branch_id, :device])
  end

  def find_or_create(branch_id, find_attrs \\ [], create_attrs \\ %{}, branch) do
    filters = Map.take(create_attrs, find_attrs) |> Map.to_list()

    query =
      from(
        screenshot in Screenshot,
        where: ^filters,
        where: screenshot.branch_id == ^branch_id,
        join: branch in Branch,
        on: branch.id == screenshot.branch_id
      )

    screenshot = Repo.one(query)

    if is_nil(screenshot) do
      %Screenshot{}
      |> changeset(create_attrs)
      |> put_assoc(:branch, branch)
      |> Repo.insert!()
    else
      screenshot
    end
  end
end
