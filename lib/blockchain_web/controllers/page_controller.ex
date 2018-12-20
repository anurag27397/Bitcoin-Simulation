defmodule BlockchainWeb.PageController do
  use BlockchainWeb, :controller

  def index(conn, _params) do

    difficulty = 2
    {:ok, block_chain_pid} = Implementation.start_link()
    {:ok, user1_id} = User.start_link()
    {:ok, user2_id} = User.start_link()
    user1_address = User.get_public_key(user1_id)
    user2_address = User.get_public_key(user2_id)
    block_1_pid = Implementation.pendingTransaction(block_chain_pid, user1_address, difficulty)
    {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 150.0)
    User.sign_transaction(user1_id, txn1_id)
    Implementation.add_transaction(block_chain_pid, txn1_id)
    block_2_pid = Implementation.pendingTransaction(block_chain_pid, user2_address, difficulty)
    user1_bal=Implementation.get_balance(block_chain_pid, user1_address)
    user2_bal=Implementation.get_balance(block_chain_pid, user2_address)

   render(conn, "index.html", user1bal: user1_bal, user2bal: user2_bal)
  end
end
