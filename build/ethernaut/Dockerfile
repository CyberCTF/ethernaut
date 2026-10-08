# Ethernaut, run fully locally: upstream ships no Dockerfile, so this one follows upstream's
# README for a local network, step by step, at image build time:
#   - a local chain: anvil (Foundry v1.8.3, the release tarball pinned by SHA-256), as upstream's
#     `yarn network` (`anvil --block-time 1 --auto-impersonate`);
#   - README step 5, "set ACTIVE_NETWORK to NETWORKS.LOCAL" in client/src/constants.js: done by
#     the sed below on the build copy (the vendored file is unchanged);
#   - README step 6, `yarn deploy:contracts`: upstream's own client/scripts/deploy_contracts.mjs
#     deploys Ethernaut, its statistics proxy and every level, and writes
#     client/src/gamedata/deploy.local.json. It runs against the contract artifacts upstream
#     commits in contracts/out/ (the `forge build` step before it needs the contracts/lib Git
#     submodules, which are not vendored); answers "y" to its confirmation prompt;
#   - `yarn install` without --frozen-lockfile: upstream's yarn.lock is slightly out of date with
#     its package.json files (yarn refuses --frozen-lockfile); every entry it lists is still used;
#   - the chain's state after deployment is dumped and the React client is built against that
#     deploy.local.json (`yarn --cwd client build`, as upstream's Netlify build, CI=false), without source maps
#     and with a 3 GB Node.js heap (the default heap runs out of memory).
# The image then serves the built client with nginx on port 3000 (every path falls back to
# index.html, as upstream's netlify.toml redirect) and runs anvil on port 8545, loading the
# dumped state, so the levels sit at the addresses the client knows.
FROM node:16.20.1-bullseye AS build
ARG FOUNDRY=v1.8.3
ARG FOUNDRY_SHA256=72a0e8ce069c50655a7d7d939089a42e242debfb902339b26561dd3e8757d6c0
RUN curl -fsSL -o /tmp/foundry.tgz \
      "https://github.com/foundry-rs/foundry/releases/download/${FOUNDRY}/foundry_${FOUNDRY}_alpine_amd64.tar.gz" \
 && echo "${FOUNDRY_SHA256}  /tmp/foundry.tgz" | sha256sum -c - \
 && tar -xzf /tmp/foundry.tgz -C /usr/local/bin anvil cast \
 && rm /tmp/foundry.tgz
COPY app/ /ethernaut
WORKDIR /ethernaut
RUN yarn install --network-timeout 600000
RUN sed -i 's|^// export const ACTIVE_NETWORK = NETWORKS.LOCAL;|export const ACTIVE_NETWORK = NETWORKS.LOCAL;|' client/src/constants.js \
 && grep -q '^export const ACTIVE_NETWORK = NETWORKS.LOCAL;' client/src/constants.js
RUN set -e; mkdir -p /chain; \
    anvil --host 127.0.0.1 --port 8545 --auto-impersonate --dump-state /chain/state.json > /chain/anvil.log 2>&1 & \
    pid=$!; \
    until cast chain-id --rpc-url http://127.0.0.1:8545 >/dev/null 2>&1; do sleep 1; done; \
    echo y | node --experimental-json-modules client/scripts/deploy_contracts.mjs; \
    kill -INT $pid; wait $pid || true; \
    test -s /chain/state.json; \
    test -s client/src/gamedata/deploy.local.json; \
    cat client/src/gamedata/deploy.local.json
RUN CI=false GENERATE_SOURCEMAP=false NODE_OPTIONS=--max-old-space-size=3072 yarn --cwd client build

FROM nginx:1.27.5-alpine
COPY --from=build /usr/local/bin/anvil /usr/local/bin/anvil
COPY --from=build /chain/state.json /chain/state.json
COPY --from=build /ethernaut/client/build /usr/share/nginx/html
COPY --from=build /ethernaut/client/src/gamedata/deploy.local.json /usr/share/nginx/html/deploy.local.json
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY start.sh /start.sh
EXPOSE 3000 8545
ENTRYPOINT ["/bin/sh", "/start.sh"]
