defmodule Talio.Guards.Website do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User

  # Admins can list anything
  def authorize(:user_website, %User{is_admin: true} = _user, _params), do: :ok

  # Users can list their own websites
  def authorize(:user_website, %User{id: user_id} = _user, %{user_id: user_id} = _params),
    do: :ok

  # Otherwise, denied
  def authorize(:user_website, _user, _params), do: :error
end
