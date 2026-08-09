# Workflow: starting work on an Overleaf project

Run this once at the start of a session, before any editing. Its purpose is to establish a
known-good baseline so that any later build failure is attributable to your changes.

## 1. Get the project locally

**If not yet cloned**, you need the project ID from the user (the identifier in
`https://www.overleaf.com/project/<PROJECT_ID>`):

```bash
git clone https://git.overleaf.com/<PROJECT_ID> <readable-name>
cd <readable-name>
```

Username `git`, password is the token. See `reference/git-bridge.md` if the user does not
have one yet, or if the clone fails with an authentication or 404 error — a 404 usually
means the bridge is not enabled for that project rather than a bad ID.

**If already cloned**, refresh before doing anything. Coauthors have almost certainly pushed
since last time:

```bash
git status              # any uncommitted local mess to deal with first?
git pull --rebase
```

## 2. Detect the default branch

The bridge uses `main` or legacy `master`, and you cannot tell which without looking:

```bash
git branch -r
```

Note which it is. Everything downstream depends on it — do not assume.

## 3. Survey the project

```bash
ls -a
git log --oneline -10          # what have coauthors been doing?
grep -ln '\\begin{document}' *.tex
```

Identify:

- **The main document** — see `reference/building.md`. If more than one file has
  `\begin{document}`, ask the user which is the real one.
- **The engine** — pdflatex, xelatex, or lualatex. See `reference/building.md`.
- **The bibliography stack** — biblatex/biber or natbib/bibtex. See
  `reference/bibliography.md`.
- **The line-wrapping convention** of the prose files — see `reference/latex-editing.md`.
  Check this now, while you are reading anyway; it governs every edit you make later.
- **Whether a `.gitignore` exists** and whether build artefacts are committed.

## 4. Baseline build

Build *before* editing anything:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

(substituting the right engine flag and main file).

**If it succeeds:** good. You now know that any subsequent failure is yours.

**If it fails:** stop and tell the user. The project is already broken, which means either a
coauthor pushed something that does not compile, or the project depends on a package your
local TeX Live does not have. Do not start editing on top of a broken build — you will not
be able to tell your errors from the pre-existing ones.

Triage it with `workflows/fix-build.md` if the user wants it fixed. If the failure is a
locally-missing package that Overleaf has, note that and consider whether you can work
without a local build at all (you can still edit, you just lose the verification loop —
say so explicitly).

## 5. Create a working branch

The remote has no branches, but working locally on one keeps `main` clean and makes the
review diff trivial to produce:

```bash
git switch -c agent/<short-topic>
```

Name it for the task: `agent/tighten-intro`, `agent/fix-refs`, `agent/bib-cleanup`.

## 6. Report to the user

Before editing, confirm what you found:

- Main document and engine
- Bibliography stack
- Baseline build result (passed / failed, with the error if failed)
- Recent coauthor activity, if it looks relevant to the task
- Anything that needs a decision — ambiguous main document, missing packages, committed
  artefacts, an existing broken state

Then proceed to `workflows/edit-and-push.md`.
