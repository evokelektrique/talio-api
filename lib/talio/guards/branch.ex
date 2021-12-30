defmodule Talio.Guards.Branch do
  @moduledoc """
  Fix it up, Need improvement
  """
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User
  alias Talio.Branch

  # Admins can list anything
  def authorize(:user_branch, %User{is_admin: true} = _user, _params), do: :ok

  # Users can list their own websites
  def authorize(
        :user_branch,
        %Branch{id: branch_id} = _branch,
        %{branch_id: branch_id} = _params
      ),
      do: :ok

  # Otherwise, denied
  def authorize(:user_branch, _user, _params), do: :error
end
