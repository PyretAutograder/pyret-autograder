#/usr/bin/env bash

set -euo pipefail

pushd "$(dirname "$0")/../../../../"
$(nix build .#gradescope-build-docker --no-link --print-out-paths) | docker load
$(nix build .#gradescope-run-docker --no-link --print-out-paths) | docker load

TAG=example-assignment-tower

docker build --tag $TAG -f ./pkgs/gradescope/examples/tower/Dockerfile .

echo Successfully built $TAG
popd

