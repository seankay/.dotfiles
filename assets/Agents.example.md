# [AGENTS.md](http://agents.md/) — (XXXX) Repository Guide

Scope: This file governs the entire repository.

Read this first if you’re contributing, reviewing, or acting as an automated coding agent.

## Reading Order

1. docs/00-central-design.md (architecture/design)
2. GitHub Issues (tasks/backlog): [https://github.com/XXXX/XXXXX/issues](https://github.com/XXXX/XXXXX/issues)
3. docs/ROADMAP.md (priorities and status)

## Intent & Principles

- SOLID, KISS, YAGNI

- (XXXX)

- Security by default: encryption at rest & in transit, least privilege

- Testability: modular boundaries, deterministic components, fast tests first

- Clarity: idiomatic C#/.NET naming, minimal non‑obvious comments only

## Expectations for Agents/Contributors

- Skim docs/00-central-design.md for architecture context before coding.

- Drive all planning via GitHub Issues (no in‑repo trackers).

- Keep changes small and focused; propose ADRs for deviations.

- Add/Update tests for essential behaviors you change or add.

- For each new feature, add both unit and integration tests when feasible. Integration tests are as important as unit tests and should exercise end-to-end behavior without relying on brittle environment assumptions.

- Structured logging only; no Console.WriteLine in production code.

## Session Handoff Protocol (GitHub Issues)

- Start: pick a ready P0 issue, self‑assign, post a “Session Start” plan.

- During: post concise updates at milestones; adjust labels as needed.

- End: post “What landed” + “Next steps” and update labels/boards.

- If behavior/architecture changed, update docs/00-central-design.md in the same commit.

### Task Tooling (GitHub)

- Windows PowerShell (preferred on Windows):

- Pick a ready P0 task and mark it in‑progress: `pwsh -f tools/agents/session-start.ps1 [-AssignSelf]`

- Update status/comment: `pwsh -f tools/agents/session-update.ps1 -Issue <#> -Status <ready|in-progress|blocked|done> [-WhatFile md] [-NextFile md] [-Close] [-AssignSelf]`

- Quickly show the top ready P0: `pwsh -f tools/agents/pick-task.ps1`

- Bash (legacy WSL2 tooling still available):

- `bash tools/agents/session-start.sh`

- `bash tools/agents/session-update.sh --issue <#> --status <...>`

- `bash tools/agents/pick-task.sh`

- Note: If CRLF line-endings cause issues, prefer the PowerShell versions on Windows.

All tools read `GITHUB_TOKEN` (or `tools/agents/.env`, or `$HOME/.config/XXXX/agent.env`, or a local token file). On Windows, the scripts also probe `F:\WIN_TOKEN.txt`.

## Code Organization

Solution layout:

(XXXX - HERE IS MY SOLUTION / CODE LAYOUT)

- tests — Unit/integration tests mirroring src/

- tools — Dev tooling, packaging, setup

### File Layout Rules (Vertical Slice)

- One type per file: each class/record/struct/enum in its own file named after the type.

- One interface per file: the filename matches the interface name.

- Interfaces placement:

- Cross‑platform: src/XXXXX/abstractions (and server equivalents).

- Platform‑specific: under an Abstractions (or Interfaces) folder inside the feature slice, e.g., windows/service/XXXXX/XXXXXX/XXXXXX.cs.

- Vertical slices first: organize code by feature (API/, XXXX/, Logging/, etc.).

- Within each slice, use Abstractions/, Implementation/, Infrastructure/ subfolders where helpful.

- Avoid mixing unrelated features in the same folder.

## Workflow & Quality

- Feature toggles/configuration are mandatory for runtime‑conditional behavior.

- Public APIs (interfaces, DTOs) must be stable and documented in code.

- Follow .NET conventions; keep functions single‑purpose.

- Dependency injection at boundaries;

- Long‑running tooling must run with timeouts/non‑interactive flags.

- Data access (server): API → Application services → Infrastructure (DbContext) → PostgreSQL.

- Error handling: return typed results; log structured context; never swallow exceptions.

- Source control: push cohesive changes to master after green build/tests.

- Keep the repo clean: do not commit generated artifacts or logs. .gitignore excludes bin/, obj/, artifacts/, logs/, win-mirror/.

### Roadmap & Priorities

- (YOUR_ROADMAP_HERE)

- Keep GitHub issues atomic and linked to roadmap items; label by P0/P1/P2.

## Coding Standards

- Async‑first; propagate CancellationToken; Async suffix for async methods.

- Prefer await using for IAsyncDisposable resources.

- EF Core: entities/value objects in Domain, mappings in Infrastructure, migrations per feature.

- Modern C#: nullable enabled; warnings as errors; primary constructors where helpful.

- One type per file; one interface per file; interfaces live in Abstractions/ per slice.

- No dead code: remove unused fields/methods/usings and scaffolding when no longer used.

- Naming: interfaces IName, types PascalCase, methods PascalCase, private fields \_camelCase, locals/params camelCase.

- Logging: structured with message templates and relevant context; no console logging in prod.

## Documentation Rules

- Central doc is the source of truth. Keep it current when architecture shifts.

- All task/progress tracking in GitHub Issues.

## Ambiguity

- Prefer the simplest design that satisfies current requirements.

- If multiple options exist, document a brief rationale and link docs/00-central-design.md.

- User instructions take precedence over the central doc.

```
# How to write good prompts
## Role
Start with a role. The role should be the most expert position for the role in question. e.g. you are an expert marine biologist, you are a world renowned author, you are a best selling musical artist, etc.
## Goal
Write a goal with as much specificity as possible. e.g. write a persuasive email tailored to a skeptical executive using behavioral psychology techniques, draft a pitch deck outline that highlights emotional resonance, not just data points, summarize these 5 research articles into an insight report. Additional example:
```

Please provide:

- Each advisor's specific recommendation (in their voice and expertise)
- Quick SWOT Analysis
- Top risks and mitigation strategies
- Key stakeholder impacts
- Concrete next steps
- Keep responses practical and actionable
- Focus on real-world implementation

```
# Context
Provide as much context as possible: e.g. provide current situation, main objectives, available resources, and time constraints.
## Examples (Shot Prompting)
Give an example of what "good" looks like. e.g. if you're looking to generate a new email template to increase conversion, provide old email templates that worked really well. If there are no past examples, you could use AI to help you write an initial draft.
# Review & Revise
Review output. If there are revisions that are needed: review examples provided. You can also use AI to improve and revise the prompt. Hallucination may also cause inconsistency in output where the first 5 results are great but the few subsequent results aren't as good.
## Cognitive Loop Prompting (AI critique AI)
1. Propose a decision pathway.
2. Critique it from the perspective of a risk-averse investor.
3. Revise based on critique.
4. Output pros/cons or original vs revised version.

# Prompt Chaining
Consider chaining prompts in sequence instead of lumping the question all in one.
# Custom Bots
Turn most-used prompts into a custom chatbot or project (custom GPTs).
```
