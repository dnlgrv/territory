defmodule Territory do
  @moduledoc """
  Territory keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def game_over do
    Phoenix.PubSub.broadcast(Territory.PubSub, "events", :game_over)
  end
end
