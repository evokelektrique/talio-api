# General application configuration
use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :talio,
  ecto_repos: [Talio.Repo]

# Migrations With Timestamp
config :talio, Talio.Repo, migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :talio, TalioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2kIqsSIphLYZB9hkzA3uCJ9dUPx+qZSxi0jEO2ViQNpXGONqNtRVp9j3d4d93nav",
  render_errors: [view: TalioWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Talio.PubSub,
  live_view: [signing_salt: "e8NC1EdU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :talio, Talio.Guardian,
  issuer: "talio",
  ttl: {30, :days},
  token_module: Guardian.Token.Jwt,
  secret_key: "Ryng3gcfdDkTBKuKvfRrWSZgb+/Svvff9O6YYhs0CXTN2tkaA//j+zs9OFZuyakO"

config :guardian, Guardian.DB,
  repo: Talio.Repo,
  schema_name: "guardian_tokens",
  # token_types: ["refresh_token"],
  sweep_interval: 60

# Gettext
config :talio, TalioWeb.Gettext, locales: ~w(fa en), default_locale: "fa"

# Bamboo
config :talio, Talio.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "mail.talio.ir",
  port: 587,
  username: "noreply@talio.ir",
  password: "Emjp9JrD",
  tls: :never,
  ssl: false,
  retries: 5

# Hammer(Rate Limit)
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

## MinIO
config :ex_aws,
  debug_requests: true,
  region: "local"

# S3
config :ex_aws, :s3, %{
  access_key_id: "minioadmin",
  secret_access_key: "minioadmin",
  scheme: "http://",
  host: "localhost",
  port: 9000
}

# Oban (Job Process)
config :talio, Oban,
  repo: Talio.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 600}],
  queues: [snapshots: 1]

# # Swagger Docs
# config :talio, :phoenix_swagger,
#   swagger_files: %{
#     "priv/static/swagger.json" => [
#       router: TalioWeb.Router,
#       endpoint: TalioWeb.Endpoint
#     ]
#   }

# config :phoenix_swagger, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
