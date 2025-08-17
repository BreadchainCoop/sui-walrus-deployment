
<!-- Install sui -->
brew install sui

<!-- Setup walrus -->
# Run a first-time install using the latest Mainnet version.
curl -sSf https://install.wal.app | sh

# Install the latest Testnet version instead.
curl -sSf https://install.wal.app | sh -s -- -n testnet

<!-- Paste configuration yaml in ~/.config/walrus/client_config.yaml -->
contexts:
  mainnet:
    system_object: 0x2134d52768ea07e8c43570ef975eb3e4c27a39fa6396bef985b5abc58d03ddd2
    staking_object: 0x10b9d30c28448939ce6c4d6c6e0ffce4a7f8a4ada8248bdad09ef8b70e4a3904
    exchange_objects: []
    wallet_config:
      # Optional path to the wallet config file.
      # path: ~/.sui/sui_config/client.yaml
      # Sui environment to use.
      active_env: mainnet
      # Optional override for the Sui address to use.
      # active_address: 0x0000000000000000000000000000000000000000000000000000000000000000
    rpc_urls:
      - https://fullnode.mainnet.sui.io:443
  testnet:
    system_object: 0x6c2547cbbc38025cf3adac45f63cb0a8d12ecf777cdc75a4971612bf97fdf6af
    staking_object: 0xbe46180321c30aab2f8b3501e24048377287fa708018a5b7c2792b35fe339ee3
    exchange_objects:
      - 0xf4d164ea2def5fe07dc573992a029e010dba09b1a8dcbc44c5c2e79567f39073
      - 0x19825121c52080bb1073662231cfea5c0e4d905fd13e95f21e9a018f2ef41862
      - 0x83b454e524c71f30803f4d6c302a86fb6a39e96cdfb873c2d1e93bc1c26a3bc5
      - 0x8d63209cf8589ce7aef8f262437163c67577ed09f3e636a9d8e0813843fb8bf1
    wallet_config:
      # Optional path to the wallet config file.
      # path: ~/.sui/sui_config/client.yaml
      # Sui environment to use.
      active_env: testnet
      # Optional override for the Sui address to use.
      # active_address: 0x0000000000000000000000000000000000000000000000000000000000000000
    rpc_urls:
      - https://fullnode.testnet.sui.io:443
default_context: testnet



<!-- Paste in ~/.config/walrus/site-config.yaml -->
```
contexts:
  testnet:
    # module: site
    # portal: wal.app
    package: 0xf99aee9f21493e1590e7e5a9aea6f343a1f381031a04a732724871fc294be799
    staking_object: 0xbe46180321c30aab2f8b3501e24048377287fa708018a5b7c2792b35fe339ee3
    general:
       wallet_env: testnet
       walrus_context: testnet # Assumes a Walrus CLI setup with a multi-config containing the "testnet" context.
       walrus_package: 0xd84704c17fc870b8764832c535aa6b11f21a95cd6f5bb38a9b07d2cf42220c66
       # wallet_address: 0x1234...
       # rpc_url: https://fullnode.testnet.sui.io:443
       # wallet: /path/to/.sui/sui_config/client.yaml
       # walrus_binary: /path/to/walrus
       # walrus_config: /path/to/testnet/client_config.yaml
       # gas_budget: 500000000
  mainnet:
    # module: site
    # portal: wal.app
    package: 0x26eb7ee8688da02c5f671679524e379f0b837a12f1d1d799f255b7eea260ad27
    staking_object: 0x10b9d30c28448939ce6c4d6c6e0ffce4a7f8a4ada8248bdad09ef8b70e4a3904
    general:
       wallet_env: mainnet
       walrus_context: mainnet # Assumes a Walrus CLI setup with a multi-config containing the "mainnet" context.
       walrus_package: 0xfdc88f7d7cf30afab2f82e8380d11ee8f70efb90e863d1de8616fae1bb09ea77
       # wallet_address: 0x1234...
       # rpc_url: https://fullnode.mainnet.sui.io:443
       # wallet: /path/to/.sui/sui_config/client.yaml
       # walrus_binary: /path/to/walrus
       # walrus_config: /path/to/mainnet/client_config.yaml
       # gas_budget: 500000000

default_context: testnet
```

<!-- Check envs (not _needed_ for workflow) -->
sui client envs

<!-- extract sui wallet address from output-->
sui client addresses

<!-- get gas by replacing address -->
https://faucet.sui.io/?address=0x0e5ecf81b88076e73c7b30630128e026f3752b678c4190e5a75fab44620e51f1

<!-- swap to wal -->
walrus get-wal

<!-- site builder  -->
SYSTEM=macos-arm64
curl https://storage.googleapis.com/mysten-walrus-binaries/site-builder-testnet-latest-$SYSTEM -o site-builder
chmod +x site-builder

<!-- to check if working -->
./site-builder

<!-- - Set static config fielto reachabck to during CICD and deploymet  -->
./site-builder --config ~/.config/walrus/site-config.yaml --context testnet deploy ./dist --epochs 1


<!-- get site from output, replace localhost:3000 with buildonwalrus.dev -->
http://1z95qybnrqtkofhf7w3y5gu2e3osq7jpemsv1tczhvff4wwswo.localhost:3000
incorrect -> 
http://1z95qybnrqtkofhf7w3y5gu2e3osq7jpemsv1tczhvff4wwswo.buildonwalrus.dev