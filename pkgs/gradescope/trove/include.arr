# NOTE: this file is compiled for its side effects:
# - The generated modules will become available when specifying assignment specs
#   in pyret
# - See pyret-lang/src/arr/compiler/cli-module-loader.arr for how builtin
#   modules are resolved. TLDR: basename should be in ./arr or ./js
# - See pyret-autograder/nix/packages/gradescope-build/autograder-lib.nix
#   for build details.
# This is done since it removes any need to have a concept of nodejs
# dependencies in the `gradescope-build` docker image; it also speeds up
# build-times for each assignment's docker image.

import autograder as _
import graders as _

# not intended to be used in spec:
import gradescope-support as _
