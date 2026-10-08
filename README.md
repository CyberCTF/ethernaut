# Ethernaut

[Ethernaut](https://github.com/OpenZeppelin/ethernaut) by [OpenZeppelin](https://www.openzeppelin.com):
a Web3/Solidity wargame played in the browser, where each level is a smart contract to hack.
This repository runs it fully locally with [Isoloom](https://www.isoloom.com):
[`isoloom.yml`](isoloom.yml) describes the machine, and
[`build/ethernaut/Dockerfile`](build/ethernaut/Dockerfile) follows upstream's README for a local
network at image build time: a local chain (Foundry's anvil), the game and every level deployed
by upstream's own deploy script, and the React client built against that deployment.

| Machine | Services |
| --- | --- |
| ethernaut | the game on port 3000, the local chain (JSON-RPC, chain id 31337) on 8545 |

## Run it

```bash
isoloom generate
isoloom run docker
```

The game needs a browser wallet, as on the public site. In MetaMask (or another injected
wallet):

1. Add a network: RPC URL http://localhost:8545, chain id 31337, currency symbol ETH.
2. Import an account from a private key, one of anvil's published development keys, for example
   `0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d` (address
   `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`, 10000 test ETH). These keys are public: never
   use them on a real network.
3. Open http://localhost:3000/, connect the wallet, open the browser console and type `help()`.

The chain starts from the deployed state at every start: instances and progress do not survive
`isoloom down`, and the browser keeps its own record of completed levels. If MetaMask complains
about a nonce after a restart, clear its activity for that account (Settings, Advanced). Block
timestamps continue from the time the image was built.

Lab guide: the level descriptions in the game. Upstream version and commit:
[UPSTREAM.md](UPSTREAM.md).

## Licence

AGPL-3.0, as Ethernaut ([LICENSE](LICENSE)), copyright OpenZeppelin.

Source offer (AGPL-3.0 section 13): anyone who interacts with this application over a network
can get its complete corresponding source, unchanged, from this repository
([`build/ethernaut/app/`](build/ethernaut/app), the commit named in [UPSTREAM.md](UPSTREAM.md))
together with the build files that produce the running image, or from upstream at
https://github.com/OpenZeppelin/ethernaut. The contracts are deliberately vulnerable: never
deploy them on a real network.
