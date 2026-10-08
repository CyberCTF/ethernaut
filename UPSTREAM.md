# Upstream

| | |
| --- | --- |
| Project | Ethernaut |
| Repository | https://github.com/OpenZeppelin/ethernaut |
| Version | master (no releases) |
| Commit | d05643a40aa98c45d66247c69ffceab8f44dd8cb (2025-11-19) |
| Licence | AGPL-3.0 |

`build/ethernaut/app/` is that commit, unchanged, without its Git history. The `contracts/lib/`
folders are Git submodules upstream (forge-std, OpenZeppelin contracts) and are not vendored:
nothing here compiles the contracts. The deployment uses the compiled artifacts upstream commits
in `contracts/out/`, as upstream's client does.

`build/ethernaut/Dockerfile` is ours (upstream ships none). It runs upstream's README steps for a
local network at image build time; its header comment lists every step and each difference:
Foundry's anvil v1.8.3 (release tarball, SHA-256 pinned) as the chain, `ACTIVE_NETWORK` set to
`NETWORKS.LOCAL` on the build copy of `client/src/constants.js` (README step 5), upstream's
`client/scripts/deploy_contracts.mjs` deploying the game and every level, the chain state dumped
and loaded at run time, `yarn install` without `--frozen-lockfile` (upstream's lockfile is
slightly out of date), and the client built without source maps on a larger Node.js heap.
`nginx.conf` and `start.sh` serve the client on 3000 and run the chain on 8545.

To update, replace `build/ethernaut/app/` with a newer commit, then this table.
