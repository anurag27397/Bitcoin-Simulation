defmodule BlockchainWeb.TransactionsControllerTest do
  use BlockchainWeb.ConnCase

  alias Blockchain.BlockChain

  @create_attrs %{from: "some from", to: "some to", txn_id: 42}
  @update_attrs %{from: "some updated from", to: "some updated to", txn_id: 43}
  @invalid_attrs %{from: nil, to: nil, txn_id: nil}

  def fixture(:transactions) do
    {:ok, transactions} = BlockChain.create_transactions(@create_attrs)
    transactions
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get conn, transactions_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Transactions"
    end
  end

  describe "new transactions" do
    test "renders form", %{conn: conn} do
      conn = get conn, transactions_path(conn, :new)
      assert html_response(conn, 200) =~ "New Transactions"
    end
  end

  describe "create transactions" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, transactions_path(conn, :create), transactions: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == transactions_path(conn, :show, id)

      conn = get conn, transactions_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Transactions"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, transactions_path(conn, :create), transactions: @invalid_attrs
      assert html_response(conn, 200) =~ "New Transactions"
    end
  end

  describe "edit transactions" do
    setup [:create_transactions]

    test "renders form for editing chosen transactions", %{conn: conn, transactions: transactions} do
      conn = get conn, transactions_path(conn, :edit, transactions)
      assert html_response(conn, 200) =~ "Edit Transactions"
    end
  end

  describe "update transactions" do
    setup [:create_transactions]

    test "redirects when data is valid", %{conn: conn, transactions: transactions} do
      conn = put conn, transactions_path(conn, :update, transactions), transactions: @update_attrs
      assert redirected_to(conn) == transactions_path(conn, :show, transactions)

      conn = get conn, transactions_path(conn, :show, transactions)
      assert html_response(conn, 200) =~ "some updated from"
    end

    test "renders errors when data is invalid", %{conn: conn, transactions: transactions} do
      conn = put conn, transactions_path(conn, :update, transactions), transactions: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Transactions"
    end
  end

  describe "delete transactions" do
    setup [:create_transactions]

    test "deletes chosen transactions", %{conn: conn, transactions: transactions} do
      conn = delete conn, transactions_path(conn, :delete, transactions)
      assert redirected_to(conn) == transactions_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, transactions_path(conn, :show, transactions)
      end
    end
  end

  defp create_transactions(_) do
    transactions = fixture(:transactions)
    {:ok, transactions: transactions}
  end
end
