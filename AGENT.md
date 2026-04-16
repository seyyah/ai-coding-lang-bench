# Agent & Contributor Protocol

> Rules of engagement for human and AI (codex) contributors.
> Read [program.md](./program.md) first for the high-level iteration loop.

---

## Golden rule

**Every session must leave the project better documented than it found it.**

After each iteration (experiment run, code change, bug fix):

1. **Append** a dated entry to [walkthrough.md](./walkthrough.md)
2. **Update** [plan.md](./plan.md) — mark completed items, add new next steps

This is **mandatory**, not optional. Skipping documentation means the next contributor (human or AI) starts blind.

---

## Session protocol

### Start of session

```
1. Read program.md         → understand the current research question
2. Read plan.md            → see active experiments + backlog
3. Read walkthrough.md     → see recent results + decisions
4. Pick a task from plan.md and mark it [/] (in progress)
```

### During session

```
5. Do the work (run benchmarks, add adapters, fix bugs, add problems)
6. Run tests: `bin/which-language run <codex> <problem> --lang <lang> --trials 1`
7. Observe metrics: time, cost, LOC, pass rate
```

### End of session

```
8. Append walkthrough.md entry (template below)
9. Update plan.md: mark completed [x], add new items [ ], note blockers
10. Commit with descriptive message
```

---

## Walkthrough entry template

```markdown
## YYYY-MM-DD — [Brief title]

**Contributor**: [human / codex-name]
**What was done**: [1–3 sentences]
**Codex/Problem/Language**: [e.g., gemini / minigit / python]
**Key metrics**: [time, cost, LOC, pass rate — if applicable]
**Observations**: [what worked, what didn't]
**Decisions made**: [any design choices or trade-offs]
**Next**: [immediate next step, links to plan.md items]
```

---

## Code conventions

### Ruby (benchmark runner + adapters)

- `# frozen_string_literal: true` at the top of every `.rb` file
- Codex adapters extend `BaseCodex` (`lib/codexes/base_codex.rb`)
- Required interface: `run_generation(prompt, dir:, log_path:)`, `version`
- Optional interface: `warmup(dir)`, `parse_metrics(raw_output)`
- Use `config/codexes.local.yml` for secrets — never commit API keys

### Python (plot.py)

- Python 3.10+, stdlib + matplotlib

### Problem layout

```
problems/<problem>/
  problem.json       # metadata + prompt templates
  SPEC-v1.txt        # v1 specification
  SPEC-v2.txt        # v2 specification (extends v1)
  test-v1.sh         # v1 test suite
  test-v2.sh         # v2 test suite
```

---

## New codex adapter checklist

When adding support for a new AI coding system:

- [ ] Create `lib/codexes/<name>_codex.rb` extending `BaseCodex`
- [ ] Implement `run_generation(prompt, dir:, log_path:)`
- [ ] Implement `version`
- [ ] Implement `parse_metrics(raw_output)` if the API returns token/cost data
- [ ] Add configuration block to `config/codexes.yml`
- [ ] Add API key handling (env var expansion in config)
- [ ] Test dry-run: `bin/which-language benchmark <name> minigit --lang python --trials 1 --dry-run`
- [ ] Run 1 real trial: `bin/which-language run <name> minigit --lang python --trials 1`
- [ ] Run 3+ trials for variance data
- [ ] Document pricing in `CLAUDE.md`
- [ ] Document the new adapter in relevant `.md` files (e.g., `program.md`, `README.md`) to update project context
- [ ] Update `plan.md` status
- [ ] Add walkthrough.md entry

## New problem checklist

- [ ] Ensure the problem name starts with the `mini` prefix (e.g., `minigit`, `minipomodoro`) and is all lowercase with no hyphens.
- [ ] Create `problems/<problem>/problem.json` with all required keys
- [ ] Write `SPEC-v1.txt` and `SPEC-v2.txt`
- [ ] Write `test-v1.sh` and `test-v2.sh` (deterministic, self-contained)
- [ ] Test with at least 1 codex × 1 language × 1 trial
- [ ] Document the new problem in relevant `.md` files (e.g., `program.md`, `CLAUDE.md`, `README.md`) to update project context
- [ ] Add walkthrough.md entry
- [ ] Update `plan.md` status

---

## PR guidelines

- Title format: `[component] Brief description` (e.g., `[codex] Add DeepSeek adapter`)
- Include benchmark results if adding/modifying adapters
- Keep PRs focused — one adapter or one problem per PR
- Run `bin/which-language benchmark <name> minigit --dry-run` before submitting
- **First-time contributors:** GitHub Actions requires manual approval for workflows from first-time contributors. If you are a maintainer or AI agent evaluating a PR:
  1. Inspect the PR content first.
  2. If it violates conventions (e.g., missing `mini` prefix for problems), comment and **close** the PR (`gh pr close <id> -c "..."`).
  3. If it looks legitimate, approve the workflow run (`gh run approve <run-id>`).

---

## For AI agents specifically

If you are an AI agent (Claude, Gemini, Codex, etc.) working in this repo:

1. **Do not modify `prepare.py`-equivalent files** — `report.rb` and `plot.py` are reporting tools, modify only if explicitly asked
2. **Scope your changes** — touch only the files relevant to your task
3. **Be explicit about failures** — if a benchmark run fails, document the failure mode in walkthrough.md
4. **Prefer small iterations** — one codex adapter or one problem per session
5. **Always update documentation** — this is the most important rule
