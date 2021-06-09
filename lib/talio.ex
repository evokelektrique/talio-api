defmodule Talio do
  @moduledoc """
  Talio keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @nonce_length 32

  def generate_nonce(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  # Find Cached Nonce Or Store A New Nonce For Given User
  def get_or_store_nonce(length \\ @nonce_length, talio_user_id) do
    nonce = Talio.generate_nonce(length)
    ConCache.get_or_store(:talio_nonce_cache, talio_user_id, fn -> nonce end)
  end
end
