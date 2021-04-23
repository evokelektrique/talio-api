defmodule Talio.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: TalioWeb.EmailView

  @emails emails: %{
            no_reply: "noreply@talio.ir"
          }

  def send_verification_code(%{to: to, subject: subject, code: code} = params) do
    new_email()
    |> to(to)
    |> from(@emails.no_reply)
    |> subject(subject)
    |> put_html_layout({TalioWeb.LayoutView, "email.html"})
    |> render("verification.html", params)
  end

  def send_forgot_password_code(%{to: to, subject: subject, code: code} = params) do
    new_email()
    |> to(to)
    |> from(@emails.no_reply)
    |> subject(subject)
    |> put_html_layout({TalioWeb.LayoutView, "email.html"})
    |> render("forgot_password_verification.html", params)
  end
end
