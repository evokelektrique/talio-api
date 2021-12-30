# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

db_host =
  System.get_env("DATABASE_HOST") ||
    raise """
    environment variable DATABASE_HOST is missing.
    """

db_database = System.get_env("DATABASE_DB") || "talio_prod"
db_username = System.get_env("DATABASE_USER") || "postgres"
db_password = System.get_env("DATABASE_PASSWORD") || "postgres"
db_url = "ecto://#{db_username}:#{db_password}@#{db_host}/#{db_database}"

config :talio, Talio.Repo,
  # ssl: true,
  url: db_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :talio, TalioWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# Fandogh Screenshot service
screenshot_secrey_key =
  System.get_env("SCREENSHOT_SECRET_KEY") ||
    raise "environment variable SCREENSHOT_SECRET_KEY is missing."

config :talio, :screenshot, %{
  url: %{host: "screenshot.talio.ir", port: 80, path: "/"},
  s3: %{bucket: "screenshots"},
  secret_key: screenshot_secrey_key
}

## MinIO
config :ex_aws,
  debug_requests: true,
  region: "local"

minio_access_key =
  System.get_env("MINIO_ACCESS_KEY") ||
    raise """
    environment variable MINIO_ACCESS_KEY is missing.
    """

minio_secret_access_key =
  System.get_env("MINIO_SECRET_ACCESS_KEY") ||
    raise """
    environment variable MINIO_SECRET_ACCESS_KEY is missing.
    """

# S3
config :ex_aws, :s3, %{
  access_key_id: minio_access_key,
  secret_access_key: minio_secret_access_key,
  scheme: "https://",
  host: "s3.talio.ir"
}

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :talio, TalioWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
