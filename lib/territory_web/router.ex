defmodule TerritoryWeb.Router do
  use TerritoryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TerritoryWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_unique_id
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TerritoryWeb do
    pipe_through :browser

    live_session :default do
      live "/", PageLive
      live "game_over", GameOverLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TerritoryWeb do
  #   pipe_through :api
  # end

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
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TerritoryWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp put_unique_id(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        user_id = :crypto.strong_rand_bytes(8) |> Base.encode64()
        put_session(conn, :user_id, user_id)

      _ ->
        conn
    end
  end
end
