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
end
