defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def get_block_chain_reference() do
    [{_, chain_pid}] = :ets.lookup(:buckets_registry, "block_chain_reference")
    chain_pid
  end

  def index(conn, %{"user" => user}) do
    chain_pid = get_block_chain_reference()

    user_pid = Map.get(Implementation.get_user_map(chain_pid), user)
    user_balance = Implementation.get_balance(chain_pid, user_pid)
    IO.inspect(user_balance)
    render(conn, "index.html", user: user, balance: user_balance)
  end
end

