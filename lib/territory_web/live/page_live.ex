defmodule TerritoryWeb.PageLive do
  use TerritoryWeb, :live_view
  alias TerritoryWeb.Presence

  @presence "page"

  def mount(_params, %{"user_id" => user_id}, socket) do
    TerritoryWeb.Endpoint.subscribe(@presence)

    Presence.track(self(), @presence, user_id, %{
      id: user_id,
      ping: nil,
      region: region()
    })

    {:ok, assign(socket, :user_id, user_id), temporary_assigns: [users: []]}
  end

  def render(assigns) do
    ~H"""
    <div>
      Connected users:

      <ul>
        <%= for user <- @users do %>
          <li>
            <%= user.id %> - <%= region_name(user.region) %>
            <img src={"https://fly.io/ui/images/#{region_key(user.region)}.svg"} width="100" />
            <%= user.ping %>ms
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("ping", %{"rtt" => ping}, socket) do
    user =
      Presence.get_by_key(@presence, socket.assigns.user_id)
      |> get_user()
      |> Map.merge(%{ping: ping})

    Presence.update(self(), @presence, socket.assigns.user_id, user)

    {:noreply, push_event(socket, "pong", %{})}
  end

  defp get_user(%{metas: [user | _]}), do: user

  def handle_info(%{event: "presence_diff"}, socket) do
    users =
      Presence.list(@presence)
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(&get_user/1)

    {:noreply, assign(socket, :users, users)}
  end

  @region_names %{
    "ams" => "Amsterdam, Netherlands",
    "bos" => "Boston Massachusetts (US)",
    "gru" => "São Paulo",
    "yyz" => "Toronto, Canada"
  }

  defp region do
    System.get_env("FLY_REGION", "ams")
  end

  defp region_name(region), do: Map.get(@region_names, region, "Unknown")

  defp region_key("bos"), do: "usa"
  defp region_key(region), do: region
end
