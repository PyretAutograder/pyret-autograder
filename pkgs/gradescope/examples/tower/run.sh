#/usr/bin/env bash

set -euo pipefail

pushd "$(dirname "$0")/../../../../"
$(nix build .#gradescope-build-docker --no-link --print-out-paths) | docker load
$(nix build .#gradescope-run-docker --no-link --print-out-paths) | docker load

TAG=example-assignment-tower

docker build --tag $TAG -f ./pkgs/gradescope/examples/tower/Dockerfile .

echo Successfully built $TAG

# docker run -it --entrypoint /usr/bin/bash $TAG:latest -lc \
#   'cd /autograder; ./run_autograder; cat results/results.json'
popd

