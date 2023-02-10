defmodule TerritoryWeb.CoreComponents do
  use Phoenix.Component

  def card(assigns) do
    base_classes = "rounded-lg bg-slate-800 text-slate-300 shadow overflow-hidden"

    class_list =
      if assigns.highlight do
        "#{base_classes} ring-4 ring-blue-500"
      else
        base_classes
      end

    ~H"""
    <section class={class_list}>
      <div class="flex">
        <div class="grow flex flex-col gap-2 p-4">
          <h1 class="text-slate-500"><%= @text %></h1>
          <span class="text-xl font-semibold"><%= @subtext %></span>
        </div>

        <div class="shrink-0 w-1/4 bg-no-repeat bg-contain bg-center translate-x-4 scale-150" style={"background-image: url(#{@image_url})"}></div>
      </div>
    </section>
    """
  end

  def controls(assigns) do
    ~H"""
    <div class="flex justify-center">
      <button class="p-4 rounded bg-sky-500 font-semibold text-white flex items-center gap-2 transition hover:bg-sky-600" phx-click="increase_value">
        <.icon name={:up_arrow} />
        Improve my value
      </button>
    </div>
    """
  end

  def icon(assigns) do
    apply(__MODULE__, assigns.name, [assigns])
  end

  def up_arrow(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
      <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18" />
    </svg>
    """
  end
end