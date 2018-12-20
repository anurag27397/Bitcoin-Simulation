defmodule Test do
  use ExUnit.Case
  doctest Implementation

  @compile :nowarn_unused_vars

  #validates that the hash of the mined block with threshold 4 starts with 4 zeroes
   test "testing hashcode with difficulty: 4" do
     {:ok, pid} = Block.start_link()
     previousHash = Block.get_previousHash(pid)
     timeStamp = Integer.to_string(Block.get_timeStamp(pid))
     transactions = List.to_string(Block.get_transactions(pid))
     nonce = Block.get_nonce(pid)
     hash = Block.generate_hash(4, pid, previousHash, timeStamp, transactions, nonce)
     assert String.match?(hash, ~r/^0000/);
    end

#validates that the hash of the mined block with threshold 5 starts with 5 zeroes
    test "testing hashcode with difficulty: 5" do
      {:ok, pid} = Block.start_link()
      previousHash = Block.get_previousHash(pid)
      timeStamp = Integer.to_string(Block.get_timeStamp(pid))
      transactions = List.to_string(Block.get_transactions(pid))
      nonce = Block.get_nonce(pid)
      hash = Block.generate_hash(5, pid, previousHash, timeStamp, transactions, nonce)
      assert String.match?(hash, ~r/^00000/);
     end


#checks the validity of a block with no transactions
     test "testing for block having zero transactions" do
       {:ok, pid} = Block.start_link()
       assert Block.is_valid(pid) == true
     end

    # verifies that all transactions done within a block are valid
     test "testing for valid block" do
       {:ok, user1_id} = BitcoinUser.start_link()
       {:ok, user2_id} = BitcoinUser.start_link()
       user1_address = BitcoinUser.get_public_key(user1_id)
       user2_address = BitcoinUser.get_public_key(user2_id)
       {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 500.0)
       BitcoinUser.sign_transaction(user1_id, txn1_id)
       {:ok, txn2_id} = BitcoinTransaction.start_link(user2_address, user1_address, 200.0)
       BitcoinUser.sign_transaction(user2_id, txn2_id)
       transaction_list = [txn1_id, txn2_id]
       {:ok, pid} = Block.start_link()
       Block.update_transactions(pid, transaction_list)
       assert Block.is_valid(pid) == true
     end

#verifies that a block with invalid transactions is flagged as an invalid block
     test "testing for invalid block" do
       {:ok, user1_id} = BitcoinUser.start_link()
       {:ok, user2_id} = BitcoinUser.start_link()
       user1_address = BitcoinUser.get_public_key(user1_id)
       user2_address = BitcoinUser.get_public_key(user2_id)
       {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 500.0)
       BitcoinUser.sign_transaction(user1_id, txn1_id)
       {:ok, txn2_id} = BitcoinTransaction.start_link(user2_address, user1_address, 200.0)
       BitcoinUser.sign_transaction(user1_id, txn2_id)
       transaction_list = [txn1_id, txn2_id]
       {:ok, pid} = Block.start_link()
       Block.update_transactions(pid, transaction_list)
       assert Block.is_valid(pid) == false
     end
end

#############

