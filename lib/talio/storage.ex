defmodule Talio.Storage do
  @doc """
  S3 Object Storage Helper
  """

  alias ExAws.S3

  def get(bucket, destination, params \\ [expires_in: 3600]) do
    query_params = [{"ACL", "public-read"}]

    presign_options = [
      virtual_host: false,
      query_params: query_params
    ]

    config = get_config()

    ExAws.S3.presigned_url(
      config,
      :get,
      bucket,
      destination,
      presign_options ++ params
    )
  end

  def upload(bucket, destination, contents) do
    S3.put_object(bucket, destination, contents) |> ExAws.request!()
  end

  def exists?(bucket, destination) do
    case S3.get_object(bucket, destination) |> ExAws.request() do
      {:error, _reason} -> :error
      {:ok, object} -> :ok
    end
  end

  defp get_config() do
    ExAws.Config.new(:s3)
  end
end
