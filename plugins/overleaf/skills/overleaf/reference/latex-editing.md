# Editing LaTeX in a shared project

The rules here matter more than they look. An Overleaf project is a document several people
are writing at once, and every change you make is read by a human as a diff.

## Rule 1: preserve the file's line-wrapping convention

**This is the single most important rule in this skill.**

A `.tex` file has a line-wrapping style, and it is load-bearing for review. Detect it before
editing:

```bash
awk '{ print length }' section.tex | sort -n | tail -5   # longest lines
grep -c '\.$' section.tex                                # lines ending in a period
```

The three common conventions:

| Convention | Looks like | How to edit |
|---|---|---|
| **One sentence per line** | Every line ends at a `.` | Edit whole lines; a reworded sentence is a one-line diff |
| **Hard-wrapped** | Lines capped near 80/100 chars, breaking mid-sentence | Rewrap only the paragraph you changed, to the same width |
| **Unwrapped** | One very long line per paragraph | The whole paragraph is one line; a diff shows the entire paragraph either way |

**Never convert between conventions.** Never reflow a paragraph you were only asked to
reword. Changing one sentence in a hard-wrapped paragraph and reflowing the rest turns a
one-line diff into a twelve-line diff, and a coauthor can no longer see what you actually
did. That is worse than the problem you were fixing.

If the user explicitly asks you to reformat, do it as a **separate commit** containing
nothing else.

## Rule 2: change only the lines you mean to change

- No trailing-whitespace cleanup on lines you did not otherwise touch.
- No re-indenting.
- No converting tabs to spaces, or quote styles, or `--` to en-dashes, unless asked.
- No reordering preamble packages "for tidiness".

Check yourself before committing:

```bash
git diff --stat            # is the line count roughly what you intended?
git diff --word-diff       # did you change words, or just whitespace?
git diff --check           # whitespace errors introduced
```

If `git diff --stat` reports far more changed lines than the edit warranted, something
reflowed. Fix it before the user sees it.

## Rule 3: labels and cross-references

`\label`s are referenced from anywhere in the project, including files you have not opened.

Before renaming or deleting a label:

```bash
grep -rn '\\label{sec:intro}' --include='*.tex' .
grep -rn -E '\\(ref|cref|Cref|autoref|eqref|pageref)\{sec:intro\}' --include='*.tex' .
```

Fix every reference in the same commit. A dangling `\ref` compiles to `??` — it does not
fail the build, so it will not be caught by the compile loop.

The same applies to citation keys — see `reference/bibliography.md`.

## Rule 4: follow the project's existing conventions

Before introducing anything new, look at what the project already does.

```bash
# Project-specific macros usually live in one of these
ls *.sty macros.tex preamble.tex definitions.tex commands.tex 2>/dev/null
grep -rn '\\newcommand\|\\DeclareMathOperator\|\\newenvironment' --include='*.tex' --include='*.sty' .
```

- If the project defines `\R` for the reals, use `\R`, not `\mathbb{R}`.
- Match the existing citation command (`\cite` vs `\citep`/`\citet` vs `\parencite`).
- Match the existing referencing command (`\ref` vs `\cref`).
- Match float placement conventions, figure/table environments, and units handling
  (`siunitx` or manual).

Do not add a `\usepackage` when an already-loaded package does the job. Adding packages is
also the main way to break the build on Overleaf while it still works locally — see
`reference/building.md`.

## Rule 5: comments and commented-out text

`.tex` files in shared papers are full of commented-out prose, TODO notes, and alternative
phrasings coauthors are still deciding between.

- Do not delete commented-out content unless asked. It is often someone's work-in-progress.
- Do not "clean up" `% TODO` notes.
- If your edit makes a commented block obsolete, mention it to the user rather than removing
  it yourself.

## Linting and formatting

### chktex — safe, read-only

`chktex` finds real LaTeX problems: bad spacing after abbreviations, `$$` instead of
`\[...\]`, missing non-breaking spaces before `\ref`, unbalanced delimiters.

```bash
chktex -q main.tex                # lint one file
chktex -q -n8 -n36 main.tex       # suppress noisy warning classes
```

Useful as a check. Apply its suggestions selectively — many are stylistic, and a paper that
has never been linted will produce hundreds of hits that are not worth a mass rewrite.

### latexindent — dangerous by default

`latexindent` reformats whitespace across a whole file. **Only run it if the project already
uses it** (look for `.latexindent.yaml`, `latexindent.yaml`, or a formatting note in the
repo).

On a project that does not use it, running `latexindent` rewrites every line, destroys the
diff, and buries your actual change. This is the fastest way to make a coauthor's review
impossible.

## A note on prose editing

When rewriting prose in an academic paper:

- Preserve the authors' terminology exactly. Papers define terms precisely, and swapping a
  synonym in one place while leaving it elsewhere introduces an inconsistency the authors
  will have to hunt down.
- Preserve hedging. "may suggest" and "demonstrates" are not interchangeable in a results
  section.
- Do not change claims, numbers, or the strength of a result. If a sentence seems to
  overstate the evidence, raise it with the user — do not silently soften it.
- Keep tense and voice consistent with the surrounding section.
