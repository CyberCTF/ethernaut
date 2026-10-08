#!/bin/sh
# The local chain answers JSON-RPC as chain 31337 (0x7a69), and the Ethernaut contract the client
# was built against (deploy.local.json, served next to the client) has code on that chain: the
# deployed game and levels were loaded.
set -u
rpc() {
  curl -sS --max-time 20 -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"$1\",\"params\":$2}" http://ethernaut:8545/ 2>/dev/null
}
rpc eth_chainId '[]' | grep -q '"result":"0x7a69"' || { echo "eth_chainId"; exit 1; }
addr=$(curl -sS --max-time 20 http://ethernaut:3000/deploy.local.json 2>/dev/null \
  | tr -d ' \n' | sed -n 's/.*"ethernaut":"\(0x[0-9a-fA-F]*\)".*/\1/p')
[ -n "$addr" ] || { echo "deploy.local.json"; exit 1; }
code=$(rpc eth_getCode "[\"$addr\",\"latest\"]" | sed -n 's/.*"result":"\(0x[0-9a-fA-F]*\)".*/\1/p')
[ "${#code}" -gt 100 ] || { echo "no code at Ethernaut $addr"; exit 1; }
echo "chain 31337 answers; Ethernaut is deployed at $addr"
