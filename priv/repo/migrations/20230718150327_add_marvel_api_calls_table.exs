defmodule TenExTakeHome.Repo.Migrations.AddMarvelApiMetricsTable do
  use Ecto.Migration

  def change do
    create table("marvel_api_metrics") do
      add :etag, :string, null: false
      add :resource, :string, null: false

      timestamps()
    end
  end
end
