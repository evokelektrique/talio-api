defmodule Talio.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  # import TalioWeb.Gettext

  alias Talio.{
    Accounts.User,
    Website,
    Plan
  }

  @required_params [:expire]
  @cast_params [:expire]

  schema "transactions" do
    field :expire, :utc_datetime
    field :status, :boolean, default: false

    belongs_to :user, User
    belongs_to :website, Website
    belongs_to :plan, Plan

    timestamps()
  end

  def changeset(transaction, params \\ %{}) do
    transaction
    |> cast(params, @cast_params)
    |> validate_required(@required_params)

    # |> check_plan_free()
  end

  def check_plan_free(changeset) do
  end
end
