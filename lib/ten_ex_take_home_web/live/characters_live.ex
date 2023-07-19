defmodule TenExTakeHomeWeb.CharactersLive do
  alias TenExTakeHome.Marvel.MarvelApi
  alias TenExTakeHomeWeb.CoreComponents
  use Phoenix.LiveView

  @cache_name :marvel

  def render(assigns) do
    ~H"""
    <div style="margin: 1rem">
      <h2>Marvel Characters:</h2>
        <ul>
          <%= for ch <- @characters do %>
            <li> <%= ch %> </li>
          <% end %>
        </ul>

      <%= if @page > 0 do %>
      <button phx-click="previous-characters">Previous</button>
      <% end %>
      <button phx-click="next-characters">Next</button>
      <CoreComponents.simple_form for={@form} phx-submit="update-results-per-page">
          <CoreComponents.input type="text" inputmode="numeric" pattern="[0-9]*" field={@form[:results_per_page]} />
      </CoreComponents.simple_form>
    </div>
    """
  end

  def mount(_params, _, socket) do
    {:ok, characters} = MarvelApi.get_all_characters()
    socket = assign(socket, :page, 0)
    socket = assign(socket, :results_per_page, 20)
    socket = assign(socket, form: to_form(%{"results_per_page" => 20}))
    {:ok, assign(socket, :characters, characters)}
  end

  def handle_event("next-characters", _, %{assigns: %{page: page, results_per_page: results_per_page}}= socket) do
    {:ok, characters} = MarvelApi.get_all_characters(page + 1, results_per_page)
    socket = assign(socket, :page, page + 1)
    socket = assign(socket, form: to_form(%{"results_per_page" => results_per_page}))
    {:noreply, assign(socket, :characters, characters)}
  end

  def handle_event("previous-characters", _, %{assigns: %{page: page, results_per_page: results_per_page}}= socket) do
    {:ok, characters} = MarvelApi.get_all_characters(page - 1, results_per_page)
    socket = assign(socket, :page, page - 1)
    socket = assign(socket, form: to_form(%{"results_per_page" => results_per_page}))
    {:noreply, assign(socket, :characters, characters)}
  end

  def handle_event("update-results-per-page", %{"results_per_page" => new_results_per_page}=payload, %{assigns: %{page: page}} = socket) do
    {:ok, characters} = MarvelApi.get_all_characters(page, String.to_integer(new_results_per_page))
    socket = assign(socket, :results_per_page, String.to_integer(new_results_per_page))
    {:noreply, assign(socket, :characters, characters)}
  end
end
