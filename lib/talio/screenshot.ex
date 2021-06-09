defmodule Talio.Screenshot do
  @doc """
  Talio Screenshot
  """

  require Logger

  @config Application.fetch_env!(:talio, :screenshot)

  def take(args \\ %{}) do
    path = @config.url.path
    args = Map.put(args, :secret_key, @config.secret_key)

    # Configure Subdomain From Fandogh Service Name
    url =
      TalioWeb.Endpoint.struct_url()
      |> Map.put(:host, @config.url.host)
      |> Map.put(:port, @config.url.port)
      |> Map.put(:path, path)
      |> Map.put(:query, URI.encode_query(args))
      |> to_string

    Logger.warning(args)

    case HTTPoison.get(url, [], recv_timeout: args[:recv_timeout], timeout: args[:timeout]) do
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
        Logger.error(reason)
        {:error, reason}
    end
  end
end