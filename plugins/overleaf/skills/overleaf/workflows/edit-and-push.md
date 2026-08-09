# Workflow: edit, verify, review, push

The main loop. Assumes `workflows/start-working.md` has been run: you have a clean clone, a
known main document and engine, a passing baseline build, and a local `agent/<topic>` branch.

**The hard rule of this workflow: nothing reaches the remote until the user has seen the
diff and approved it.**

## 1. Pull first

Even if you pulled minutes ago. Coauthors edit continuously.

```bash
git switch <default-branch>     # main or master, as detected
git pull --rebase
git switch agent/<topic>
git rebase <default-branch>
```

If the rebase conflicts, go to `workflows/sync-and-conflicts.md`.

## 2. Edit

Follow `reference/latex-editing.md`. The rules that matter most:

- Preserve the file's line-wrapping convention.
- Change only the lines you mean to change.
- Match the project's existing macros, citation commands, and terminology.
- Update every `\ref` when you touch a `\label`, and every `\cite` when you touch a bib key.

Keep changes scoped to what was asked. If you notice unrelated problems, note them for the
user rather than fixing them in the same pass.

## 3. Build

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

If it fails, go to `workflows/fix-build.md`, then come back.

Also check for the failures that do *not* break the build:

```bash
grep -n 'undefined' main.log        # dangling \ref or \cite
grep -n 'multiply-defined' main.log
```

A `\ref` you broke resolves to `??` and compiles fine. The log is the only place it shows up.

## 4. Self-check the diff

Before showing the user, check that the diff is what you intended:

```bash
git diff --stat
git diff --check
git diff --word-diff
```

If `--stat` shows far more changed lines than the edit warranted, something reflowed or
reformatted. Fix that before proceeding — see `reference/latex-editing.md`.

## 5. Commit

One logical change per commit. Write the message for a coauthor who will see it in
Overleaf's history panel, not for yourself:

```bash
git add <specific files>          # not -A; do not sweep in build artefacts
git commit -m "Tighten the introduction's framing of the contribution"
```

Do not commit `.aux`, `.log`, `.bbl`, `.out`, `.synctex.gz`, or the built PDF.

## 6. Show the user the diff and stop

```bash
git diff <default-branch>...agent/<topic>
```

Present:

- What changed and why, in a sentence or two
- The build result — and say **"builds locally"**, not "builds". Overleaf's TeX Live differs;
  its build after the push is the authoritative one.
- Anything you noticed but did not change
- Any warning worth flagging: new `\usepackage` that Overleaf might not have, a renamed
  label or bib key, a file rename

**Then stop and wait.** Do not merge, do not push. This is the review gate.

If coauthors have track-changes or comments active in the browser, say so now — pushing can
drop that metadata (see `reference/git-bridge.md`).

## 7. After approval: merge and push

Only once the user has approved:

```bash
git switch <default-branch>
git merge --no-ff agent/<topic>
git pull --rebase                 # the remote may have moved during review
git push
```

`--no-ff` keeps the change visible as a unit in the history.

The second `git pull --rebase` is not redundant. Review takes time, and a coauthor may have
pushed while the user was reading.

**If the push is rejected**, the remote moved. Go to `workflows/sync-and-conflicts.md`.
**Never** resolve a rejected push with `--force`. There is no branch on the remote and no
recovery path — a force-push overwrites a coauthor's work irretrievably.

## 8. Confirm

Tell the user the push landed, and that they should check the Overleaf build in the browser
to confirm it compiles there. Then clean up:

```bash
git branch -d agent/<topic>
```
