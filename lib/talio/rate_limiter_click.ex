defmodule Talio.RateLimiterClick do
  use GenServer
  require Logger

  @table_name :talio_rate_limit_clicks_cache

  ## Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick(talio_user_id) do
    case get_or_store_limit(talio_user_id) do
      count when count > 5 ->
        {:error, :rate_limited}

      _count ->
        increment_limit(talio_user_id, 1)
        :ok
    end
  end

  ## Server

  def init(_) do
    {:ok, %{}}
  end

  defp increment_limit(talio_user_id, count) do
    ConCache.update(@table_name, talio_user_id, fn old_value ->
      new_value = old_value + count
      # Logger.debug("Old value: #{inspect(old_value)} | New Value: #{inspect(new_value)}")
      {:ok, new_value}
    end)
  end

  defp get_or_store_limit(talio_user_id) do
    ConCache.get_or_store(@table_name, talio_user_id, fn ->
      0
    end)
  end
end
