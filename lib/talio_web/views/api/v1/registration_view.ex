defmodule TalioWeb.API.V1.RegistrationView do
  use TalioWeb, :view

  def render("success.json", %{user: user}) do
    %{
      status: :ok,
      message:
        gettext("Registration Successfull! A Verification email sent to your email address"),
      data: %{
        user: %{
          id: user.id,
          email: user.email,
          full_name: user.full_name
        }
      }
    }
  end

  def render("verified.json", %{user: user}) do
    %{
      status: :ok,
      message: gettext("Your account successfully verified"),
      data: %{
        user: %{
          id: user.id,
          email: user.email,
          full_name: user.full_name
        }
      }
    }
  end

  def render("code.json", %{user: user}) do
    %{
      status: :ok,
      message: gettext("Code Successfully Sent To your Email"),
      data: %{
        user: %{
          id: user.id,
          email: user.email
          # full_name: user.full_name
        }
      }
    }
  end

  def render("error.json", %{reason: reason}) do
    case reason do
      :not_found ->
        %{status: reason, message: gettext("User not found")}

      :invalid_code ->
        %{status: reason, message: gettext("Invalid code")}

      :expired_code ->
        %{status: reason, message: gettext("Expired code")}
    end
  end
end
