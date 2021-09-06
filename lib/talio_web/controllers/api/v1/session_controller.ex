defmodule TalioWeb.API.V1.SessionController do
  use TalioWeb, :controller

  alias Talio.Accounts.User

  action_fallback TalioWeb.API.V1.FallbackController

  def sign_in(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
        ## Optional on MVP
        # if user.is_verified do
        {:ok, jwt, _full_claims} = Talio.Guardian.encode_and_sign(user, %{}, token_type: "access")

        conn
        |> put_status(:created)
        |> render("sign_in.json", user: user, jwt: jwt)

      # else
      #   conn
      #   |> put_status(:forbidden)
      #   |> render("verification.json", user: user)
      # end

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", %{reason: reason})
    end
  end
end
