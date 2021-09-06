defmodule Talio.Accounts.VerificationCode do
  use Ecto.Schema

  alias Talio.Accounts.User

  schema "verification_codes" do
    field :code, :integer
    field :is_expired, :boolean, default: false

    belongs_to :user, User

    timestamps()
  end

  # Returns a random generated number between 1000 to 9999
  def generate() do
    Enum.random(1_000..9_999)
  end
end
