defmodule TenExTakeHome.Marvel.MarvelApi do
  @moduledoc """
  Contains top-level functions for retrieving and caching data from the Marvel Api.
  """

  alias TenExTakeHome.MarvelApi.MarvelApiMetrics

  def get_all_characters(page \\ 1, results_per_page \\ 20) do
    {:ok, characters} = check_cache(:characters)

    {next_etag, next_characters_list} = if characters["#{page}"], do: characters["#{page}"], else: {"", []}
    if results_per_page != 20, do: next_etag = ""

    IO.inspect(next_etag, label: "=======NEXT ETAG=======")
    IO.inspect(results_per_page, label: "=======RESULTS COUNT=======")
    {:ok, response} = HTTPoison.get("http://gateway.marvel.com/v1/public/characters",
    ["If-None-Match": next_etag],
    [params: configure_params(page, results_per_page)
    ])

    case response.status_code do
      200 ->
        {:ok, decoded} = Jason.decode(response.body)
        IO.inspect(decoded["etag"], label: "=======RESPONSE ETAG=======")
        next_characters_list = Enum.map(decoded["data"]["results"], fn ch -> ch["name"] end)

        MarvelApiMetrics.insert_marvel_api_metric(%{etag: decoded["etag"], resource: "characters"})
        Cachex.put(:marvel, :characters, Map.put(characters, "#{page}", {decoded["etag"], next_characters_list}))

        next_characters_list
      304 ->
        IO.inspect("=======CACHE DATA UP TO DATE 304=======")
        MarvelApiMetrics.insert_marvel_api_metric(%{etag: next_etag, resource: "characters"})
        next_characters_list
    end
  end

  defp configure_params(page, results_per_page) do
    timestamp = "#{DateTime.to_unix(DateTime.utc_now())}"
    private_key = Application.get_env(:ten_ex_take_home, :private_marvel_key)
    public_key = Application.get_env(:ten_ex_take_home, :public_marvel_key)
    IO.inspect(results_per_page, label: "=======RESULTS COUNT=======")
    hash = Base.encode16(:erlang.md5(timestamp <> private_key <> public_key), case: :lower)
    offset = page * results_per_page
    # multiply current page by 20 for the next 20 results
    [ts: timestamp, apikey: public_key, hash: hash, offset: offset, limit: results_per_page]
  end

  def check_cache(resource) do
    case Cachex.get(:marvel, resource) do
      {:ok, nil} ->
        {:ok, %{}}
      cache ->
        cache
    end
  end
end
