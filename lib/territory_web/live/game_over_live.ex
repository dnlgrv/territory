defmodule TerritoryWeb.GameOverLive do
  use TerritoryWeb, :live_view

  def mount(_params, _session, socket) do
    send(self(), :after_mount)
    {:ok, assign(socket, :opacity_class, "opacity-0")}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen bg-slate-900 text-red-700 flex items-center justify-center">
      <h1 class={"text-giant uppercase font-bold tracking-widest center transition duration-[8000ms] opacity-0 #{@opacity_class}"}>
        Game over
      </h1>
    </div>
    """
  end

  def handle_info(:after_mount, socket) do
    {:noreply, assign(socket, :opacity_class, "opacity-100")}
  end
end
