defmodule Talio.Plan do
  use Ecto.Schema

  import Ecto.Changeset
  # import TalioWeb.Gettext

  @required_params [:name, :duration, :price, :limits]
  @cast_params [:name, :duration, :price, :limits]

  @default_limits %{
    "snapshot" => %{
      "page_view" => 1000
    }
  }

  schema "plans" do
    field :name, :string
    field :duration, :integer
    field :price, :integer, default: 0
    field :limits, :map, default: @default_limits

    # has_many :transactions, Website

    timestamps()
  end

  def changeset(plan, params \\ %{}) do
    plan
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
  end
end
