defmodule TerritoryWeb.PageLive do
  use TerritoryWeb, :live_view
  alias TerritoryWeb.Presence

  @presence "page"

  def mount(_params, %{"user_id" => user_id}, socket) do
    TerritoryWeb.Endpoint.subscribe(@presence)

    Presence.track(self(), @presence, user_id, %{
      connected_at: inspect(System.system_time(:millisecond)),
      region: region()
    })

    {:ok, socket, temporary_assigns: [users: []]}
  end

  def render(assigns) do
    ~H"""
    <div>
      Connected users:

      <ul>
        <%= for user <- @users do %>
          <li>
            <%= user.id %> - <%= region_name(user.region) %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    users =
      Presence.list(@presence)
      |> Enum.map(fn
        {user_id, %{metas: [meta | _]}} ->
          Map.merge(meta, %{id: user_id})

        {user_id, _} ->
          %{id: user_id}
      end)

    {:noreply, assign(socket, :users, users)}
  end

  @region_names %{
    "ams" => "Amsterdam, Netherland",
    "iad" => "Ashburn, Virginia (USA)"
  }

  defp region do
    System.get_env("FLY_REGION", "iad")
  end

  defp region_name(region), do: Map.get(@region_names, region)
end
