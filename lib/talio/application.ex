defmodule Talio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Talio.Repo,
      # Start the Telemetry supervisor
      TalioWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Talio.PubSub},
      # Start the Endpoint (http/https)
      TalioWeb.Endpoint,
      # Guardian
      {Guardian.DB.Token.SweeperServer, []},
      # Oban (Job Process)
      {Oban, oban_config()},
      # Nonce Cache
      con_cache_child_spec(
        :talio_nonce_cache,
        :timer.seconds(1),
        :timer.minutes(1),
        true
      ),
      # Rate Limit Clicks Cache
      con_cache_child_spec(
        :talio_rate_limit_clicks_cache,
        :timer.seconds(1),
        :timer.seconds(10),
        false
      ),
      # Branches Cache
      con_cache_child_spec(
        :talio_branches_cache,
        :timer.seconds(1),
        :timer.minutes(5),
        true
      ),
      # Rate Limit Clicks GenServer
      Talio.RateLimiterClick
    ]

    # Attach Oban's Logger
    :ok = Oban.Telemetry.attach_default_logger()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Talio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TalioWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp con_cache_child_spec(name, ttl_check_interval, global_ttl, touch_on_read) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: ttl_check_interval,
          global_ttl: global_ttl,
          touch_on_read: touch_on_read
        ]
      },
      id: {ConCache, name}
    )
  end

  # Conditionally disable queues or plugins here.
  defp oban_config do
    Application.fetch_env!(:talio, Oban)
  end
end
