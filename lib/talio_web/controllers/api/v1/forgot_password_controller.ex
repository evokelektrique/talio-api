defmodule TalioWeb.API.V1.ForgotPasswordController do
  use TalioWeb, :controller

  alias Talio.{Repo, Accounts.User, Accounts.ForgotPassword, Email, Mailer}

  # Step one, Find user by given email & Send a random generated number to user's email
  def index(conn, %{"user" => user_params}) do
    case Repo.get_by(User, email: user_params["email"]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.API.V1.RegistrationView)
        |> render("error.json", reason: :not_found)

      user ->
        changeset =
          user |> Ecto.build_assoc(:forgot_passwords, %{code: Enum.random(1_000..9_999)})

        case Repo.insert(changeset) do
          {:ok, code} ->
            Email.send_forgot_password_code(%{
              code: code.code,
              subject: "Test Subject Forgot Password Verify code",
              to: user.email
            })
            |> Mailer.deliver_later()

            # Render Confirmation Requirments
            conn
            |> put_status(:created)
            |> render("success.json", code: code)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(TalioWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  # Step two, Verify the user's given email & code
  def verify_code(conn, %{"user" => user_params}) do
    case ForgotPassword.find_and_verify_code(%{
           email: user_params["email"],
           code: user_params["code"]
         }) do
      # Valid
      {:ok, _code} ->
        conn
        |> put_status(:ok)
        |> put_view(TalioWeb.API.V1.ForgotPasswordView)
        |> render("found_code.json")

      # Invalid
      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.API.V1.ForgotPasswordView)
        |> render("invalid_found_code.json", reason: reason)
    end
  end

  # Step Three, Confirm the given code & Change the user's password
  def confirm(conn, %{"user" => user_params}) do
    case ForgotPassword.find_and_change_password(%{
           email: user_params["email"],
           code: user_params["code"],
           password: user_params["password"]
         }) do
      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> put_view(TalioWeb.API.V1.RegistrationView)
        |> render("error.json", reason: reason)

      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("confirm.json", user: user)

      {:changeset_error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(TalioWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
