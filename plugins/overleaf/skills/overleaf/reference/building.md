# Building LaTeX locally

A local build is a fast pre-check. Overleaf's build after the push is authoritative — the
local TeX distribution and Overleaf's pinned TeX Live differ.

## Finding the main document

An Overleaf project has one main document. Candidates, in order of reliability:

```bash
# 1. An explicit magic comment
grep -rn '% *!TEX root' --include='*.tex' .

# 2. Overleaf's own setting, if the project has a latexmkrc
cat latexmkrc .latexmkrc 2>/dev/null

# 3. Files that contain a document environment
grep -ln '\\begin{document}' *.tex
```

Usually it is `main.tex`, `paper.tex`, or `<something>.tex` matching the conference template.
If more than one file has `\begin{document}`, ask the user rather than guessing — building
the wrong one wastes a cycle and can produce misleading errors.

## Choosing the engine

Overleaf stores the engine per-project (Menu → Compiler). Locally, infer it:

| Signal | Engine |
|---|---|
| `% !TEX program = xelatex` (or `lualatex`) magic comment | as stated |
| `latexmkrc` setting `$pdf_mode` (1 = pdflatex, 4 = lualatex, 5 = xelatex) | as stated |
| `\usepackage{fontspec}` or `unicode-math` | xelatex or lualatex — **not** pdflatex |
| CJK packages, system font loading | xelatex or lualatex |
| Nothing unusual | pdflatex |

If the signals conflict, ask. Building with the wrong engine produces a wall of errors that
has nothing to do with the actual document.

## Invocations

Always use non-interactive flags — an agent must never leave `latexmk` waiting at a `?`
prompt.

```bash
# pdflatex (most common)
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex

# xelatex
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex

# lualatex
latexmk -lualatex -interaction=nonstopmode -halt-on-error main.tex
```

`latexmk` handles the rerun logic itself: it reruns for cross-references, invokes
biber/bibtex when needed, and stops when the output stabilises. Do not hand-roll a
pdflatex → bibtex → pdflatex → pdflatex sequence.

`-halt-on-error` stops at the first hard error. This is what you want while fixing a build:
later errors are usually cascades from the first one.

To see everything at once instead (useful for a survey), drop `-halt-on-error`.

## Reading the log without drowning in it

A `.log` for a real paper runs to thousands of lines, nearly all of it font and package
chatter. Never read the whole file. Extract.

```bash
# Hard errors: every TeX error line starts with "!" in column 1
grep -n -A5 '^!' main.log

# Just the first one, which is usually the only real one
grep -n -A5 '^!' main.log | head -20

# Undefined references and citations
grep -n 'undefined' main.log

# All LaTeX-level warnings
grep -n 'LaTeX Warning' main.log

# Missing files (packages, images, inputs)
grep -n -E 'not found|No file|Unable to load' main.log

# Overfull/underfull boxes - cosmetic, usually ignore unless asked
grep -c 'Overfull\|Underfull' main.log
```

Do not add `-m1` to narrow it to the first hit. On BSD grep and ugrep (the default `grep` on
many macOS setups), `-m1` stops reading at the match and suppresses the `-A` context, leaving
you with a bare error line and no line number. Pipe to `head` instead, as above.

Read the extracted window, then open the offending `.tex` at the reported line. The log
reports line numbers as `l.<N>` in the error block — that is the line to open, and it is the
most useful thing in the extract.

One line that always matches `^!` is the trailer:

```
!  ==> Fatal error occurred, no output PDF file produced!
```

That is a summary, not a diagnosis. Ignore it and work from the first real error above it.

Note: with `-halt-on-error`, `latexmk`'s exit status is non-zero on failure, so the shell
exit code alone tells you whether to start triage.

## Error decode table

| Log message | Meaning | Fix |
|---|---|---|
| `! Undefined control sequence.` | A command that does not exist — typo, or the package defining it is not loaded | Check spelling; add the `\usepackage` |
| `! Missing $ inserted.` | Math-mode character (`_`, `^`, `\alpha`) used in text | Wrap in `$...$`, or escape `\_` |
| `! LaTeX Error: File \`foo.sty' not found.` | Package not installed locally | `tlmgr install foo` — **and** check it exists on Overleaf |
| `! LaTeX Error: Environment foo undefined.` | `\begin{foo}` with no defining package | Add the package |
| `! Runaway argument?` | Unclosed brace or a blank line inside a command argument | Find the unbalanced `{` |
| `! Missing \begin{document}.` | Stray text or a bad character before `\begin{document}` | Usually an encoding problem or text in the preamble |
| `! Too many }'s` / `! Extra }` | Unbalanced braces | Count braces around the reported line |
| `! LaTeX Error: Can be used only in preamble.` | A preamble-only command after `\begin{document}` | Move it up |
| `! Package inputenc Error: Unicode character ...` | Non-ASCII character under pdflatex | Switch to xelatex/lualatex, or escape the character |
| `LaTeX Warning: Reference \`x' on page N undefined.` | Cross-reference not yet resolved, or `\label` missing | Rerun; if it persists, the `\label` really is absent |
| `LaTeX Warning: Citation \`x' undefined.` | Key missing from the `.bib`, or bibliography tool not run | See `reference/bibliography.md` |
| `LaTeX Warning: There were multiply-defined labels.` | Two `\label`s share a name | Rename one and fix its `\ref`s |

## Missing packages, and the Overleaf gap

When a package is missing locally:

```bash
tlmgr search --global --file "/foo.sty"   # which package provides it
sudo tlmgr install foo
```

This solves the *local* build only. The reverse case matters more: a package present in your
local TeX Live may be absent from, or a different version to, Overleaf's. If you add a
`\usepackage` for something unusual, flag it to the user — they should confirm the Overleaf
build after pushing.

## Cleaning

```bash
latexmk -c    # remove auxiliary files, keep the PDF
latexmk -C    # remove auxiliary files and the PDF
```

Clean before a baseline build when you suspect a stale `.aux` is producing phantom errors.

Do not commit build artefacts — see the `.gitignore` guidance in `reference/git-bridge.md`.
