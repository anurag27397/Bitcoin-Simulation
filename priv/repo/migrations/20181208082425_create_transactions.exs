defmodule Blockchain.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :txn_id, :integer
      add :from, :string
      add :to, :string

      timestamps()
    end

  end
end
