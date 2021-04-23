defmodule TalioWeb.API.V1.SessionView do
  use TalioWeb, :view

  def render("sign_in.json", %{user: user, jwt: jwt}) do
    %{
      status: :ok,
      data: %{
        token: jwt,
        user: %{
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          is_verified: user.is_verified
        }
      },
      message: gettext("Logged in successfully !")
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :not_found ->
        %{status: reason, message: gettext("User not found")}

      :unauthorized ->
        %{status: reason, message: gettext("Credential Error")}
    end
  end

  def render("verification.json", %{user: user}) do
    %{
      status: :not_verified,
      message: gettext("User email is not verified")
    }
  end
end
