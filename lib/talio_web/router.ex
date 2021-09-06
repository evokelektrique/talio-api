defmodule TalioWeb.Router do
  use TalioWeb, :router

  # Guardian Pipeline
  pipeline :authorized do
    plug Guardian.Plug.Pipeline,
      module: Talio.Guardian,
      error_handler: Talio.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :unauthorized do
    plug Guardian.Plug.EnsureNotAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # UnAuthorized Scope
  scope "/", TalioWeb.API, as: :api do
    pipe_through [:api, :unauthorized]

    scope "/v1", V1, as: :v1 do
      scope "/auth", as: :auth do
        post "/sign_up", RegistrationController, :sign_up
        post "/resend_code", RegistrationController, :resend_code
        post "/verify", RegistrationController, :verify
        post "/sign_in", SessionController, :sign_in
        post "/forgot_password", ForgotPasswordController, :index
        post "/forgot_password/verify_code", ForgotPasswordController, :verify_code
        post "/forgot_password/confirm", ForgotPasswordController, :confirm
      end
    end
  end

  # Custom Authorized Scope
  scope "/internals", TalioWeb.Internals, as: :internals do
    pipe_through [:api]

    resources "/elements", ElementsController, except: [:new, :index, :show, :delete]
  end

  # Authorized Scope
  scope "/", TalioWeb.API, as: :api do
    pipe_through [:api, :authorized]

    scope "/v1", V1, as: :v1 do
      resources "/users", UserController, except: [:new, :edit]

      get "/websites/:id/verify", WebsiteController, :verify

      resources "/websites", WebsiteController, except: [:new] do
        resources "/snapshots", SnapshotController, except: [:new] do
          get "/branches/:branch_id/elements/:device", BranchController, :elements
          get "/branches/:branch_id/clicks/:device", BranchController, :clicks
          # resources "/branches", BranchController do
          #   get "/clicks", BranchController, :clicks
          # end
        end
      end

      resources "/categories", CategoryController, except: [:new]
      resources "/plans", PlanController, except: [:new]
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: TalioWeb.Telemetry, ecto_repos: [Talio.Repo]
    end
  end
end
