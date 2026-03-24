# Documentation Index

Use this page when you know **what you want to do**, but not **which document to open**.

## Start here

If you are new to the repository:

1. [README.md](./README.md) — what the project is and how it is structured
2. [QUICK_START.md](./QUICK_START.md) — first working run

## If you want to...

### Run your first benchmark

Read: [QUICK_START.md](./QUICK_START.md)

### Understand the platform at a high level

Read: [README.md](./README.md)

### Understand internal architecture

Read: [CLAUDE.md](./CLAUDE.md)

### Add a new problem

Start with:

- [README.md](./README.md)
- `problems/minigit/problem.json`
- `problems/minigit/SPEC-v1.txt`
- `problems/minigit/test-v1.sh`

### Add a new codex adapter

Start with:

- [CLAUDE.md](./CLAUDE.md)
- `lib/codexes/base_codex.rb`
- `lib/codex_loader.rb`
- `config/codexes.yml`

### Add a new language

Start with:

- `benchmark.rb` (`LANGUAGES` hash)
- [CLAUDE.md](./CLAUDE.md)

### Understand planned future integrations

Read: [ROADMAP.md](./ROADMAP.md)

### Compare codexes conceptually

Read: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md)

## Practical map

| File | Why you would open it |
|------|------------------------|
| [README.md](./README.md) | overall framing and benchmark model |
| [QUICK_START.md](./QUICK_START.md) | first benchmark run, config, outputs |
| [CLAUDE.md](./CLAUDE.md) | internal architecture and extension points |
| [ROADMAP.md](./ROADMAP.md) | what codexes are planned next |
| [CODEX_COMPARISON.md](./CODEX_COMPARISON.md) | cross-codex notes and research framing |
| `benchmark.rb` | runner, language registry, problem execution loop |
| `lib/codex_loader.rb` | config loading and adapter instantiation |
| `lib/codexes/base_codex.rb` | adapter contract |
| `problems/minigit/` | canonical example problem |

## Important conventions

### Problem layout

```text
problems/<problem>/
  problem.json
  SPEC-v1.txt
  SPEC-v2.txt
  test-v1.sh
  test-v2.sh
```

### Output layout

```text
artifacts/<codex>/<model>/<problem>/
  generated/
  logs/
  results/
  figures/
```

### Local configuration

Prefer:

```text
config/codexes.local.yml
```

for secrets and local enablement.

## Suggested reading paths

### New user

`README.md` → `QUICK_START.md`

### Contributor adding a codex

`CLAUDE.md` → `lib/codexes/base_codex.rb` → `config/codexes.yml`

### Contributor adding a problem

`README.md` → `problems/minigit/problem.json` → MiniGit specs/tests

### Contributor adding a language

`benchmark.rb` → `CLAUDE.md`

## Notes

- The repo originated as a Claude/MiniGit benchmark, but the codebase is now organized as a broader benchmark harness.
- The most user-friendly entrypoint is usually `bash scripts/run-all.sh <codex> <problem> ...`.
- Dry runs intentionally write under `artifacts/<codex>/<model>/<problem>/dry-run/` so canonical results stay clean.
