defmodule Implementation do
  use GenServer

  @compile :nowarn_unused_vars


  def run(arg) do
      difficulty=String.to_integer((arg))
      main(difficulty)
  end

#blockchain
  def main(difficulty) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    updateMineReward(pid, 150.0)
    {:ok, user1_id} = User.start_link()
    add_user(pid, user1_id)
    block_1_pid = pendingTransaction(pid, User.get_public_key(user1_id), difficulty)
    {:ok, user2_id} = User.start_link()
    add_user(pid, user2_id)
    {:ok, txn1_id} = BitcoinTransaction.start_link(User.get_public_key(user1_id), User.get_public_key(user2_id), 150.00)
    User.sign_transaction(user1_id, txn1_id)
    add_transaction(pid, txn1_id)
    {:ok, txn2_id} = BitcoinTransaction.start_link(User.get_public_key(user2_id), User.get_public_key(user1_id), 150.00)
    User.sign_transaction(user2_id, txn2_id)
    add_transaction(pid, txn2_id)
    IO.inspect("Original Balances:")
    IO.inspect(User.getAmount(user1_id))
    IO.inspect(User.getAmount(user2_id))
    block_2_pid = pendingTransaction(pid, User.get_public_key(user2_id), difficulty)
    IO.inspect(Block.is_valid(block_2_pid))
    IO.inspect("Updated Balances:")
    IO.inspect(User.getAmount(user1_id))
    IO.inspect(User.getAmount(user2_id))
    IO.inspect(is_valid(pid))
    IO.inspect(get_balance(pid, User.get_public_key(user1_id)))
    IO.inspect(get_balance(pid, User.get_public_key(user2_id)))
