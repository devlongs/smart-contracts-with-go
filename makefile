# The environment has three accounts all using this same passkey (123).
# Geth is started with address 0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd and is used as the coinbase address.
# The coinbase address is the account to pay mining rewards to.
# The coinbase address is give a LOT of money to start.
#
# These are examples of what you can do in the attach JS environment.
# 	eth.getBalance("0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd") or eth.getBalance(eth.coinbase)
# 	eth.getBalance("0x8e113078adf6888b7ba84967f299f29aece24c55")
# 	eth.getBalance("0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7")
#   eth.sendTransaction({from:eth.coinbase, to:"0x8e113078adf6888b7ba84967f299f29aece24c55", value: web3.toWei(0.05, "ether")})
#   eth.sendTransaction({from:eth.coinbase, to:"0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7", value: web3.toWei(0.05, "ether")})
#   eth.blockNumber
#   eth.getBlockByNumber(8)
#   eth.getTransaction("0xaea41e7c13a7ea627169c74ade4d5ea86664ff1f740cd90e499f3f842656d4ad")
#


dev.setup:
	sudo apt-get update
	sudo apt-get upgrade
	@if ! command -v geth &> /dev/null; then \
		sudo add-apt-repository -y ppa:ethereum/ethereum; \
		sudo apt-get update; \
		sudo apt-get install ethereum; \
	fi
	@if ! command -v solc &> /dev/null; then \
		sudo add-apt-repository -y ppa:ethereum/ethereum; \
		sudo apt-get update; \
		sudo apt-get install solc; \
	fi

dev.update:
	sudo apt-get update
	sudo apt-get upgrade ethereum solc

# ==============================================================================
# These commands start the Ethereum node and provide examples of attaching
# directly with potential commands to try, and creating a new account if necessary.

# This is start Ethereum in developer mode. Only when a transaction is pending will

#---------------------------- flags explanation ------------------------------------------------------------------
# Ethereum mine a block. It provides a minimal environment for development.
# --dev: This flag starts the node in a development mode, which allows you to quickly test and experiment with Ethereum without having to wait for the blockchain to sync.

# --ipcpath zarf/ethereum/geth.ipc: This flag sets the path where the node will create the IPC (inter-process communication) file. This file is used to allow other programs to interact with the Geth node.

# --http.corsdomain '*': This flag sets the allowed CORS (Cross-Origin Resource Sharing) domain for the HTTP API. The asterisk (*) allows any domain to access the API.

# --http: This flag starts the HTTP-based JSON-RPC API server, which allows you to interact with the Geth node using HTTP requests.

# --allow-insecure-unlock: This flag allows the node to unlock an account without SSL encryption.

# --rpc.allow-unprotected-txs: This flag enables unprotected transactions for the node.

# --mine: This flag enables mining for the node.

# --miner.threads 1: This flag sets the number of CPU threads that the miner should use.

# --verbosity 5: This flag sets the log level of the node. A higher value means more logs will be printed to the console.

# --datadir "zarf/ethereum/": This flag sets the directory where the node will store its data.

# --unlock 0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd: This flag unlocks the specified account.

# --password zarf/ethereum/password: This flag specifies the path to the file containing the password for the unlocked account.
# ==============================================================================
# These commands build, deploy, and run the basic smart contract.

# This will compile the smart contract and produce the binary code. Then with the
# abi and binary code, a Go source code file can be generated for Go API access.

basic-build:
	solc --abi app/basic/contract/src/basic/basic.sol -o app/basic/contract/abi/basic --overwrite
	solc --bin app/basic/contract/src/basic/basic.sol -o app/basic/contract/abi/basic --overwrite
	abigen --bin=app/basic/contract/abi/basic/Basic.bin --abi=app/basic/contract/abi/basic/Basic.abi --pkg=basic --out=app/basic/contract/go/basic/basic.go


geth-up:
	geth --dev --ipcpath zarf/ethereum/geth.ipc --http.corsdomain '*' --http --allow-insecure-unlock --rpc.allow-unprotected-txs --mine --miner.threads 1 --verbosity 5 --datadir "zarf/ethereum/" --unlock 0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd --password zarf/ethereum/password

# This will signal Ethereum to shutdown.
geth-down:
	kill -INT $(shell ps -eo pid,comm | grep " geth" | awk '{print $$1}')

# This will remove the local blockchain and let you start new.
geth-reset: 
	rm -rf zarf/ethereum/geth/

# This is a JS console environment for making geth related API calls.
geth-attach:
	geth attach --datadir zarf/ethereum/

# This will add a new account to the keystore. The account will have a zero
# balance until you give it some money.
geth-new-account:
	geth --datadir zarf/ethereum/ account new

# This will deposit 1 ETH into the two extra accounts from the coinbase account.
# Do this if you delete the geth folder and start over or if the accounts need money.
geth-deposit:
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "to":"0x8E113078ADF6888B7ba84967F299F29AeCe24c55", "value":"0x1000000000000000000"}], "id":1}' localhost:8545
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "to":"0x0070742FF6003c3E809E78D524F0Fe5dcc5BA7F7", "value":"0x1000000000000000000"}], "id":1}' localhost:8545
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "to":"0x7FDFc99999f1760e8dBd75a480B93c7B8386B79a", "value":"0x1000000000000000000"}], "id":1}' localhost:8545
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "to":"0x000cF95cB5Eb168F57D0bEFcdf6A201e3E1acea9", "value":"0x1000000000000000000"}], "id":1}' localhost:8545

# ==============================================================================
# These commands provide Go related support.

test:
	CGO_ENABLED=0 go test -count=1 ./...
	CGO_ENABLED=0 go vet ./...
	staticcheck -checks=all ./...
	govulncheck ./...

# This will tidy up the Go dependencies.
tidy:
	go mod tidy
	go mod vendor

deps-upgrade:
	# go get $(go list -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' -m all)
	go get -u -v ./...
	go mod tidy
	go mod vendor