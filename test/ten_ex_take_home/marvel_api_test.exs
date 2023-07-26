defmodule TenExTakeHome.MarvelApiTest do
  use TenExTakeHome.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias TenExTakeHome.Marvel.{MarvelApi, MarvelApiMetric}

  setup do
    HTTPoison.start()
    :ok
  end

  describe "get_all_characters/2" do
    test "retrieves a list of characters from the Marvel API with a user specified offset" do
      use_cassette "character_fetch_success" do
        {:ok, characters} = MarvelApi.get_all_characters(0, 30)
        IO.inspect(characters)

        assert length(characters) == 30
        assert List.first(characters) == "3-D Man"
      end
    end
  end
end
