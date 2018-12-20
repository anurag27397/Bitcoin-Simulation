defmodule Blockchain.BlockChain.Transactions do
  use Ecto.Schema
  import Ecto.Changeset


  schema "transactions" do
    field :from, :string
    field :to, :string
    field :txn_id, :integer

    timestamps()
  end

  @doc false
  def changeset(transactions, attrs) do
    transactions
    |> cast(attrs, [:txn_id, :from, :to])
    |> validate_required([:txn_id, :from, :to])
  end
end
