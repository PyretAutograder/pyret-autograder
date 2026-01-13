# Pyret Autograder

An extensible autograding system for Pyret programming assignments that supports
dependency-based grading. Graders are organized as a directed acyclic graph
where dependencies control execution flow; it can generate artifacts for manual
review alongside automated scoring.

## Overview

This autograder supports multiple testing paradigms:

- **Functional tests**: Check implementation correctness
- **Examplar tests**: Validate student tests using wheat/chaff implementations
- **Test diversity**: Ensure varied test coverage
- **Training wheels**: Restrict language features
- **Artifacts**: Generate images and reports for manual review

Tests are organized as a directed acyclic graph where dependencies control execution:
- Failed prerequisites automatically skip downstream tests
- Clear error propagation and reporting
- Separate student-facing and staff-facing output

## Platform Support

- **Gradescope**: Docker-based automated grading
- **Pawtograder**: JSON-based API integration
- **CLI**: Local testing for instructors

## Getting Started

### For Course Staff

#### Gradescope

See [pkgs/gradescope/README.md](pkgs/gradescope/README.md) for setup instructions.

#### Pawtograder (currently only used by Northeastern)

There aren't currently any docs, feel free to email me.

### For Developers

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup.

## Project Status

This is pre-release software that has been successfully used for real assignments.

The core architecture is solid, but documentation and API design is still being refined.

Issues and PRs are welcome.

## Architecture

The system is built around a DAG execution model where each grader can produce one of four outcomes:

- **noop**: Guard passed, continue execution
- **emit**: Test produced a result (score/artifact)
- **block**: Stop downstream tests (e.g. parse error)
- **internal-error**: Autograder bug

This enables flexible composition of test types with automatic dependency resolution.

See [pkgs/core/DESIGN.md](pkgs/core/DESIGN.md) for detailed architecture documentation.

## License

LGPL-3.0-or-later. See [COPYING](COPYING) and [COPYING.LESSER](COPYING.LESSER).
