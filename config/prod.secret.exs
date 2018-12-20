use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :blockchain, BlockchainWeb.Endpoint,
  secret_key_base: "voyM0RZdYwe7zVg+7PyVIBtdGpEa/vNhb09gluKjQ/hQDBHYjVJWUjUnYJWs0NqD"

# Configure your database
config :blockchain, Blockchain.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "blockchain_prod",
  pool_size: 15
