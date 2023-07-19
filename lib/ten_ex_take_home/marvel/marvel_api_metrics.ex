defmodule TenExTakeHome.MarvelApi.MarvelApiMetrics do
  @moduledoc """
  Contains context functions for persisting data from successful calls to the Marvel API.
  Only provides create, get, and get_all functions, as there should be no need to delete/update these directly.
  """

  alias TenExTakeHome.Marvel.MarvelApiMetric
  alias TenExTakeHome.Repo


  def insert_marvel_api_metric(attrs) do
    %MarvelApiMetric{}
    |> MarvelApiMetric.changeset(attrs)
    |> Repo.insert()
  end

  def get_marvel_api_metric(id), do: Repo.get!(MarvelApiMetric, id)

  def get_all_marvel_api_metrics, do: Repo.all(MarvelApiMetric)
end
