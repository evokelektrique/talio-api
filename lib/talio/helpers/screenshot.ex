defmodule Talio.Helpers.Screenshot do
  @moduledoc """
  Talio Screenshot
  """
  @moduledoc since: "0.9.0"

  require Logger

  def take(args \\ %{}) do
    config = Application.fetch_env!(:talio, :screenshot)
    path = config.url.path
    args = Map.put(args, :secret_key, config.secret_key)

    # Configure Subdomain From Fandogh Service Name
    url =
      TalioWeb.Endpoint.struct_url()
      |> Map.put(:host, config.url.host)
      |> Map.put(:port, config.url.port)
      |> Map.put(:path, path)
      |> Map.put(:query, URI.encode_query(args))
      |> to_string

    # Timeouts don't work here, Idk why?
    # `case HTTPoison.get(url, [], recv_timeout: args[:recv_timeout], timeout: args[:timeout]) do`
    # This looks fine to me tho
    # Update: Yeah it looks fine when we use static numbers/timeouts,
    # maybe Oban does not serialize it correctly idk
    # 
    case HTTPoison.get(url, [], recv_timeout: 120_000, timeout: 120_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Screenshot Taken From #{args["url"]}")
        {:ok, image: body}

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        Logger.warning(body)
        {:error, body}

      {:ok, %HTTPoison.Response{status_code: 408, body: body}} ->
        Logger.warning(body)
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("TIMEOUT REASON? OR MAYBE SERVER IS SHUTDOWN?")
        {:error, reason}
    end
  end
end
