# Workflow: syncing with coauthors and resolving conflicts

Overleaf projects move constantly — every keystroke a coauthor types in the browser
eventually becomes a commit on the bridge. Conflicts are normal, not exceptional.

**The rule that governs everything here: never `git push --force`.** The remote has no
branches and no recovery path. A force-push silently overwrites work a coauthor may have
spent hours on, and there is no way to get it back from the Overleaf side.

## Routine: pulling coauthor changes

```bash
git switch <default-branch>     # main or master, as detected with `git branch -r`
git pull --rebase
```

`--rebase` keeps history linear, which matters because Overleaf's history panel is what your
coauthors read. Merge commits from repeated pulls make it unreadable.

To see what changed:

```bash
git log --oneline -20
git diff HEAD@{1} HEAD --stat
```

If you are working on a local `agent/<topic>` branch, replay it onto the updated base:

```bash
git switch agent/<topic>
git rebase <default-branch>
```

## When a push is rejected

```
! [rejected]  main -> main (fetch first)
```

This means a coauthor pushed while you were working. It is expected. The fix is always the
same:

```bash
git pull --rebase
# resolve conflicts if any (below)
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex   # rebuild after rebasing
git push
```

Rebuild after the rebase, before pushing. Your change and theirs each compiled alone; the
combination may not.

If the push is rejected again, someone pushed during those few seconds. Repeat. Do not
escalate to `--force`.

### Other rejection causes

Not every rejection is a race:

- **Authentication failure** → the token expired or was revoked. Create a new one; see
  `reference/git-bridge.md`.
- **File or size limit exceeded** → the project hit its plan limit. Usually a large figure
  or an accidentally committed PDF. Check `git diff --stat` and
  `du -sh` the files you added.
- **Unsupported content** → symlinks or LFS pointers. Remove them.

## Resolving conflicts in `.tex`

```bash
git status                      # which files conflict
grep -n '<<<<<<<\|=======\|>>>>>>>' *.tex
```

### The guiding principle

Both sides are a human coauthor's intent. Your job is to **preserve both**, not to pick a
winner.

- **Different sentences in the same paragraph** → keep both, in a sensible order. This is the
  common case and it is usually mechanical.
- **Both edited the same sentence** → this is a genuine editorial decision. **Do not choose
  silently.** Show the user both versions and ask.
- **One side deleted, the other edited** → always ask. A deletion is a deliberate act and
  quietly resurrecting the text overrides someone's decision.
- **Conflicts in the preamble** → keep both `\usepackage` lines unless they actually clash.
  Duplicate package loads are usually harmless; a missing one breaks the build.
- **Conflicts in a `.bib`** → keep both entries, then check for duplicate keys afterwards
  (see `reference/bibliography.md`).

### Mechanics

Edit the file to remove all conflict markers, then:

```bash
git add <file>
git rebase --continue
```

Verify nothing survived:

```bash
grep -rn '<<<<<<<\|>>>>>>>' --include='*.tex' --include='*.bib' .
```

A conflict marker left in a `.tex` file will usually still compile, producing garbage text in
the PDF. Always grep.

Then rebuild before pushing.

### Backing out

If a rebase goes wrong, it is fully recoverable:

```bash
git rebase --abort
```

This returns you to the pre-rebase state with nothing lost. Use it freely — an aborted rebase
costs nothing, a botched conflict resolution costs a coauthor's work.

If you have already completed a bad rebase but **not pushed**:

```bash
git reflog                  # find the commit before the rebase
git reset --hard <sha>
```

Once pushed, do not try to undo it with a force-push. Fix forward with a normal commit, and
tell the user what happened.

## When Overleaf and git disagree

Occasionally a project's git state looks stale compared to the browser. The bridge commits
browser edits lazily. If the user says they made a change that you cannot see:

1. `git pull --rebase` again — it may have just landed.
2. Ask them to make any small edit in the browser, which flushes pending changes.
3. As a last resort, re-clone into a fresh directory and compare.

Do not try to "fix" a divergence by force-pushing your local state over it.
