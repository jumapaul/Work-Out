defmodule WorkOut2Web.Router do
  use WorkOut2Web, :router
  alias WorkOut2.Guardian
  alias WorkOut2.Auth.RequireRolePipeline
  alias WorkOut2.Auth.RefreshAuthPipeline

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  pipeline :admins_only do
    plug RequireRolePipeline, roles: [:admin]
  end

  pipeline :refresh do
    plug RefreshAuthPipeline
  end

  scope "/api", WorkOut2Web do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/api/v1", WorkOut2Web do
    pipe_through :api
    post "/sign_up", UserController, :create_user
    post "/sign_in", UserController, :sign_in
    post "/verify_email", UserController, :verify_email
    get "/reset_code/:id", UserController, :send_reset_pass_code
    post "/reset_password", UserController, :reset_password
    get "/resend_verification_code/:id", UserController, :resend_verification_code
  end

  scope "/api/v1", WorkOut2Web do
    pipe_through [:api, :refresh]
    get "/refresh", UserController, :refresh_token
  end

  scope "/api/v1", WorkOut2Web do
    pipe_through [:api, :jwt_authenticated, :admins_only]
    get "/users", UserController, :index
  end

  scope "/api/v1", WorkOut2Web do
    pipe_through [:api, :jwt_authenticated]
    delete "/logout", UserController, :logout
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:work_out_2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: WorkOut2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