end

  def init([]) do
    _timestamp = :erlang.system_time / 1.0e6 |> round
    genesis_block = createGenesisBlock()
    {:ok, {[] ++ [genesis_block], 1, [], 0, %{}}}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def createGenesisBlock() do
    {:ok, block_pid} = Block.start_link()
    Block.update_previousHash(block_pid, "")
    Block.update_hash(block_pid, "genesis_block")
    block_pid
  end

  def process_block_transactions(pid, block_pid) do
    transactions = Block.get_transactions(block_pid)
    IO.inspect("processing all pending transactions.....")
    Enum.each(transactions, fn transcationid ->
    is_valid = BitcoinTransaction.verify_transaction(transcationid, BitcoinTransaction.get_from_address(transcationid))
    if is_valid do
      process_single_transaction(pid, transcationid)
      else
      IO.inspect("Signature unmatched so adding it to unconfirmed transactions")
      add_transaction(pid, transcationid)
      end
    end)
  end

    def process_single_transaction(pid, transcationid) do
    from_user = get_user(pid, BitcoinTransaction.get_from_address(transcationid))
    to_user = get_user(pid, BitcoinTransaction.get_to_address(transcationid))
    amount = BitcoinTransaction.getAmount(transcationid)
    User.update_amount(from_user, User.getAmount(from_user) - amount)
    User.update_amount(to_user, User.getAmount(to_user) + amount)
  end

    def pendingTransaction(pid, miningRewardAddress, difficulty) do
    {:ok, block_pid} = Block.start_link()
    Block.mine_block(block_pid, difficulty)
    latest_block_pid = get_latest_block(pid)
    latest_block_hash = Block.get_hash(latest_block_pid)
    Block.update_previousHash(block_pid, latest_block_hash)
    add_block(pid, block_pid)
    Block.update_transactions(block_pid, get_pending_transactions(pid))
    Block.recalculateHash(difficulty, block_pid)
    update_pending_transcations(pid, [])
    {:ok, transcationid} = BitcoinTransaction.start_link("miningReward", miningRewardAddress, get_mining_reward(pid))
    add_transaction(pid, transcationid)
    block_pid
  end
  def is_valid(pid) do
    chain = get_chain(pid)
    index_list = Enum.to_list(1..Enum.count(chain)-1)
    is_valid = Enum.reduce(index_list, true, fn(index, acc) ->
      previous_block = Enum.fetch!(chain, index-1)
      current_block = Enum.fetch!(chain, index)
      hash_is_valid = Block.get_hash(previous_block) == Block.get_previousHash(current_block)
      acc and hash_is_valid and Block.is_valid(current_block) end)
    is_valid
  end

  def updateMineReward(pid, reward) do
    GenServer.cast(pid, {:updatingMineReward, reward})
  end

  def get_balance(pid, user_public_key) do
    chain = get_chain(pid)
    balance = Enum.reduce(chain, 0.0, fn(block, acc)->
      acc + Block.get_balance(block, user_public_key)
    end)
    balance
  end

  def update_pending_transcations(pid, transactions) do
    GenServer.cast(pid, {:updatingPendingTrans, transactions})
  end

  def add_user(pid, user_pid) do
    GenServer.cast(pid, {:addingUser, user_pid})
  end

  def add_block(pid, block_pid) do
    GenServer.cast(pid, {:addingBlock, block_pid})
  end

  def get_pending_transactions(pid) do
    GenServer.call(pid, {:gettingPendingTransactions})
  end

  def get_user_map(pid) do
    GenServer.call(pid,{:gettingUserMap})
  end

  def get_chain(pid) do
    GenServer.call(pid, {:gettingChain})
  end

  def get_mining_reward(pid) do
    GenServer.call(pid, {:gettingMiningReward})
  end

  def get_latest_block(pid) do
    GenServer.call(pid, {:gettingLatestBlock})
  end

  def get_user(pid, user_public_key) do
    GenServer.call(pid, {:gettingUser, user_public_key})
  end

  def add_transaction(pid, transaction) do
    GenServer.cast(pid, {:addingTransaction, transaction})
  end

  def handle_call({:gettingPendingTransactions}, _from, state) do
    {_, _, transactions, _, _} = state
    {:reply, transactions, state}
  end
  def handle_call({:gettingChain}, _from, state) do
    {chain, _, _, _, _} = state
    {:reply, chain, state}
  end
  def handle_call({:gettingMiningReward}, _from, state) do
    {_, _, _, reward, _} = state
    {:reply, reward, state}
  end
  def handle_call({:gettingLatestBlock}, _from, state) do
    {chain, _, _, _, _} = state
    latest_block = List.last(chain)
    {:reply, latest_block, state}
  end
  def handle_call({:gettingUserMap}, _from, state) do
    {_, _, _, _, map} = state
    {:reply, map, state}
  end
  def handle_call({:gettingUser, user_public_key}, _from, state) do
    {_, _, _, _, map} = state
    user_pid = Map.get(map, user_public_key)
    {:reply, user_pid, state}
  end
  def handle_cast({:addingTransaction, transaction}, state) do
    {a, b, transactions, d, e} = state
    state = {a, b, transactions ++ [transaction], d, e}
    {:noreply, state}
  end
  def handle_cast({:updatingMineReward, reward}, state) do
    {a, b, c, _, e} = state
    state = {a, b, c, reward, e}
    {:noreply, state}
  end
  def handle_cast({:updatingPendingTrans, transactions}, state) do
    {a, b, _, d, e} = state
    state = {a, b, transactions, d, e}
    {:noreply, state}
  end
  def handle_cast({:addingBlock, block_pid}, state) do
    {chain, b, c, d, e} = state
    state = {chain ++ [block_pid], b, c, d, e}
    {:noreply, state}
  end
  def handle_cast({:addingUser, user_pid}, state) do
    {a, b, c, d, map} = state
    user_public_key = User.get_public_key(user_pid)
    map = Map.put(map, user_public_key, user_pid)
    state = {a, b, c, d, map}
    {:noreply, state}
  end
end

