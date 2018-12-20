defmodule Blockchain.BlockChainTest do
  use Blockchain.DataCase

  alias Blockchain.BlockChain

  describe "transactions" do
    alias Blockchain.BlockChain.Transactions

    @valid_attrs %{from: "some from", to: "some to", txn_id: 42}
    @update_attrs %{from: "some updated from", to: "some updated to", txn_id: 43}
    @invalid_attrs %{from: nil, to: nil, txn_id: nil}

    def transactions_fixture(attrs \\ %{}) do
      {:ok, transactions} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BlockChain.create_transactions()

      transactions
    end

    test "list_transactions/0 returns all transactions" do
      transactions = transactions_fixture()
      assert BlockChain.list_transactions() == [transactions]
    end

    test "get_transactions!/1 returns the transactions with given id" do
      transactions = transactions_fixture()
      assert BlockChain.get_transactions!(transactions.id) == transactions
    end

    test "create_transactions/1 with valid data creates a transactions" do
      assert {:ok, %Transactions{} = transactions} = BlockChain.create_transactions(@valid_attrs)
      assert transactions.from == "some from"
      assert transactions.to == "some to"
      assert transactions.txn_id == 42
    end

    test "create_transactions/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BlockChain.create_transactions(@invalid_attrs)
    end

    test "update_transactions/2 with valid data updates the transactions" do
      transactions = transactions_fixture()
      assert {:ok, transactions} = BlockChain.update_transactions(transactions, @update_attrs)
      assert %Transactions{} = transactions
      assert transactions.from == "some updated from"
      assert transactions.to == "some updated to"
      assert transactions.txn_id == 43
    end

    test "update_transactions/2 with invalid data returns error changeset" do
      transactions = transactions_fixture()
      assert {:error, %Ecto.Changeset{}} = BlockChain.update_transactions(transactions, @invalid_attrs)
      assert transactions == BlockChain.get_transactions!(transactions.id)
    end

    test "delete_transactions/1 deletes the transactions" do
      transactions = transactions_fixture()
      assert {:ok, %Transactions{}} = BlockChain.delete_transactions(transactions)
      assert_raise Ecto.NoResultsError, fn -> BlockChain.get_transactions!(transactions.id) end
    end

    test "change_transactions/1 returns a transactions changeset" do
      transactions = transactions_fixture()
      assert %Ecto.Changeset{} = BlockChain.change_transactions(transactions)
    end
  end
end
