# COP5615: Dist Oper Sys Princ:  Project 4.2

## Group Info:
Name: Anurag K Gupta
UFID:  9152-4969
————————

## Instructions:
_How to run?_
1. Extract “Anurag.zip” file
2. Open terminal and cd to the project folder
3. Run  “mix phx.server”
————————

## Implemented functionalities:
1. Ability to mine new bitcoin with given difficulty using Bitcoin Protocol.
2. Ability to add the transaction to the blockchain.
3. Ability to validity the transactions and display wallet's balance.

## Transacting Scenarios:
1. testing hash code with difficulty 4 which validates that the hash of the mined block with threshold 4 starts with 4 zeroes.
2. testing hash code with difficulty  5 which validates that the hash of the mined block with threshold 5 starts with 5 zeroes
3. testing for block having zero transactions which checks the validity of a block with no transactions.
4. testing for valid block which verifies that all transactions done within a block are valid.
5. testing for invalid block which verifies that a block with invalid transactions is flagged as an invalid block.
6. testing for transactions having multiple block and mining Rewards.
7. testing for valid block chain.
8. testing for invalid block chain having given one block is invalid.
9. testing validity of a transaction: testing the validity of the transaction when User1 sends $100 to user2 signing with its public_key
10. testing for invalid transaction when receiver tries to impersonates the sender: Verifying that the transaction was not signed by User2. Here User1 sends $100 to User2 signing with its public_key and User2 falsely impersonates the receiver.
11. testing for invalid transaction when a different user impersonates the sender: flagging invalid transactions when User1 sends $100 to User2 signing with its public_key and User3 falsely claiming that he sent the money.

## Scenarios Tested:
test "transacting 100.0 from user1 to user2"
User 1 sends $100 to User 2 and User 2's balance gets reduced by $100 while User 2 gains $100.

test "testing for transactions having multiple block and rewards for mining blocks".
User 1 received $150 as mining award. User 1 mines the first block.

Transactions :
User 1 sends $90 to User 2
User 2 sends $50 to User 3

Updated Balance:
User 1: $60
User 2: $40
User 3: $50

User 3 mines the next block. User 3 received $150  as mining reward

Transactions :
User 3 sends $30 to User 2
User 1 sends $20 to User 3
User 2 sends $20 to User 1

Updated Balance:
User 1: $60
User 2: $50
User 3: $190


![](COP5615:%20Dist%20Oper%20Sys%20Princ:%20%20Project%204.2/A7AE0319-903D-43CC-BD0C-8560C3A07525.png)

![](COP5615:%20Dist%20Oper%20Sys%20Princ:%20%20Project%204.2/0A154B8A-D35F-4F10-8364-BF60D34CC9A7.png)

![](COP5615:%20Dist%20Oper%20Sys%20Princ:%20%20Project%204.2/904CF81A-895A-4784-AF26-580F333B38A4.png)

![](COP5615:%20Dist%20Oper%20Sys%20Princ:%20%20Project%204.2/ED8D9B21-0215-456E-B7E0-7759E900E2A6.png)