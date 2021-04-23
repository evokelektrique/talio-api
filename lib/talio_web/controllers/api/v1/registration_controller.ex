defmodule TalioWeb.API.V1.RegistrationController do
  use TalioWeb, :controller

  alias Talio.{Accounts, Accounts.User, Accounts.VerificationCode, Email, Mailer}
  alias Talio.Repo

  action_fallback TalioWeb.API.V1.FallbackController

  # # Rate Limits
  # plug Hammer.Plug,
  #      [
  #        rate_limit: {"registration:resend_code", 10_000, 1}
  #      ]
  #      when action == :resend_code

  def sign_up(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      # Registration Successful
      {:ok, user} ->
        # Generate a Verification Code Then Send It To User's Email
        code = VerificationCode.generate()
        code = Ecto.build_assoc(user, :verification_codes, %{code: code})

        # Save the code 
        Repo.insert!(code)

        Email.send_verification_code(%{
          code: code.code,
          subject: "Test Subject Registration Verify code",
          to: user.email
        })
        |> Mailer.deliver_later()

        # Render Confirmation Requirments
        conn
        |> put_status(:created)
        |> render("success.json", user: user)

      # Error In Changeset
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(TalioWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  # Generates a random number and sends it to user's email
  def resend_code(conn, %{"user" => user_params}) do
    # Fetch user by given email
    user = Repo.get_by(User, email: user_params["email"])

    case user do
      user ->
        # Generate random code
        code = VerificationCode.generate()
        code = Ecto.build_assoc(user, :verification_codes, %{code: code})

        # Save the code 
        Repo.insert!(code)

        # Send verification email
        Email.send_verification_code(%{
          code: code.code,
          subject: "Test Subject Registration Verify code",
          to: user.email
        })
        |> Mailer.deliver_later()

        conn
        |> put_status(:created)
        |> render("code.json", user: user)

      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", reason: :not_found)
    end
  end

  # Verifies the user
  def verify(conn, %{"user" => user_params}) do
    case User.verify(%{email: user_params["email"], code: user_params["code"]}) do
      {:verified, user} ->
        conn
        |> put_status(:created)
        |> render("verified.json", user: user)

      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("verified.json", user: user)

      {:error, reason} ->
        conn
        |> put_status(:forbidden)
        |> render("error.json", reason: reason)
    end
  end
end
