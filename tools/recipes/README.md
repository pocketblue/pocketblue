# tools/recipes/

Purpose: place long-running or complex shell logic in small, testable scripts under `tools/recipes/bin/` and keep `Justfile` entries as thin delegators.

Conventions
- Scripts: `tools/recipes/bin/*.sh` (POSIX/bash), accept explicit args and fallback to `PB_*` env vars.
- Delegator Justfile: `tools/recipes/Justfile` — thin wrappers that call the scripts.
- CI entrypoints: `tests/ci/Justfile` provides CI-friendly targets which call top-level or `tools/recipes` delegators.

Why
- Improves readability and testability
- Makes it easy to add shellcheck / unit tests
- Keeps top-level `Justfile` as a single source of workflow truth
