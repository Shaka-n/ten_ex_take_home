defmodule TenExTakeHome.Marvel.MarvelApiMetric do
  @moduledoc """
  Schema module for persisting data from successful calls to the Marvel API.
  The etag represents the unique identifier of each version of a given resource.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "marvel_api_metrics" do
    field :resource, :string
    field :etag, :string

    timestamps()
  end

  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:etag, :resource])
  end
end
