---
name: overleaf
description: "Use when working with Overleaf LaTeX projects - editing paper prose, fixing compile errors, managing .bib files and citations, or syncing changes with coauthors. Also use when the user mentions Overleaf, git.overleaf.com, a shared paper or manuscript, latexmk, or a .tex project they collaborate on."
license: MIT
compatibility: "Requires git, a TeX distribution providing latexmk, and an Overleaf Git integration token (a premium feature)"
metadata:
  version: "1.0.0"
---

# Overleaf: LaTeX papers over the Git bridge

This skill covers working on Overleaf projects as ordinary local files: cloning them,
editing the LaTeX, compiling and fixing errors locally, managing bibliographies, and
pushing changes back without disrupting coauthors.

## Overview

Overleaf is a collaborative web LaTeX editor. Agents cannot work in its browser editor,
but the **Git bridge** exposes any project as a normal git repository. From there it is
just files: read them, edit them, build them with `latexmk`, and push.

The workflow this skill assumes:

```
clone → baseline build → local branch → edit → build → user reviews diff → merge → push
```

## Critical Concepts

### 1. `overleaf.com/devs` is NOT a usable API

The page at <https://www.overleaf.com/devs> documents exactly one endpoint,
`https://www.overleaf.com/docs`. It is the **"Open in Overleaf" link generator**:
unauthenticated, write-only, and it *creates a brand-new project* from publicly reachable
content.

It cannot list projects, read a project, or edit one. Do not attempt to use it for any task
in this skill. The Git bridge is the only supported read/write integration point.

### 2. The Git bridge is the integration point

```bash
git clone https://git.overleaf.com/<PROJECT_ID>
# Username: git
# Password: <token from Overleaf Account Settings>
```

`<PROJECT_ID>` is the identifier in the project URL: `https://www.overleaf.com/project/<PROJECT_ID>`.

This is a **premium feature** — the project *owner* must have a paid Overleaf plan. See
`reference/git-bridge.md` for token setup, all bridge constraints, and what to do when
premium is unavailable.

### 3. Diff-friendly editing is the top rule

This is the rule most worth getting right. A shared paper is reviewed by humans reading
diffs. An edit that reflows a paragraph while changing one sentence produces a diff no
coauthor can review — which is worse than the problem it fixed.

**Match the file's existing line-wrapping convention. Change only the lines you mean to
change.** Never reformat, rewrap, or run a whitespace formatter across files you were not
asked to reformat. Full rules in `reference/latex-editing.md`.

### 4. A local build is a pre-check, not the truth

`latexmk` locally gives a fast iteration loop and keeps you off Overleaf's build queue. But
the local TeX distribution and Overleaf's pinned TeX Live are different: a package that
resolves locally may not exist on Overleaf, and vice versa.

Treat a clean local build as evidence, not proof. Overleaf's own build after the push is
authoritative — say so to the user rather than claiming the project "compiles".

### 5. Pushing can destroy track-changes and comments

Overleaf warns that pushing over the Git bridge can drop track-changes metadata and
comments, and that renaming or moving a file can lose them outright.

If coauthors have an in-browser review cycle running on the project, **tell the user before
pushing**. Do not mix git pushes with active track-changes review.

### 6. Never push without the user's review

The agent commits to a **local** branch. The user reviews the diff. Only after they approve
does anything reach the remote. Never force-push — the remote is a live document other
people are editing, and there is no branch to recover from.

## Reference Files

Load these based on the task:

| Task Type | Reference File |
|-----------|----------------|
| Token setup, cloning, bridge limits, no-premium fallbacks | `reference/git-bridge.md` |
| Compiling, engine selection, reading logs, decoding errors | `reference/building.md` |
| `.bib` files, citations, biber vs bibtex | `reference/bibliography.md` |
| Editing `.tex` without wrecking diffs, labels, macros, linting | `reference/latex-editing.md` |

## Workflow Files

For common multi-step tasks:

| Workflow | File |
|----------|------|
| Starting work on a project (clone, detect, baseline build) | `workflows/start-working.md` |
| The main edit loop through to pushing | `workflows/edit-and-push.md` |
| Diagnosing and fixing a compile failure | `workflows/fix-build.md` |
| Pulling coauthor changes, rejected pushes, conflicts | `workflows/sync-and-conflicts.md` |

## Common Commands Quick Reference

```bash
# One-time: store the token in the macOS keychain instead of retyping it
git config --global credential.helper osxkeychain

# Clone a project (username "git", password is the token)
git clone https://git.overleaf.com/<PROJECT_ID> my-paper

# Which branch does this remote actually use? (main or legacy master - do not assume)
git branch -r

# Always pull before doing anything
git pull --rebase

# Work on a local branch; the remote has no branches
git switch -c agent/tighten-intro

# Build (pdflatex engine); see reference/building.md for xelatex/lualatex
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex

# Pull the real errors out of the log without reading 2000 lines
grep -n -A5 '^!' main.log
grep -n 'undefined' main.log

# Show the user what changed, for review
git diff main...agent/tighten-intro

# After approval: merge and push (never --force)
git switch main && git merge --no-ff agent/tighten-intro
git pull --rebase && git push

# Clean build artefacts
latexmk -c
```

## Best Practices

1. **Baseline build before editing.** Confirm the project compiles *before* you touch it, so
   any later failure is attributable to your changes.
2. **Pull before you push, always.** Coauthors edit continuously; the remote moves under you.
3. **Never force-push.** There is no branch and no easy recovery on the remote.
4. **One logical change per commit**, with a message a coauthor will understand in the
   Overleaf history panel.
5. **Do not commit build artefacts.** `.aux`, `.log`, `.out`, `.bbl`, `.synctex.gz` and the
   built PDF pollute the project. Check for a `.gitignore` and add one if missing.
6. **Report build status honestly.** If the local build failed, say so with the error. If it
   passed, say it passed *locally* — Overleaf's build is the authoritative one.

## Getting Help

- Git integration docs: <https://docs.overleaf.com/integrations-and-add-ons/git-integration-and-github-synchronization/git-integration>
- Authentication tokens: <https://docs.overleaf.com/integrations-and-add-ons/git-integration-and-github-synchronization/git-integration/git-integration-authentication-tokens>
- `latexmk -help`, `chktex --help`