defmodule BlockChainTest do
  use ExUnit.Case
  doctest Implementation

  test "start a blockchain with genesis block" do
    {:ok, block_chain_pid} = Implementation.start_link()
    assert Enum.count(Implementation.get_chain(block_chain_pid)) == 1
  end

  test "testing for transactions having multiple block and rewards for mining blocks" do
    difficulty = 4
    {:ok, block_chain_pid} = Implementation.start_link()
    {:ok, user1_id} = BitcoinUser.start_link()
    Implementation.add_user(block_chain_pid, user1_id)
    user1_address = BitcoinUser.get_public_key(user1_id)
    mining_reward = 150.0
    Implementation.updateMineReward(block_chain_pid, mining_reward)
    Implementation.pendingTransaction(block_chain_pid, user1_address, difficulty)
    {:ok, user2_id} = BitcoinUser.start_link()
    {:ok, user3_id} = BitcoinUser.start_link()
    Implementation.add_user(block_chain_pid, user2_id)
    Implementation.add_user(block_chain_pid, user3_id)
    user2_address = BitcoinUser.get_public_key(user2_id)
    user3_address = BitcoinUser.get_public_key(user3_id)


    {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 90.0)
    BitcoinUser.sign_transaction(user1_id, txn1_id)
    Implementation.add_transaction(block_chain_pid, txn1_id)

    {:ok, txn2_id} = BitcoinTransaction.start_link(user2_address, user3_address, 50.0)
    BitcoinUser.sign_transaction(user2_id, txn2_id)
    Implementation.add_transaction(block_chain_pid, txn2_id)
    Implementation.pendingTransaction(block_chain_pid, user3_address, difficulty)

    user1_balance = Implementation.get_balance(block_chain_pid, user1_address)
    user2_balance = Implementation.get_balance(block_chain_pid, user2_address)
    user3_balance = Implementation.get_balance(block_chain_pid, user3_address)
    IO.inspect(user1_balance)
    IO.inspect(user2_balance)
    IO.inspect(user3_balance)
    check1 = user1_balance == 60.0 and user2_balance==40.0 and user3_balance==50.0

    {:ok, txn_c_id} = BitcoinTransaction.start_link(user3_address, user2_address, 30.0)
    BitcoinUser.sign_transaction(user3_id, txn_c_id)
    Implementation.add_transaction(block_chain_pid, txn_c_id)

    {:ok, txn_d_id} = BitcoinTransaction.start_link(user1_address, user3_address, 20.0)
    BitcoinUser.sign_transaction(user1_id, txn_d_id)
    Implementation.add_transaction(block_chain_pid, txn_d_id)

    {:ok, txn_e_id} = BitcoinTransaction.start_link(user2_address, user1_address, 20.0)
    BitcoinUser.sign_transaction(user2_id, txn_e_id)
    Implementation.add_transaction(block_chain_pid, txn_e_id)
    Implementation.pendingTransaction(block_chain_pid, user2_address, difficulty)

    user1_balance = Implementation.get_balance(block_chain_pid, user1_address)
    user2_balance = Implementation.get_balance(block_chain_pid, user2_address)
    user3_balance = Implementation.get_balance(block_chain_pid, user3_address)
    IO.inspect(user1_balance)
    IO.inspect(user2_balance)
    IO.inspect(user3_balance)
    check2 = user1_balance == 60.0 and user2_balance == 50.0 and user3_balance == 190.0 and Implementation.is_valid(block_chain_pid)

    assert check1 == true and check2 == true
  end

  test "testing for valid block chain" do
    difficulty = 2
    {:ok, block_chain_pid} = Implementation.start_link()
    {:ok, user1_id} = BitcoinUser.start_link()
    {:ok, user2_id} = BitcoinUser.start_link()
    user1_address = BitcoinUser.get_public_key(user1_id)
    user2_address = BitcoinUser.get_public_key(user2_id)
    block_1_pid = Implementation.pendingTransaction(block_chain_pid, user1_address, difficulty)
    {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 500.0)
    BitcoinUser.sign_transaction(user1_id, txn1_id)
    {:ok, txn2_id} = BitcoinTransaction.start_link(user2_address, user1_address, 200.0)
    BitcoinUser.sign_transaction(user2_id, txn2_id)
    Implementation.add_transaction(block_chain_pid, txn1_id)
    Implementation.add_transaction(block_chain_pid, txn2_id)
    block_2_pid = Implementation.pendingTransaction(block_chain_pid, user2_address, difficulty)
    assert Implementation.is_valid(block_chain_pid) == true
  end

  test "testing for invalid block chain having given one block is invalid" do
    difficulty = 2
    {:ok, block_chain_pid} = Implementation.start_link()
    {:ok, user1_id} = BitcoinUser.start_link()
    {:ok, user2_id} = BitcoinUser.start_link()
    user1_address = BitcoinUser.get_public_key(user1_id)
    user2_address = BitcoinUser.get_public_key(user2_id)
    block_1_pid = Implementation.pendingTransaction(block_chain_pid, user1_address, difficulty)
    {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 500.0)
    BitcoinUser.sign_transaction(user1_id, txn1_id)
    {:ok, txn2_id} = BitcoinTransaction.start_link(user2_address, user1_address, 200.0)
    BitcoinUser.sign_transaction(user1_id, txn2_id)
    Implementation.add_transaction(block_chain_pid, txn1_id)
    Implementation.add_transaction(block_chain_pid, txn2_id)
    block_2_pid = Implementation.pendingTransaction(block_chain_pid, user2_address, difficulty)
    assert Implementation.is_valid(block_chain_pid) == false
  end

  test "transacting 100.0 from user1 to user2" do
    difficulty = 2
    {:ok, block_chain_pid} = Implementation.start_link()
    {:ok, user1_id} = BitcoinUser.start_link()
    {:ok, user2_id} = BitcoinUser.start_link()
    user1_address = BitcoinUser.get_public_key(user1_id)
    user2_address = BitcoinUser.get_public_key(user2_id)
    block_1_pid = Implementation.pendingTransaction(block_chain_pid, user1_address, difficulty)
    {:ok, txn1_id} = BitcoinTransaction.start_link(user1_address, user2_address, 100.0)
    BitcoinUser.sign_transaction(user1_id, txn1_id)
    Implementation.add_transaction(block_chain_pid, txn1_id)
    block_2_pid = Implementation.pendingTransaction(block_chain_pid, user2_address, difficulty)
    assert Implementation.get_balance(block_chain_pid, user2_address) == 100.0 and Implementation.get_balance(block_chain_pid, user1_address) == -100.0
  end

