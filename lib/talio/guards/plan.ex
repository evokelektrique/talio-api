defmodule Talio.Guards.Plan do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User

  # Admins can list anything
  def authorize(:admin_plan, %User{role: 0} = _user, _params), do: :ok

  # Otherwise, denied
  def authorize(:admin_plan, _user, _params), do: :error
end
