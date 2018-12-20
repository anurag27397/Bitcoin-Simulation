defmodule BlockchainWeb.TransactionsController do
  use BlockchainWeb, :controller

  alias Blockchain.BlockChain
  alias Blockchain.BlockChain.Transactions

  def index(conn, _params) do
    transactions = BlockChain.list_transactions()
    render(conn, "index.html", transactions: transactions)
  end

  def new(conn, _params) do
    changeset = BlockChain.change_transactions(%Transactions{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"transactions" => transactions_params}) do
    case BlockChain.create_transactions(transactions_params) do
      {:ok, transactions} ->
        conn
        |> put_flash(:info, "Transactions created successfully.")
        |> redirect(to: transactions_path(conn, :show, transactions))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transactions = BlockChain.get_transactions!(id)
    render(conn, "show.html", transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    transactions = BlockChain.get_transactions!(id)
    changeset = BlockChain.change_transactions(transactions)
    render(conn, "edit.html", transactions: transactions, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transactions" => transactions_params}) do
    transactions = BlockChain.get_transactions!(id)

    case BlockChain.update_transactions(transactions, transactions_params) do
      {:ok, transactions} ->
        conn
        |> put_flash(:info, "Transactions updated successfully.")
        |> redirect(to: transactions_path(conn, :show, transactions))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", transactions: transactions, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transactions = BlockChain.get_transactions!(id)
    {:ok, _transactions} = BlockChain.delete_transactions(transactions)

    conn
    |> put_flash(:info, "Transactions deleted successfully.")
    |> redirect(to: transactions_path(conn, :index))
  end
end