#block
defmodule Block do
  use GenServer
  def init([]) do
    timestamp = :erlang.system_time / 1.0e6 |> round
    {:ok, {"", timestamp, [], 0, ""}}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end
  def calculateHash(string) do
    :crypto.hash(:sha, string) |> Base.encode16
  end
   def get_balance(pid, user_public_key) do
    transactions = get_transactions(pid)
    balance = Enum.reduce(transactions, 0.0, fn(transcationid, acc)->
      from_address = BitcoinTransaction.get_from_address(transcationid)
      to_address = BitcoinTransaction.get_to_address(transcationid)
      amount = BitcoinTransaction.getAmount(transcationid)
      cond do
      from_address == user_public_key -> acc - amount
        to_address == user_public_key -> acc + amount
      true -> acc end end)
    balance
  end
  def mine_block(pid, difficulty) do
    previousHash = get_previousHash(pid)
    timeStamp = Integer.to_string(get_timeStamp(pid))
    transactions = List.to_string(get_transactions(pid))
    nonce = get_nonce(pid)
    hash = generate_hash(difficulty, pid, previousHash, timeStamp, transactions, nonce)
    IO.puts("Mined a new block with hash = " <> hash)
    update_hash(pid, hash)
  end
  def generate_hash(difficulty, pid, previousHash, timeStamp, transactions, nonce) do
    hash = calculateHash(previousHash <> timeStamp <> transactions <> Integer.to_string(nonce))
    list = Enum.to_list(1..difficulty)
    string_of_zeroes = Enum.reduce(list, "", fn(x, acc) -> "0" <> acc end)
    if String.slice(hash, 0..difficulty-1) == string_of_zeroes do
      update_nonce(pid, nonce)
      hash
    else
      generate_hash(difficulty, pid, previousHash, timeStamp, transactions, nonce+1)
    end
  end
  def recalculateHash(difficulty, pid) do
    previousHash = get_previousHash(pid)
    timeStamp = Integer.to_string(get_timeStamp(pid))
    transactions = Integer.to_string(Enum.count(get_transactions(pid)))
    nonce = get_nonce(pid)
    hash = Block.generate_hash(difficulty, pid, previousHash, timeStamp, transactions, nonce)
    update_hash(pid, hash)
  end

  def get_nonce(pid) do
    GenServer.call(pid, {:gettingNonce})
  end
  def get_hash(pid) do
    GenServer.call(pid, {:gettingHash})
  end
  def get_transactions(pid) do
    GenServer.call(pid, {:gettingTransactions})
  end
  def get_previousHash(pid) do
    GenServer.call(pid, {:gettingPreviousHash})
  end
  def get_timeStamp(pid) do
    GenServer.call(pid, {:gettingTimeStamp})
  end
  def update_hash(pid, hash) do
    GenServer.cast(pid, {:updatingHash, hash})
  end
  def update_transactions(pid, transactions) do
    GenServer.cast(pid, {:updatingTransactions, transactions})
  end
  def update_previousHash(pid, previousHash) do
    GenServer.cast(pid, {:updatingPreviousHash, previousHash})
  end
  def update_nonce(pid, nonce) do
    GenServer.cast(pid, {:updatingNonce, nonce})
  end

  def is_valid(pid) do
    transactions = get_transactions(pid)
    flag = Enum.reduce(transactions, true, fn(transcationid, acc) ->
    if BitcoinTransaction.get_from_address(transcationid) == "miningReward" do
    true
    else
    acc and BitcoinTransaction.verify_transaction(transcationid, BitcoinTransaction.get_from_address(transcationid))
    end
    end)
    flag
  end

  def handle_call({:gettingNonce}, _from, state) do
    {_, _, _, nonce, _} = state
    {:reply, nonce, state}
  end
  def handle_call({:gettingHash}, _from, state) do
    {_, _, _, _, hash} = state
    {:reply, hash, state}
  end
  def handle_call({:gettingPreviousHash}, _from, state) do
    {previousHash, _, _, _, _} = state
    {:reply, previousHash, state}
  end
  def handle_call({:gettingTransactions}, _from, state) do
    {_, _, transcations, _, _} = state
    {:reply, transcations, state}
  end
  def handle_call({:gettingTimeStamp}, _from, state) do
    {_, timestamp, _, _, _} = state
    {:reply, timestamp, state}
  end
  def handle_cast({:updatingHash, hash}, state) do
    {previousHash, timestamp, transactions, nonce, _} = state
    state = {previousHash, timestamp, transactions, nonce, hash}
    {:noreply, state}
  end
  def handle_cast({:updatingTransactions, transactions}, state) do
    {a, b, _ , d, e} = state
    state = {a, b, transactions, d, e}
    {:noreply, state}
    end
  def handle_cast({:updatingPreviousHash, previousHash}, state) do
    {_, b, c, d, e} = state
    state = {previousHash, b, c, d, e}
    {:noreply, state}
  end
  def handle_cast({:updatingNonce, nonce}, state) do
    {a, b, c , _, e} = state
    state = {a, b, c, nonce, e}
    {:noreply, state}
  end
