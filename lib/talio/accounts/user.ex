defmodule Talio.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import TalioWeb.Gettext

  alias Talio.{
    Repo,
    Accounts.VerificationCode,
    Accounts.User,
    Accounts.ForgotPassword,
    Website
  }

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :role, :integer, default: 1
    field :password, :string, virtual: true
    field :password_hash, :string
    field :is_verified, :boolean, default: false

    has_many :verification_codes, VerificationCode
    has_many :forgot_passwords, ForgotPassword
    has_many :websites, Website

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:full_name, :password_hash, :email, :role])
    |> validate_required([:full_name, :password_hash, :email, :role])
  end

  def registration_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:full_name, :password, :email])
    |> validate_required([:full_name, :password, :email])
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> validate_changeset()
  end

  def find_and_confirm_password(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  def verify(%{email: email, code: code}) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        if user.is_verified do
          {:verified, user}
        else
          query = from(c in VerificationCode, where: [code: ^code, user_id: ^user.id])

          case Repo.one(query) do
            nil ->
              {:error, :invalid_code}

            code ->
              {:ok, user} =
                user
                |> change(%{is_verified: true})
                |> Repo.update()

              {:ok, user}
          end
        end
    end
  end

  @doc false
  def verify(%{user: user, email: _, code: _}) do
    nil
  end

  defp validate_changeset(struct) do
    struct
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*/,
      message:
        gettext("Must include at least one lowercase letter, one uppercase letter, and one digit")
    )
    |> generate_password_hash
  end

  defp generate_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
