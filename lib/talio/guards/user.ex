defmodule Talio.Guards.User do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User

  # Admins can list anything
  def authorize(_, %User{role: 0} = _user, _params), do: :ok

  # Otherwise, denied
  def authorize(:list_users, _user, _params), do: :error
end
