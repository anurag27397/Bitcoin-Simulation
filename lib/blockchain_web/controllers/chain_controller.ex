defmodule BlockchainWeb.ChainController do
  use BlockchainWeb, :controller
  def index(conn, _params) do
    [{_, chain_pid}] = :ets.lookup(:buckets_registry, "block_chain_reference")
    IO.inspect(Block.get_hash(Implementation.get_latest_block(chain_pid)))


    Enum.each(1..100, fn x->
      {:ok, user} = User.start_link()
      IO.inspect(user)
      Implementation.add_user(chain_pid, user)
      IO.inspect(User.get_user_id(user))
    end)
    # IO.inspect(User.get_public_key(user1_id))
    user_count = Enum.count(Implementation.get_user_map(chain_pid))
    IO.inspect(user_count)
    render(conn, "index.html", no_of_users: user_count)

  end
end
