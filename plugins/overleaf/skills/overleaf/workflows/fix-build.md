# Workflow: fixing a compile failure

A systematic loop. The discipline that matters: **fix one error at a time, narrowest fix
first, rebuild after each**. LaTeX errors cascade — a single unclosed brace can produce
thirty error messages, twenty-nine of which are noise.

## 1. Reproduce with a clean state

Stale auxiliary files produce phantom errors that survive the real fix:

```bash
latexmk -C
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

If it now succeeds, the problem was stale `.aux`/`.bbl` state, not the source. Say so and
stop.

## 2. Establish whose failure this is

Before debugging, know whether you caused it:

```bash
git stash                                                     # set your changes aside
latexmk -C && latexmk -pdf -interaction=nonstopmode main.tex  # does it build without them?
git stash pop
```

- **Builds without your changes** → your edit broke it. The diff tells you where to look.
- **Fails without your changes too** → pre-existing. Either a coauthor pushed something
  broken, or the project needs a package your local TeX Live lacks. Tell the user which,
  before spending effort on it.

## 3. Extract the first error

Only the first one is reliable:

```bash
grep -n -A5 '^!' main.log | head -20
```

(Not `-m1` — on BSD grep and ugrep that suppresses the `-A` context and you lose the line
number. See `reference/building.md`.)

The block gives you the error text and a line reference in the form `l.<N>`. Note that `l.N`
is the line where TeX *noticed* the problem, which is often after where the problem actually
is — an unclosed brace is reported at the end of the paragraph, not at the brace.

Skip the `!  ==> Fatal error occurred` trailer; it is a summary, not the error.

If `-halt-on-error` masked useful context, rerun without it to see the whole picture, then
still fix the first error only:

```bash
latexmk -pdf -interaction=nonstopmode main.tex
grep -n -A5 '^!' main.log
```

## 4. Classify and fix

Look the error up in the decode table in `reference/building.md`.

Apply the **narrowest** fix that addresses it:

- A missing `$` → wrap that expression, do not restructure the sentence.
- An undefined control sequence → check the spelling first. Only add a `\usepackage` if the
  command genuinely comes from a package the project does not load.
- An unbalanced brace → find and close it, do not rewrite the block.

Do not take the opportunity to tidy surrounding code. Every extra changed line makes the fix
harder to review.

### The missing-package case

```bash
tlmgr search --global --file "/foo.sty"   # find the providing package
sudo tlmgr install foo
```

Two things to be careful about:

1. This fixes your **local** build only. It changes nothing about Overleaf.
2. The reverse risk is worse: if the fix you are considering involves *adding* a
   `\usepackage`, that package may not exist in Overleaf's pinned TeX Live even though it is
   in yours. Prefer a solution using packages the project already loads. If you must add one,
   flag it explicitly so the user checks the Overleaf build.

If the package is missing locally but the project builds fine on Overleaf, installing it is
the right move — you are catching up to Overleaf's environment, not diverging from it.

## 5. Rebuild and repeat

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

Back to step 3 for the next error. Expect the error count to drop sharply after the first
real fix.

## 6. Check the non-fatal failures

A clean exit is not a correct document. These do not fail the build:

```bash
grep -n 'undefined' main.log            # \ref or \cite resolving to ?? or [?]
grep -n 'multiply-defined' main.log     # duplicate \label
grep -n 'LaTeX Warning' main.log
```

Undefined references after a successful full `latexmk` run are real — `latexmk` already did
the reruns, so they will not resolve on their own. Chase them down; see
`reference/latex-editing.md` for labels and `reference/bibliography.md` for citations.

## 7. When you are stuck

If two or three attempts have not moved it:

- **Bisect the document.** Comment out half the body with `\iffalse ... \fi` (not `%`, which
  would be an enormous diff) and rebuild to find which half contains the problem. Undo this
  before committing — it must not end up in a commit.
- **Check `git log -p` on the file** for what a coauthor changed recently.
- **Stop and ask.** Report the exact error, the line, what you tried, and what you ruled out.
  A guessed fix in someone else's paper is worse than no fix.