end
#user
defmodule User do
  use GenServer
  def init([]) do
     {public_key, private_key} = :crypto.generate_key(:ecdh, :crypto.ec_curve(:secp256k1))
     user_id = Nanoid.generate()
     {:ok, {private_key, public_key, user_id}}
  end
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end
  def get_private_key(pid) do
    GenServer.call(pid, {:gettingPrivateKey})
  end
   def get_user_id(pid) do
    GenServer.call(pid, {:getUserId})
  end
  def sign_transaction(pid, transcationid) do
    amount = BitcoinTransaction.getAmount(transcationid)
    private_key = get_private_key(pid)
    sign = :crypto.sign(:ecdsa,:sha256,Float.to_string(amount),[private_key,:secp256k1])
    BitcoinTransaction.update_sign(transcationid, sign)
  end
  def get_public_key(pid) do
    GenServer.call(pid, {:gettingPublicKey})
  end
  def getAmount(pid) do
    GenServer.call(pid, {:gettingAmount})
  end
  def update_amount(pid, amount) do
    GenServer.cast(pid, {:updatingAmount, amount})
  end
   def handle_call({:getUserId}, _from, state) do
    {_, _ , amount} = state
    {:reply, amount, state}
  end
  def handle_call({:gettingPrivateKey}, _from, state) do
    {private_key, _, _} = state
    {:reply, private_key, state}
  end
  def handle_call({:gettingPublicKey}, _from, state) do
    {_, public_key, _} = state
    {:reply, public_key, state}
  end
  def handle_call({:gettingAmount}, _from, state) do
    {_, _ , amount} = state
    {:reply, amount, state}
  end
  def handle_cast({:updatingAmount, amount}, state) do
    {a, b, _} = state
    state = {a, b, amount}
    {:noreply, state}
  end
end

#transaction
defmodule BitcoinTransaction do
  use GenServer
  def init([from_address, to_address, amount]) do
    {:ok, {from_address, to_address, amount, None}}
  end
  def start_link(from_address, to_address, amount) do
    GenServer.start_link(__MODULE__, [from_address, to_address, amount])
  end
  def getAmount(pid) do
  GenServer.call(pid, {:gettingAmount})
  end
  def get_signature(pid) do
    GenServer.call(pid, {:gettingSign})
  end
  def verify_transaction(pid, user_public_key) do
    sign = get_signature(pid)
    amount = getAmount(pid)
    :crypto.verify(:ecdsa,:sha256,Float.to_string(amount),sign,[user_public_key,:secp256k1])
  end
  def get_from_address(pid) do
    GenServer.call(pid, {:gettingFromAddress})
  end
  def get_to_address(pid) do
    GenServer.call(pid, {:gettingToAddress})
  end
  def update_sign(pid, sign) do
    GenServer.cast(pid, {:updatingSign, sign})
  end
  def handle_call({:gettingFromAddress}, _from, state) do
    {from_address, _, _, _} = state
    {:reply, from_address, state}
  end
  def handle_call({:gettingSign}, _from, state) do
    {_, _, _, sign} = state
    {:reply, sign, state}
  end
  def handle_call({:gettingToAddress}, _from, state) do
    {_, to_address, _, _} = state
    {:reply, to_address, state}
  end
  def handle_call({:gettingAmount}, _from, state) do
    {_, _, amount, _} = state
    {:reply, amount, state}
  end
  def handle_cast({:updatingSign, sign}, state) do
    {a, b, c, _} = state
    state = {a, b, c, sign}
    {:noreply, state}
  end
end





