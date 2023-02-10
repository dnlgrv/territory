defmodule TerritoryWeb.PageLive do
  use TerritoryWeb, :live_view
  alias TerritoryWeb.Presence

  @presence "page"

  def mount(_params, %{"user_id" => user_id}, socket) do
    TerritoryWeb.Endpoint.subscribe(@presence)

    Presence.track(self(), @presence, user_id, %{
      id: user_id,
      region: region(),
      value: 100
    })

    {
      :ok,
      assign(socket, :user_id, user_id),
      temporary_assigns: [regions: [], users: []]
    }
  end

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <header class="flex justify-between items-center mb-8">
        <h1 class="font-light tracking-widest text-5xl text-slate-300 text-center uppercase">Territory</h1>
        <.controls />
      </header>

      <section class="mb-16 grid grid-cols-1 gap-6 opacity-50 md:grid-cols-3">
        <%= for region <- @regions do %>
          <.card
            text={region.name}
            subtext={"#{region.count} connected"}
            image_url={"https://fly.io/ui/images/#{region.id}.svg"}
            />
        <% end %>
      </section>

      <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
        <%= for user <- @users do %>
          <.card
            text={user.id}
            subtext={"$#{user.value}"}
            image_url={"https://fly.io/ui/images/#{region_key(user.region)}.svg"}
            highlight={user.id == @user_id}
            />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("increase_value", _params, socket) do
    user =
      Presence.get_by_key(@presence, socket.assigns.user_id)
      |> get_user()

    new_value = user.value + 100

    Presence.update(self(), @presence, socket.assigns.user_id, %{user | value: new_value})

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    presences = Presence.list(@presence) |> Enum.map(&elem(&1, 1))

    users = Enum.map(presences, &get_user/1)

    regions =
      users
      |> Enum.reduce(%{}, fn %{region: region}, acc ->
        Map.update(acc, region, %{id: region, name: region_name(region), count: 1}, fn existing ->
          %{existing | count: existing.count + 1}
        end)
      end)
      |> Map.values()

    socket =
      socket
      |> assign(:users, users)
      |> assign(:regions, regions)

    {:noreply, socket}
  end

  defp get_user(%{metas: [user | _]}), do: user

  @region_names %{
    "bos" => "Boston Massachusetts (US)",
    "lhr" => "London, United Kingdom",
    "gru" => "São Paulo",
    "yyz" => "Toronto, Canada"
  }

  defp region, do: System.get_env("FLY_REGION", "lhr")

  defp region_name(region), do: Map.get(@region_names, region, "Unknown")

  defp region_key("bos"), do: "usa"
  defp region_key(region), do: region
end
