defmodule Talio.Accounts.ForgotPassword do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import TalioWeb.Gettext

  alias __MODULE__
  alias Talio.{Repo, Accounts.User}

  schema "forgot_passwords" do
    field :code, :integer, null: false
    field :status, :boolean, default: false

    belongs_to :user, User
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :status])
    |> validate_required([:code, :status])
  end

  def find_and_change_password(%{email: email, code: code, password: password}) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        query = from(rp in ForgotPassword, where: [code: ^code, user_id: ^user.id, status: false])

        case Repo.one(query) do
          nil ->
            {:error, :invalid_code}

          code ->
            change_code_status(user, code, password)
        end
    end
  end

  def change_code_status(user, code, password) do
    changeset =
      user
      |> change(password: password)
      |> User.registration_changeset()

    case Repo.update(changeset) do
      {:ok, user} ->
        code
        |> change(%{status: true})
        |> Repo.update()

        {:ok, user}

      {:error, changeset} ->
        {:changeset_error, changeset}
    end
  end

  def find_and_verify_code(%{email: email, code: code}) do
    # Find User
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        query = from(c in ForgotPassword, where: [code: ^code, user_id: ^user.id, status: false])

        # Find Code
        case Repo.one(query) do
          nil ->
            {:error, :invalid_code}

          code ->
            {:ok, code}
        end
    end
  end
end
