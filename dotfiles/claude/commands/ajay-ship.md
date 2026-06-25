Generate a `/tmp` shell script that will stage, commit, and (for git) push the user's current set of changes in the working directory. Do NOT stage or commit anything yourself — the only side effect of this command is writing the script.

## Steps

1. **Detect the VCS** in the current working directory by walking upward looking for one of:
   - `.git` (file or directory) → `VCS=git`
   - `.sl` directory → `VCS=sl`
   - `.hg` directory → `VCS=hg`

   If none is found, tell the user "Not in a git/sl/hg repository" and stop.

2. **Inspect the changes** read-only:
   - git: `git status --short`, `git diff HEAD`, `git log --oneline -20`, and `git rev-parse --abbrev-ref HEAD` for the branch name. If branch tracks a remote, also note the remote name (`git rev-parse --abbrev-ref --symbolic-full-name @{u}`).
   - sl: `sl status`, `sl diff`, `sl log -l 20 --template '{node|short} {desc|firstline}\n'`.
   - hg: `hg status`, `hg diff`, `hg log -l 20 --template '{node|short} {desc|firstline}\n'`.

   If the working tree is clean, tell the user "Nothing to ship — working tree is clean" and stop without writing a script.

3. **Identify the intended files for this commit.** Default to every modified/added/deleted/untracked path. If the diff contains files that look unrelated to the dominant theme of the change (e.g. a stray edit in an unrelated subtree, or untracked scratch files), ask the user via `AskUserQuestion` which group(s) to include before continuing. Any file that's dirty in the working tree but NOT going into this commit must be listed under "Files NOT staged" in the script header so the user can spot drift.

   **Handoff docs (`.session-handoff/`, written by `/ajay-handoff`):** place these deliberately. If there are other changes too, include `.session-handoff/` in the SAME commit as the work (one commit carries the change plus its handoff snapshot). If the handoff docs are the ONLY change and the repo has a diff/commit stack, put them in their OWN isolated commit on TOP of the stack — do not fold them into a mid-stack diff (the isolated commit's commit step targets only `.session-handoff/`; make sure the working copy is at the stack top so it lands on top rather than inserted mid-stack). When it's ambiguous which applies, ask the user via `AskUserQuestion`. Push: for git, the handoff docs follow the normal push confirmation (never push without it); for sl/hg there is no push step (review goes through `arc diff` separately).

4. **Draft a commit message** that matches the repo's recent style. Read the last ~20 commits and copy the convention you see — for example, the dotfiles repo uses `<scope>: <short subject>` with an optional bulleted body explaining the *why* (not the *what*). Don't invent a style. The subject should be short (≤72 chars); the body is optional and used only when the change has non-obvious motivation worth recording. For large repos (such as a monorepo), inspect current changes in the relevant project or current directory; it will not be useful to look at overall last ~20 commits. Always use lowercase for the first word after the scope prefix — e.g. `[nrf54h20] add ...` not `[nrf54h20] Add ...`, `dotfiles: fish: add ...` not `dotfiles: fish: Add ...`.

   For repos that use a Test Plan field (e.g. fbsource/Phabricator), populate it with a minimal fenced code block listing the relevant commands (existing and new) that a reviewer can copy-paste to reproduce. No prose — just the commands. After the commands block, add a blank output block for the user to paste results into, with a tiny note like `<output of: `command`>`. If you can predict what the output will be, prepopulate it as expected output (clearly marked as "expected", not actual). If the change modifies behavior of an existing command, use before/after sections. Example:

   ```
   echo 'hello_world'
   ```

   before:
   ```
   <output of: `echo 'hello_world'` before>
   ```

   after:
   ```
   <output of: `echo 'hello_world'` after>
   ```

   For new commands with no "before", just use a single output block:

   ```
   make test TARGET=myapp
   ```

   ```
   <output of: `make test TARGET=myapp`>
   ```

5. **Write the script** to `/tmp/ship-<repo-basename>-<theme>-<YYYYMMDD-HHMMSS>.sh` using the template below, then `chmod +x` it.

6. **Print to the user**: the chosen commit message, the file list, any excluded dirty files, and the absolute path of the generated script. Do not run the script yourself.

## Script template — git

```bash
#!/usr/bin/env bash
#
# Ship: <one-line summary of the commit>
# Generated <ISO 8601 timestamp> for <absolute repo path>
# Branch: <branch>  ->  <remote/branch or "(no upstream)">
#
# Files staged:
#   <path1>
#   <path2>
#
# Files NOT staged (dirty in working tree at generation time):
#   <other_path>          # <reason if known, else omit comment>
#
set -euo pipefail

YES=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes) YES=1 ;;
        -h|--help)
            sed -n '2,/^[^#]/{ /^#/s/^# \?//p }' "$0"; exit 0 ;;
        *) echo "Unknown flag: $arg" >&2; exit 2 ;;
    esac
done

# Force pagers off — generated scripts are linear, never paged.
export GIT_PAGER=cat
export PAGER=cat

confirm() {
    (( YES )) && return 0
    if [[ ! -t 0 ]]; then
        echo "Cannot prompt: stdin is not a tty. Re-run interactively or pass -y/--yes." >&2
        return 1
    fi
    local key
    while :; do
        printf '%s [y/n] ' "$1"
        IFS= read -rsn1 key
        case "$key" in
            y|Y) echo "y"; return 0 ;;
            n|N) echo "n"; return 1 ;;
            *)   echo
                 echo "  (press 'y' to proceed or 'n' to abort)"
                 ;;
        esac
    done
}

preview() {
    printf '\n──── %s ────\n' "$1"
    shift
    if (( $# > 0 )); then
        printf '  $ %s\n' "$1"
        shift
        for line in "$@"; do
            printf '    %s\n' "$line"
        done
    fi
    printf '\n'
}

cd <ABSOLUTE_REPO_PATH>

echo "──── Current state ────"
git status --short
echo

preview "Stage" \
    "git add \\" \
    "<path1> \\" \
    "<path2>"
confirm "Stage <N> file(s)?" || { echo "aborted"; exit 1; }
git add <path1> <path2>

preview "Commit" \
    "git commit -m \"\$(cat <<'EOF'" \
    "<scope>: <subject>" \
    "" \
    "<optional body line 1>" \
    "<optional body line 2>" \
    "EOF" \
    ")\""
confirm "Create commit?" || { echo "aborted"; exit 1; }
git commit -m "$(cat <<'EOF'
<scope>: <subject>

<optional body>
EOF
)"

preview "Push" "git push"
echo "Upstream:        <remote>/<branch>"
echo "Commits to push:"
git log --oneline '@{u}..HEAD' || true
echo
confirm "Push to <remote>/<branch>?" || { echo "commit kept locally; not pushed"; exit 0; }
git push
```

For a single-file stage, `preview "Stage" "git add <path>"` (one arg) is fine — the helper handles both forms.

If the branch has no upstream, the push block becomes:

```bash
preview "Push" "git push -u origin <branch>"
echo "Branch <branch> has no upstream. Setting upstream to origin/<branch>."
echo "Commits to push:"
git log --oneline origin/<branch>..HEAD 2>/dev/null \
    || git log --oneline -10        # fallback when remote ref doesn't exist yet
echo
confirm "Push to origin/<branch> (and set upstream)?" \
    || { echo "commit kept locally; not pushed"; exit 0; }
git push -u origin <branch>
```

## Script template — sl / hg

Same scaffolding (`#!/usr/bin/env bash`, header comments, flag parser, `confirm()`, `preview()`, `cd`), but the body becomes:

```bash
echo "──── Current state ────"
sl status
echo

# Only emit this block when there are untracked files to add:
preview "Add new files" \
    "sl add \\" \
    "<new_path1> \\" \
    "<new_path2>"
confirm "Add <K> new file(s)?" || { echo "aborted"; exit 1; }
sl add <new_path1> <new_path2>

preview "Commit" \
    "sl commit -m \"\$(cat <<'EOF'" \
    "<scope>: <subject>" \
    "" \
    "<optional body>" \
    "EOF" \
    ")\" \\" \
    "<path1> \\" \
    "<path2>"
confirm "Create commit?" || { echo "aborted"; exit 1; }
sl commit -m "$(cat <<'EOF'
<scope>: <subject>

<optional body>
EOF
)" <path1> <path2>

# No push step — fbsource workflow uses arc diff separately.
```

Use `hg` in place of `sl` when the detected VCS is Mercurial.

## Constraints

- Do NOT run `git add`, `git commit`, `git push`, `sl commit`, etc. yourself. The slash command only writes a `/tmp` script.
- Do NOT modify anything in the working tree.
- The script header MUST include: the commit summary, generation timestamp, repo path, the staged file list, and the excluded-but-dirty file list (if any).
- Quote heredoc delimiters as `<<'EOF'` so the embedded commit message is treated literally (no shell expansion of `$`, backticks, etc.).
- If the working tree contains logically distinct changes, ask the user whether to bundle them into one commit or generate one script per group.
- Every `confirm` MUST be immediately preceded by a `preview` block that lists the exact command(s) about to run.
- The commit step's preview MUST render the literal bash invocation (heredoc form) including every line of the message body. No `...` truncation.
- The push step's preview MUST show the upstream target and the local commits that would land on the remote (`git log @{u}..HEAD --oneline`).
- The `preview` helper definition (the multi-line-aware `printf` shim shown in the template) MUST be added near the top of the script alongside `confirm`.
- Immediately after `cd <repo>`, the script MUST print `git status --short` (or `sl status` / `hg status`) under a `──── Current state ────` header, with no `confirm` gate.
- Preview command strings MUST NOT use `...` to abbreviate file lists, message bodies, or any other content. Render the full command. For multi-line invocations, pass each line as a separate arg to `preview` so the helper indents continuation lines.
- The script MUST `export GIT_PAGER=cat` and `export PAGER=cat` near the top (after the flag parser, before any VCS command runs) so pager-by-default git/sl/hg subcommands stream their output inline instead of trapping the user in less.
