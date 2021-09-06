defmodule Talio.Click do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Element,
    Branch
  }

  @required_params [:x, :y, :talio_user_id, :path, :device]

  schema "clicks" do
    field :x, :integer
    field :y, :integer
    field :talio_user_id, :integer
    field :path, :string
    ## Device Types:
    # 0 => Desktop
    # 1 => Tablet
    # 2 => Mobile
    field :device, :integer

    belongs_to :branch, Branch

    timestamps()
  end

  def changeset(click, params \\ %{}) do
    click
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:x, :y, :talio_user_id, :device])
  end
end
