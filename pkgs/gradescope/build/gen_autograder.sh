#!/usr/bin/env bash

set -euo pipefail

# needs to generate /autograder/run_autograder
# submission will be located at /autograder/submission

RUNTIME_SUBMSSION_DIR="/autograder/submission"

chmod +x /run_autograder
