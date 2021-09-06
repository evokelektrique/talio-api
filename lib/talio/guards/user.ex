defmodule Talio.Guards.User do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User

  # Admins can list anything
  def authorize(_, %User{is_admin: 1} = _user, _params), do: :ok

  # Otherwise, denied
  def authorize(:list_users, _user, _params), do: :error
end
