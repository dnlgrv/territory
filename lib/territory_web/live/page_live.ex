defmodule TerritoryWeb.PageLive do
  use TerritoryWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      Hello World
    </div>
    """
  end
end
