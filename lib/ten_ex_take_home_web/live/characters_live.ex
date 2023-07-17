defmodule TenExTakeHomeWeb.CharactersLive do
  alias TenExTakeHome.Marvel
  use Phoenix.LiveView

  @cache_name :marvel

  def render(assigns) do
    ~H"""
    Marvel Characters:

    <ul>
      <%= for ch <- @characters do %>
        <li> <%= ch %> </li>
      <% end %>
    </ul>
    """
  end

  def mount(_params, _, socket) do
    characters = Marvel.get_all_characters()
    {:ok, assign(socket, :characters, characters)}
  end
end
