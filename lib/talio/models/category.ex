defmodule Talio.Category do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.Website

  schema "categories" do
    field :name, :string

    has_many :websites, Website

    timestamps()
  end

  def changeset(category, params \\ %{}) do
    category
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
