Resume work in this repo on this machine from handoff docs left by `/ajay-handoff` — read `.session-handoff/` (README → the START-HERE RESUME doc), reconcile it against the live repo, and pick up exactly where the other machine left off. Use when you arrive at a machine (home, office, laptop, devserver) to continue work handed off from another. The counterpart to `/ajay-handoff`.

**ULTRATHINK.** Load the full handoff context before acting. The RESUME doc is the source of *intent*; the live repo is the source of *truth* — reconcile both and flag any drift.

## Steps

1. **Detect the VCS + repo root** (`.git`/`.sl`/`.hg`, walking upward). Follow the repo's source-control rules (e.g. a Meta `sl` repo needs `--reason` on every command).

2. **Make sure the handoff is present.** If `.session-handoff/` is missing — or looks older than the remote — the handoff commit may not be local yet. You cannot fetch it yourself (the agent has no SSH keys — see the `feedback_no_ssh_operations` memory): give the user the exact command to run (`git pull` / `sl pull`, per the repo) and wait for them, then re-check. If `.session-handoff/` still doesn't exist after that, fall back to `/ajay-init` (general bootstrap).

3. **Read the handoff, in order:** `.session-handoff/README.md` → the doc its "START HERE" names (the RESUME doc) IN FULL → any recent docs it points to (skip ones carrying a `SUPERSEDED` banner unless you need the history). Also load the relevant auto-memory index for this repo.

4. **Ground-truth + reconcile.** First sanity-check that the START-HERE doc belongs to THIS repo/branch lineage (not a doc for a different stack); if the README's "START HERE" pointer is dangling or points to a superseded doc, use the newest RESUME doc instead and flag it. Then compare the doc's claimed state against the LIVE repo (branch/stack/commits, real hashes/D-numbers, pushed vs local, dirty files, build/CI). Work may have advanced since the doc was written — **flag any drift; trust the repo over the doc on facts.**

5. **Brief the user:** where things stand (one paragraph), the **decisive next action** (from the doc, validated against the repo), the key context/gotchas/decisions to honor, and the open/deferred work. Cite the RESUME doc + the real repo facts.

6. **Confirm the next move** with `AskUserQuestion`: proceed with the doc's next action (recommended, restated concretely), or pick a different focus. Then begin the work.

## Constraints

- **Read-only orientation** — no edits, commits, or `/tmp` scripts during resume (like `/ajay-init`). Start the actual work only after the user confirms in step 6.
- **The live repo overrides the doc** on any factual conflict; surface drift rather than trusting a possibly-stale doc.
- **Don't re-derive what the handoff already settled** — ruled-out approaches, decisions, root causes. Trust them (verify cheaply), don't repeat the investigation.
- **Never push, pull, or run any SSH/remote op yourself** (the agent has no SSH keys — `feedback_no_ssh_operations`); if a pull is needed to fetch the handoff, hand the command to the user and wait.
- If there's no `.session-handoff/`, defer to `/ajay-init` (general bootstrap).
