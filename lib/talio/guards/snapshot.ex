defmodule Talio.Guards.Snapshot do
  @behaviour Bodyguard.Policy

  alias Talio.Accounts.User
  alias Talio.Website

  # Admins can list anything
  def authorize(:user_snapshot, %User{role: 0} = _user, _params), do: :ok

  # Users can list their own websites
  def authorize(
        :user_snapshot,
        %Website{id: website_id} = _website,
        %{website_id: website_id} = _params
      ),
      do: :ok

  # Otherwise, denied
  def authorize(:user_snapshot, _user, _params), do: :error
end
