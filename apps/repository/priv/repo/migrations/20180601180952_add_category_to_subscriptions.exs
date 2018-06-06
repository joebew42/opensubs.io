defmodule Repository.Repo.Migrations.AddCategoryToSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :category, :string, default: "uncategorized"
    end
  end
end
