defmodule TalioWeb.API.V1.ForgotPasswordView do
  use TalioWeb, :view

  def render("success.json", %{code: code}) do
    %{
      status: :ok,
      message: gettext("Forgot Password Code successfully sent to user's email")
    }
  end

  def render("confirm.json", %{user: user}) do
    %{
      status: :ok,
      message: gettext("Password successfully changed")
    }
  end

  def render("found_code.json", _) do
    %{
      status: :ok,
      message: gettext("Valid Code")
    }
  end

  def render("invalid_found_code.json", %{reason: reason}) do
    %{
      status: reason,
      message: gettext("Invalid Code")
    }
  end
end
