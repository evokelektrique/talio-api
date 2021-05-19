defmodule Talio.Website do
  use Ecto.Schema

  import Ecto.Changeset
  import TalioWeb.Gettext

  alias Talio.{
    Category,
    Snapshot,
    Accounts.User,
    Transaction
  }

  @timestamps_opts [type: :utc_datetime]

  schema "websites" do
    field :name, :string
    field :url, :string
    field :is_verified, :boolean, default: false

    belongs_to :category, Category, on_replace: :nilify
    belongs_to :user, User
    has_many :snapshots, Snapshot, on_delete: :delete_all

    has_one :transaction, Transaction

    timestamps()
  end

  def changeset(website, params \\ %{}) do
    website
    |> cast(params, [:name, :url])
    |> validate_required([:name, :url])
    |> update_change(:url, &String.downcase/1)
    |> unique_constraint([:url, :user_id])
    |> validate_changeset()
  end

  def verify_changeset(website, params \\ %{}) do
    website
    |> cast(params, [:name, :url, :is_verified])
    |> validate_required([:name, :url])
    |> update_change(:url, &String.downcase/1)
    |> validate_changeset()
  end

  # Captures the talio.js script tag in the body
  def matched?(body) do
    Regex.match?(~r/<script.*?src='(.*?).(talio.js)'/, body)
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:name, min: 1, max: 255)
    |> valid_website?
  end

  defp valid_website?(changeset) do
    case fetch_change(changeset, :url) do
      {:ok, url} ->
        uri = URI.parse(url)

        if uri.scheme != nil && uri.host =~ "." do
          changeset
        else
          changeset
          |> add_error(:url, gettext("Invalid website format"))
        end

      _ ->
        changeset
    end
  end
end