defmodule TerritoryWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :territory,
    pubsub_server: Territory.PubSub

  def fetch(_topic, presences) do
    for {key, %{metas: metas}} <- presences, into: %{} do
      {key,
       %{
         metas: metas,
         user: %{
           id: key
         }
       }}
    end
  end
end
