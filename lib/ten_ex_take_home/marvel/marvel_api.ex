defmodule TenExTakeHome.Marvel.MarvelApi do
  @moduledoc """
  Contains top-level functions for retrieving and caching data from the Marvel Api.
  """

  alias TenExTakeHome.MarvelApi.MarvelApiMetrics

  def get_all_characters(page \\ 0, results_per_page \\ 20) do
    {:ok, characters} = check_cache(:characters)

    {next_etag, next_characters_list} = if characters["#{page}"], do: characters["#{page}"], else: {"", []}

    {:ok, response} = HTTPoison.get("http://gateway.marvel.com/v1/public/characters",
    ["If-None-Match": next_etag],
    [params: configure_params(page, results_per_page)
    ])

    case response.status_code do
      200 ->
        {:ok, decoded} = Jason.decode(response.body)
        next_characters_list = Enum.map(decoded["data"]["results"], fn ch -> ch["name"] end)

        MarvelApiMetrics.insert_marvel_api_metric(%{etag: decoded["etag"], resource: "characters"})
        Cachex.put(:marvel, :characters, Map.put(characters, "#{page}", {decoded["etag"], next_characters_list}))

        {:ok, next_characters_list}
      304 ->
        MarvelApiMetrics.insert_marvel_api_metric(%{etag: next_etag, resource: "characters"})
        {:ok, next_characters_list}
      _ ->
        {:error, "Something has gone wrong when contacting the Marvel API."}
    end
  end

  defp configure_params(page, results_per_page) do
    timestamp = "#{DateTime.to_unix(DateTime.utc_now())}"
    private_key = System.get_env("private_marvel_key")
    public_key = System.get_env("public_marvel_key")
    hash = Base.encode16(:erlang.md5(timestamp <> private_key <> public_key), case: :lower)
    offset = if page == 0, do: 0, else: page * results_per_page
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
