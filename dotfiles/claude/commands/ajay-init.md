Scan the current project thoroughly to bootstrap a new Claude Code session — read CLAUDE.md, walk recent commits, surface conventions, in-flight work, and project structure. This is a READ-ONLY investigation: no edits, no commits, no /tmp files. End by asking the user what they want to work on.

**ULTRATHINK.** Engage extended reasoning throughout — this scan sets the foundation for the entire session, so depth and accuracy matter more than speed.

## Arguments

`/ajay-init [<scope-path>]`

- No argument → scope is the current working directory's subtree.
- Argument → resolve relative to cwd (supports `..`, absolute paths, repo-root paths). Validate it exists; error out if not.
- The scope determines what `git log`, file walks, and Explore agents look at. The repo *root* is always detected separately (walk upward for `.git`/`.sl`/`.hg`) and reported alongside.

## Steps

1. **Detect environment** (cheap, always run):
   - Resolve the scope path (per the Arguments rule above) to an absolute path.
   - Walk upward from scope to find VCS root: `.git` → `VCS=git`, `.sl` → `VCS=sl`, `.hg` → `VCS=hg`. If none, report "Not in a git/sl/hg repository" and stop.
   - Check `/opt/facebook` existence → Meta machine yes/no.
   - Branch + upstream:
     - git: `git rev-parse --abbrev-ref HEAD`, `git rev-parse --abbrev-ref --symbolic-full-name @{u}` (silently note "(no upstream)" on failure).
     - sl/hg: current bookmark / `.` rev.
   - Dirty state: `git status --short` / `sl status` / `hg status`.
   - File count in scope: `git ls-files <scope> | wc -l` (or `find <scope> -type f` for sl/hg). Used to decide fan-out.

2. **Decide fan-out**: use parallel Explore agents IF any of the following hold, otherwise single-threaded:
   - File count in scope > 500, OR
   - Meta machine AND scope == repo root, OR
   - Repo root path matches a known monorepo (e.g. `fbsource`, `fbcode`).

3. **Always-on reads** (main context, regardless of fan-out — these are foundational and small):
   - `CLAUDE.md` at the scope, and at the repo root if different. If neither exists, note it.
   - Nearer `README.md` to the scope (prefer scope-local over repo-root).
   - User auto-memory index: `/home/ajaysriv/.claude/projects/-home-ajaysriv--dotfiles/memory/MEMORY.md` — for the dotfiles repo specifically. For other repos, check `~/.claude/projects/` for a project-specific MEMORY.md by mangling the cwd path (replace `/` with `-`, prefix with `-`).
   - The obvious build/test entry point in scope, if there's exactly one: `Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `BUCK`/`TARGETS`/`BUILD` (Buck/Bazel). Read it — don't just list it.

