defmodule Talio.Click do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Element
  }

  @required_params [:x, :y, :talio_user_id]

  schema "clicks" do
    field :x, :integer
    field :y, :integer
    field :talio_user_id, :integer

    belongs_to :element, Element

    timestamps()
  end

  def changeset(click, params \\ %{}) do
    click
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:x, :talio_user_id])
    |> unique_constraint([:y, :talio_user_id])
  end
end
