#!/bin/sh
# The local chain (anvil, as upstream's `yarn network`, with the deployed levels loaded) on 8545
# and the client on 3000. The container stops when either stops.
anvil --host 0.0.0.0 --port 8545 --block-time 1 --auto-impersonate --load-state /chain/state.json &
nginx -g 'daemon off;' &
wait -n
