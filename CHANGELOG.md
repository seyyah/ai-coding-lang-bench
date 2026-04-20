# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-14

### Added
- **CI/CD Workflows**: GitHub Actions for automated contribution validation
  - `validate-problem.yml` — validates new problem structure and schema
  - `validate-codex.yml` — validates new codex adapter contributions
  - `validate-artifact.yml` — validates benchmark artifact submissions
  - `auto-contributor.yml` — auto-updates README Hall of Fame on merge
  - `gate-other-changes.yml` — flags core file changes for human review
- **7 benchmark problems**: minigit, minigrades, miniinventory, minilibrary, miniplaylist, miniscoreboard, minitimer
- **New problem**: `miniquiz` by @knewral (#49)
- **5 codex adapters**: Claude, Gemini, OpenAI, Groq, Aider
- **Unified CLI**: `bin/which-language` for benchmark orchestration
- **Multi-language support**: 15 languages including Python, Rust, Go, Ruby, TypeScript
- **Reporting pipeline**: benchmark → report → plot (figures)

### Contributors
- @mame — 🚀 Visionary
- @berkevnl — 💻 Core Architect
- @Ahmetngz — 💻 Core Architect
- @knewral — 🎯 Problem Architect (miniquiz, #49)
- @Elvannegis — 🎯 Problem Architect (miniinventory, #52)

[Unreleased]: https://github.com/seyyah/which-language/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/seyyah/which-language/releases/tag/v1.0.0
