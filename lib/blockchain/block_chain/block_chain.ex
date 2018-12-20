defmodule Blockchain.BlockChain do

  import Ecto.Query, warn: false
  alias Blockchain.Repo

  alias Blockchain.BlockChain.Transactions

  def list_transactions do
    Repo.all(Transactions)
  end

  def get_transactions!(id), do: Repo.get!(Transactions, id)

  def create_transactions(attrs \\ %{}) do
    %Transactions{}
    |> Transactions.changeset(attrs)
    |> Repo.insert()
  end


  def update_transactions(%Transactions{} = transactions, attrs) do
    transactions
    |> Transactions.changeset(attrs)
    |> Repo.update()
  end

  def delete_transactions(%Transactions{} = transactions) do
    Repo.delete(transactions)
  end

  def change_transactions(%Transactions{} = transactions) do
    Transactions.changeset(transactions, %{})
  end
end