4. **Gather context** — either fan-out OR single-threaded, covering these three buckets:

   **Bucket A — Structure & build surface**
   - Top-level layout of scope (one level deep, then 2-3 levels for subdirs that look like source).
   - Build/test/lint entry points and the commands they expose (e.g. `make help` output if Make-based).
   - CI config: `.github/workflows/`, `.buckconfig`, `.circleci/`, etc.
   - Submodules (`.gitmodules`), language mix, package manifests.

   **Bucket B — Recent activity & in-flight work**
   - Last 20-30 commits in scope:
     - git at repo root: `git log --oneline -30`
     - git scoped: `git log --oneline -30 -- <scope>`
     - sl/hg: equivalent.
   - Full message + diff of the most recent commit touching scope (`git show HEAD -- <scope>` or scope-relative HEAD).
   - Current stack if sl/hg: `sl log -r 'stack()' -T '{node|short} {desc|firstline}\n'`.
   - Dirty files (already collected in step 1) — if the dirty diff is small (<200 lines total), also read it.
   - Last few authors / commit cadence (rough — just enough to know if this is a high-traffic area).

   **Bucket C — Conventions, docs, pending work**
   - Commit message convention (derive from last ~20 commits, don't invent).
   - Lint/format setup: linter config files, pre-commit hooks, `lint` make targets.
   - Pending work surface: any `TODO.md`, `TODO`, `NOTES.md` in scope or repo root. Open PRs/diffs if tooling is available (silently skip on failure):
     - git: `gh pr list --author @me --state open` (only if `gh` is installed and authenticated)
     - hg/sl on Meta: `jf list` or `arc list --status open` (only if installed; silent on failure)
   - Quick scan for `TODO`/`FIXME`/`XXX` comments in files touched in the last 5 commits.
   - Anything in CLAUDE.md flagged as a "don't" or constraint (identity rules, file-modification policies, etc.).

   If fanning out: launch up to 3 Explore agents (one per bucket) IN PARALLEL in a single message. Each agent's prompt MUST include the scope path, repo root, VCS type, and a request for a <200-word structured report. If single-threaded: Claude reads the same material directly using `Bash`/`Read`/`Grep`.

5. **Compile the report** to chat, with these sections — OMIT empty sections (no "N/A" stubs):

   ```
   ## Identity
   - Repo: <absolute repo root>  (<basename>)
   - Scope: <absolute scope path>  (<relative-to-repo or "= repo root">)
   - VCS: <git|sl|hg> on branch <branch> -> <upstream or "(no upstream)">
   - Dirty: <N files> | clean
   - Env: <Meta | non-Meta>, <fan-out used? yes/no — why>

   ## Recent activity
   - Last commit (scope): <sha> <subject>
     <2-4 line summary of what changed and why, derived from message + diff>
   - Recent: <5 most recent one-liners>
   - In-flight: <dirty file list with short status flags>

   ## Structure
   - <one-paragraph mental model: what this project does, how it's organized>
   - Entry points / commands: <make targets / npm scripts / buck targets the user is likely to invoke>
   - CI: <one line>

   ## Conventions
   - Commit messages: <derived format, e.g. "<scope>: <subject>", from recent log>
   - Lint/format: <tools + how to run>
   - <Any "don't" rules from CLAUDE.md, e.g. identity split, file-link policy>

   ## Pending work
   - TODO.md: <bulleted items>
   - Open PRs/diffs: <list with titles>
   - Loose ends: <TODO/FIXME hits in recently-touched files>

   ## Memory hits
   - [[memory-slug]] — one-line relevance hook (cite the slug; don't paraphrase the body unless asked).

   ## Notes
   - <anything surprising: stale submodules, conflicting CLAUDE.md guidance, uncommitted WIP older than today, etc.>
   ```

6. **End with `AskUserQuestion`** — 1-3 targeted questions, tailored to what the scan surfaced. The first question is ALWAYS "What do you want to work on?", and its first option ("Recommended") should be derived from the scan (e.g. "Continue the WIP in `foo.py`" if there are dirty files; "Review PR #123" if a PR was found; "Pick up TODO item: <X>" if TODO.md has items). Other useful conditional questions:
   - If dirty files exist: confirm whether to continue that work or set it aside.
   - If multiple open PRs/diffs: which one is in focus.
   - If CLAUDE.md is missing or thin: offer to draft one (don't do it — just ask).

## Constraints

- READ-ONLY. No `git add`, no commits, no edits, no `/tmp` script generation. The only state change in the user's environment is the `AskUserQuestion` prompt at the end.
- Use parallel Explore agents ONLY when the fan-out trigger fires (step 2). For small repos, stay single-threaded so the user can see exactly what was read.
- When fanning out, the three agents MUST be launched in a single message with three parallel tool calls — not sequentially.
- Each Explore agent's prompt must be self-contained: explicitly include scope path, repo root, VCS type, and a word budget (<200 words). Do not delegate "figure out what to do" — assign a specific bucket.
- Do NOT read the dirty-state diff if it exceeds 200 lines total. Summarize file list only; offer to read specific files on request.
- Do NOT walk the file tree more than 3 levels deep in step 4's structure pass. Top-level shape is enough; the user will direct deeper reads.
- Network calls (`gh`, `arc`, `jf`) are best-effort. Silent on failure — do NOT prompt for auth.
- Memory citations MUST use the `[[slug]]` form from the memory file's `name:` field. Do not invent slugs or paraphrase memory bodies unless the user asks.
- OMIT empty report sections rather than emitting "(none)". A scannable report beats a complete one.
- The report's "Recent activity" summary of the last commit must be grounded in the actual diff — do NOT just restate the commit subject.
- If CLAUDE.md and observed code conflict (e.g. CLAUDE.md describes a pipeline step that no longer exists), call it out under "Notes" — this is more valuable than the rest of the report combined.
- The final `AskUserQuestion` MUST have a Recommended first option tied to something concrete the scan surfaced. Generic options ("What are you working on?" with no defaults) are not acceptable — they waste the scan.
- Do not save anything to auto-memory during the init — even if you learn something memorable. The point of init is to load context, not write it. Save during the working session if appropriate.
