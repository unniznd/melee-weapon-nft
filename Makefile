-include .env

.PHONY: all test clean deploy fund help install update snapshot format anvil mint switch wallet-import

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Import a private key into Foundry's encrypted keystore (prompts for the key and a password interactively).
# Run once per account: make wallet-import ACCOUNT=my-account
wallet-import:
	@cast wallet import $(ACCOUNT) --interactive

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Verification only applies to deploy (it's the only script that creates a new contract).
VERIFY_ARGS :=

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --sender $(SENDER) --broadcast -vvvv
	VERIFY_ARGS := --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
endif

deploy:
	@forge script script/DeployMeleeWeaponNFT.s.sol:DeployMeleeWeaponNFT $(NETWORK_ARGS) $(VERIFY_ARGS)

mint:
	@forge script script/Interactions.s.sol:MintMeleeWeaponNFT $(NETWORK_ARGS)

# SwitchMeleeMeleeWeaponNFT.run takes a tokenId, so it must be invoked via --sig instead of
# the default zero-arg entrypoint: make switch TOKEN_ID=0
switch:
	@forge script script/Interactions.s.sol:SwitchMeleeMeleeWeaponNFT $(NETWORK_ARGS) --sig "run(uint256)" $(TOKEN_ID)
