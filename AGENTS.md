# Repository Guidelines

## Project Structure & Module Organization
- Source: `app/` (models, controllers, views, jobs, channels), assets in `app/assets/` via Propshaft.
- Configuration: `config/` (environments, routes), Rack entry `config.ru`.
- Database: `db/` (schema, migrations). Temp/runtime: `log/`, `tmp/`, `storage/`.
- Libraries: `lib/`. Public files: `public/`. Executables: `bin/`.
- Tests: `test/` (Minitest: `models/`, `controllers/`, `system/`, fixtures in `test/fixtures/`).

## Build, Test, and Development Commands
- Setup: `bin/setup` — installs gems, prepares DB, clears logs/tmp.
- Run app: `bin/dev` — starts the Rails server (default: http://localhost:3000).
- Database: `bin/rails db:prepare` — create/migrate; `db:reset` to rebuild.
- Tests: `bin/rails test` — run all tests; scope with `test/models/user_test.rb`.
- Lint: `bin/rubocop` — style checks; use `-A` for safe autocorrect.
- Security: `bin/brakeman` — static security analysis.

## Coding Style & Naming Conventions
- Ruby: 2-space indent, single quotes for simple strings, snake_case methods/files, CamelCase classes.
- Rails: models in `app/models` (singular), controllers in `app/controllers` (plural), tests end with `_test.rb`.
- Follow RuboCop Omakase rules (`.rubocop.yml`). Keep methods small; prefer service objects/helpers for complex logic.

## Testing Guidelines
- Framework: Minitest with fixtures. Place unit tests under `test/models`, request/controller under `test/controllers`, system under `test/system`.
- Naming: mirror class/file names; one assertion purpose per test where practical.
- Running: `bin/rails test`; specific file: `bin/rails test test/models/example_test.rb`.

## Commit & Pull Request Guidelines
- Commits: imperative mood and scoped, e.g., `Add User#active?` or Conventional Commits like `feat(auth): add session timeout`.
- Include context: why + what changed; separate refactors from behavior changes.
- PRs: clear description, linked issues (e.g., `Closes #123`), screenshots for UI, migration notes, and local runbook (how reviewed).
- Checks: ensure `bin/rails test`, `bin/rubocop`, and `bin/brakeman` pass; include any new tests/fixtures.

## Security & Configuration Tips
- Secrets: use Rails credentials; never commit secrets or local `.env` files.
- Docker/Kamal: see `Dockerfile` for container build; deployment hooks/config live in `.kamal/`.
