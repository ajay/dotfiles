Generate or update cross-machine handoff docs in `.session-handoff/` so work in this repo can be resumed in a fresh Claude Code session on another machine (home, office, laptop, devserver). Captures the ground-truthed current state, the single most important next action, the session narrative, key context/gotchas, and open work. This command writes docs ONLY — it never commits or pushes; run `/ajay-ship` afterward to commit them (it knows where handoff docs belong in a commit/stack), and `/ajay-resume` on the destination machine to pick them up.

**Be thorough and accurate.** A fresh session on another machine will have ONLY these docs (plus synced memories) — no transcript, no session context. Ground-truth every fact from the repo; do not write from memory.

## Arguments

`/ajay-handoff [<note>]`

- No argument → infer the handoff from the current session + repo state.
- Argument → a free-text steer: what to emphasize, the intended next focus, or which work is in flight. Weave it into the RESUME doc.

## Steps

1. **Detect the VCS + repo root** by walking upward: `.git` → git, `.sl` → sl, `.hg` → hg. The handoff dir is `<repo-root>/.session-handoff/`. Follow the repo's source-control rules (e.g. a Meta `sl`/`jf` repo: `--reason` on every `sl`, never push with `jf`).

2. **Assess existing handoff docs.** If `.session-handoff/` exists, read its `README.md` + the current START-HERE doc to learn the structure, naming/numbering convention, and what is now stale. If it doesn't exist, you will create it (a `README.md` + the first RESUME doc) following the convention in step 6.

3. **Ground-truth the current state — from the repo, not memory.** Capture real values:
   - VCS: branch/bookmark, the commit/diff stack (`git log --oneline` + `git status`; or `sl ssl`), exact short hashes + diff numbers (e.g. D-numbers) + links to the in-flight diff(s)/PR(s), what is pushed vs local-only, the base/remote it sits on, and dirty/untracked files.
   - Work in flight: the precise files/diffs being changed and why.
   - Health: the latest build/test/CI/lint status you can verify — run a quick check or cite the last verified result; never assert "green" without basis.

4. **Capture the session narrative** — the part only this session knows: what was done and why, decisions made, approaches ruled out (so the next session won't repeat them), and anything surprising.

5. **Ask the user if the resume intent is ambiguous** (only if genuinely unclear): the single next action, what's in flight, any pending decisions, and anything that must NOT be redone. Skip the questions if the session already makes these obvious.

6. **Write / update the docs** in `.session-handoff/`:
   - **START-HERE RESUME doc** — a NEW dated, self-contained file (e.g. `NN-RESUME-<YYYY-MM-DD>-<slug>.md`, continuing any existing numbering). Lead with a one-line TL;DR + the **single next action**, then: current state (ground-truthed, with real hashes/D-numbers/branch + links to the in-flight diff(s)/PR(s)), what was done this session, key context/gotchas/decisions, build/run/test/flash commands **plus any machine-specific prerequisites that may differ across machines** (toolchain versions, `sl`/`--reason` setup, required hardware/device presence — e.g. an attached dev board), constraints + tooling rules, and open/deferred work. Make the doc **self-locating**: state the repo root and an explicit line such as `To continue: run /ajay-resume in <repo-root>` so a cold reader on another machine knows exactly how to pick up. Next-action-first and scannable.
   - **`README.md` index** — repoint "START HERE" at the new RESUME doc; keep a short reverse-chronological pointer to recent docs + an index of the stable/reference docs. If creating it fresh, establish that layout.
   - **Append-only** — never rewrite or delete prior docs; add a one-line `> ⚠️ SUPERSEDED (<date>) — see <doc>` banner to any the new doc overtakes.

7. **Stop — do NOT commit or push.** The docs are working-copy changes. Tell the user to run **`/ajay-ship`** to commit them (it handles placement: folded into the current WIP commit, or an isolated commit on top of a diff stack). On the destination machine they run **`/ajay-resume`**.

## Constraints

- **Docs only.** Never commit, never push, never run SSH/remote-write ops (committing is `/ajay-ship`'s job; pushing is always the user's — see the `feedback_no_ssh_operations` memory).
- **Ground-truth every fact** (hashes, D-numbers, branch, CI) from the live repo. Memories and prior docs reflect a past moment and may be stale — verify, then write.
- **The RESUME doc must be self-contained** — assume the reader has zero prior context.
- **Match the repo's existing `.session-handoff/` conventions** if present; otherwise create `README.md` + the first numbered RESUME doc.
- **Append, don't overwrite** history; supersede with banners. Keep it lean — the README points to the current + recent docs, and the RESUME doc captures what's needed to resume (link out for the rest) rather than dumping unbounded narrative.
- **Lead with the next action** — a resumer should know what to do within the first few lines.
- Do not write auto-memory notes; the handoff travels via the committed docs.
