defmodule TerritoryWeb.PageLive do
  use TerritoryWeb, :live_view
  alias TerritoryWeb.Presence

  @events "events"
  @presence "page"
  @value_cap 2000

  def mount(params, %{"user_id" => user_id}, socket) do
    TerritoryWeb.Endpoint.subscribe(@events)
    TerritoryWeb.Endpoint.subscribe(@presence)

    Presence.track(self(), @presence, user_id, %{
      id: user_id,
      colour: nil,
      region: Map.get(params, "region", region()),
      value: 100
    })

    socket =
      socket
      |> assign(:user_id, user_id)
      |> assign(:current_colour, nil)
      |> assign(:selected_region, nil)
      |> assign(:users, [])
      |> assign(:regions, [])

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-gradient-to-b from-slate-700 to-slate-800 p-8">
        <header class="flex flex-col gap-6 lg:flex-row sm:justify-between items-center mb-8">
          <h1 class="font-light tracking-widest text-5xl text-slate-300 text-center uppercase">Territory</h1>
          <.controls colour={@current_colour} regions={@regions} />
        </header>

        <section class="grid grid-cols-1 gap-6 md:grid-cols-3">
          <%= for region <- @regions do %>
            <.card
              text={region.name}
              subtext={"#{region.count} connected"}
              image_url={"https://fly.io/ui/images/#{region_key(region.id)}.svg"}
              />
          <% end %>
        </section>
      </div>

      <div class="grid grid-cols-1 gap-6 p-8 md:grid-cols-3">
        <%= for user <- @users, filter_by_selected_region(user, @selected_region) do %>
          <.card
            text={user_text(user)}
            subtext={user_value(user)}
            image_url={"https://fly.io/ui/images/#{region_key(user.region)}.svg"}
            highlight={user.id == @user_id}
            colour={user.colour}
            />
        <% end %>
      </div>
    </div>
    """
  end

  defp filter_by_selected_region(_, nil), do: true
  defp filter_by_selected_region(%{region: region}, region), do: true
  defp filter_by_selected_region(_, _), do: false

  defp user_text(user) do
    if user.count > 1 do
      "#{user.id} (x#{user.count})"
    else
      user.id
    end
  end

  defp user_value(%{value: @value_cap}), do: "💰🤑💰"
  defp user_value(%{value: value}), do: "$#{value}"

  def handle_event("change_colour", %{"colour" => colour}, socket) do
    user = get_user_presence(socket)
    Presence.update(self(), @presence, socket.assigns.user_id, %{user | colour: colour})
    {:noreply, assign(socket, :current_colour, colour)}
  end

  def handle_event("filter_by_region", %{"region" => ""}, socket) do
    {:noreply, assign(socket, :selected_region, nil)}
  end

  def handle_event("filter_by_region", %{"region" => region}, socket) do
    {:noreply, assign(socket, :selected_region, region)}
  end

  def handle_event("increase_value", _params, socket) do
    user = get_user_presence(socket)
    new_value = min(user.value + 100, @value_cap)

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

  def handle_info(:game_over, socket) do
    {:noreply, push_redirect(socket, to: "/game_over")}
  end

  defp get_user_presence(socket) do
    @presence
    |> Presence.get_by_key(socket.assigns.user_id)
    |> get_user()
  end

  defp get_user(%{metas: [user | _]} = client) do
    Map.put(user, :count, Enum.count(client.metas))
  end

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