end

############
defmodule TransactionTest do
  use ExUnit.Case
  doctest Implementation

#testing the validity of the transaction when User1 sends $100 to user2 signing with its public_key
  test "testing validity of a transaction" do
    {:ok, user1_id} = BitcoinUser.start_link()
    from_address = BitcoinUser.get_public_key(user1_id)
    {:ok, user2_id} = BitcoinUser.start_link()
    to_address = BitcoinUser.get_public_key(user2_id)
    amount = 100.0;
    {:ok, transcationid} = BitcoinTransaction.start_link(from_address,to_address,amount)
    BitcoinUser.sign_transaction(user1_id, transcationid)
    assert BitcoinTransaction.verify_transaction(transcationid,from_address)
   end

  #verifying that the transaction was not signed by User2. Here User1 sends $100 to User2 signing with its public_key and User2 falsely impersonates the receiver.
    test "testing for invalid transaction when receiver tries to impersonates the sender" do
      {:ok, user1_id} = BitcoinUser.start_link()
      user1_address = BitcoinUser.get_public_key(user1_id)
      {:ok, user2_id} = BitcoinUser.start_link()
      user2_address = BitcoinUser.get_public_key(user2_id)
      amount = 100.0;
      {:ok, transcationid} = BitcoinTransaction.start_link(user1_address, user2_address, amount)
      BitcoinUser.sign_transaction(user1_id, transcationid)
      assert BitcoinTransaction.verify_transaction(transcationid, user2_address) == false
    end

    #flagging invalid transactions when User1 sends $100 to User2 signing with its public_key and User3 falsely claiming that he sent the money.
    test "testing for invalid transaction when a different user impersonates the sender" do
      {:ok, user1_id} = BitcoinUser.start_link()
      user1_address = BitcoinUser.get_public_key(user1_id)
      {:ok, user2_id} = BitcoinUser.start_link()
      user2_address = BitcoinUser.get_public_key(user2_id)
      amount = 100.0;
      {:ok, user3_id} = BitcoinUser.start_link()
      user3_address = BitcoinUser.get_public_key(user3_id)
      {:ok, transcationid} = BitcoinTransaction.start_link(user1_address, user2_address,amount)
      BitcoinUser.sign_transaction(user1_id, transcationid)
      assert BitcoinTransaction.verify_transaction(transcationid, user3_address) == false
    end

end
