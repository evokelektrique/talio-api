defmodule Talio.Guards.Category do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User

  # Admins can list anything
  def authorize(:admin_category, %User{role: 0} = _user, _params), do: :ok

  # Otherwise, denied
  def authorize(:admin_category, _user, _params), do: :error
end
