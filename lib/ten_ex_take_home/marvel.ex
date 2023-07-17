defmodule TenExTakeHome.Marvel do
  @moduledoc """
  Contains functions for interacting with the Marvel API.
  """

  def get_all_characters do
    {:ok, {curr_etag, curr_characters}} = check_cache()

    IO.inspect(curr_etag, label: "=======CURRENT ETAG=======")
    timestamp = "#{DateTime.to_unix(DateTime.utc_now())}"
    private_key = Application.get_env(:ten_ex_take_home, :private_marvel_key)
    public_key = Application.get_env(:ten_ex_take_home, :public_marvel_key)

    hash = Base.encode16(:erlang.md5(timestamp <> private_key <> public_key), case: :lower)

   {:ok, response} = HTTPoison.get("http://gateway.marvel.com/v1/public/characters",
    ["If-None-Match": curr_etag],
    [params:
      [ts: timestamp,
      apikey: public_key,
      hash: hash ]
    ])
    case response.status_code do
      200 ->
        {:ok, decoded} = Jason.decode(response.body)
        IO.inspect(decoded["etag"], label: "=======RESPONSE ETAG=======")
        new_chars = Enum.map(decoded["data"]["results"], fn ch -> ch["name"] end)
        Cachex.put(:marvel, :characters, {decoded["etag"], new_chars})
        new_chars
      304 ->
        curr_characters
    end

  end

  def check_cache() do
    case Cachex.get(:marvel, :characters) do
      {:ok, nil} ->
        {:ok, {"", []}}
      result ->
        result
    end
  end

end
