# Bibliographies and citations

## First: which bibliography stack is this project using?

Getting this wrong means running the wrong tool and producing confusing failures. Check the
preamble:

```bash
grep -n 'usepackage.*\(biblatex\|natbib\)\|\\bibliography\|\\addbibresource\|\\printbibliography' *.tex
```

| Preamble signal | Stack | Backend | Bibliography printed with |
|---|---|---|---|
| `\usepackage[...]{biblatex}` + `\addbibresource{refs.bib}` | biblatex | **biber** (default) | `\printbibliography` |
| `\usepackage[backend=bibtex]{biblatex}` | biblatex | bibtex | `\printbibliography` |
| `\usepackage{natbib}` + `\bibliography{refs}` | natbib | **bibtex** | `\bibliography{refs}` |
| `\bibliography{refs}` with no package | plain BibTeX | **bibtex** | `\bibliography{refs}` |

`latexmk` detects this and runs the right backend automatically. Prefer letting it do so
rather than invoking `biber`/`bibtex` by hand.

If you must run the backend manually:

```bash
biber main       # biblatex projects (no extension)
bibtex main      # natbib / plain BibTeX projects (no extension)
```

Then rerun the LaTeX pass — twice, for citations to resolve into the text.

### Citation commands differ by stack

Match what the project already uses:

- **natbib**: `\citep{key}` (parenthetical), `\citet{key}` (textual), `\citeauthor`, `\citeyear`
- **biblatex**: `\parencite{key}`, `\textcite{key}`, `\cite{key}`, `\autocite{key}`
- **plain**: `\cite{key}`

Do not mix stacks' commands. `\citep` in a biblatex document without a compatibility option
is an undefined control sequence.

## Diagnosing citation problems

```bash
# Keys cited in the document but missing from the .bib
grep -n 'Citation.*undefined' main.log

# For biblatex/biber, the detailed report is in the .blg
grep -n -i 'warn\|error' main.blg
```

`LaTeX Warning: Citation 'foo' undefined` has three common causes, in order of likelihood:

1. The key genuinely is not in any `.bib` file — check with
   `grep -rn '@.*{foo,' *.bib`.
2. The bibliography backend has not been run yet — rerun `latexmk`, which handles it.
3. The `.bib` file is not registered — missing `\addbibresource{refs.bib}` (biblatex, needs
   the extension) or `\bibliography{refs}` (bibtex, no extension).

### Stale `.bbl` and `.blg`

If citations behave inexplicably, a stale intermediate file is a common cause:

```bash
latexmk -C && latexmk -pdf -interaction=nonstopmode main.tex
```

Careful: some Overleaf projects commit a `.bbl` deliberately, because journal submission
systems require it and the project may not run a backend at all. Check `git ls-files` before
deleting one.

## `.bib` hygiene

### Citation keys

- Keys are referenced from `.tex` files across the project. **Renaming a key is a
  project-wide edit**, exactly like renaming a `\label`:

  ```bash
  grep -rn 'smith2020' --include='*.tex' .
  ```

  Fix every citation in the same commit as the rename.

- Follow the project's existing key convention — usually `authorYEARword` (`smith2020deep`)
  or `AuthorYear`. Do not introduce a second convention.

### Duplicate keys

BibTeX silently uses one entry and ignores the rest; biber warns. Both are bad.

```bash
grep -oE '^@[a-zA-Z]+\{[^,]+,' refs.bib | sed -E 's/^@[a-zA-Z]+\{//; s/,$//' | sort | uniq -d
```

### Duplicate entries under different keys

The same paper cited twice under two keys — common when coauthors each paste from a
different source. Find them by DOI and by title:

```bash
# by DOI - the reliable signal
grep -i '^[[:space:]]*doi[[:space:]]*=' refs.bib \
  | sed -E 's/^[^=]*=[[:space:]]*//; s/[{}",]//g; s/[[:space:]]+$//' \
  | tr 'A-Z' 'a-z' | sort | uniq -d

# by normalised title - catches entries with no DOI
grep -i '^[[:space:]]*title[[:space:]]*=' refs.bib \
  | sed -E 's/^[^=]*=[[:space:]]*//' \
  | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9]//g' | sort | uniq -d
```

These use POSIX bracket classes rather than `\s`, which BSD `sed` does not support. Both
assume one field per line, which is the normal `.bib` layout but not guaranteed — treat a
clean result as weak evidence, not proof.

Merging duplicates means picking one key and updating every `.tex` reference to the other —
tell the user which key you kept.

### Protecting capitalization

Most bibliography styles lowercase titles. Proper nouns, acronyms, and initialisms must be
brace-protected or they come out wrong:

```bibtex
title = {A {B}ayesian Approach to {LSTM} Networks on {ImageNet}}
```

This is the most common real defect in a shared `.bib`. Worth fixing when you notice it, but
mention it rather than silently rewriting dozens of entries.

### Field consistency

Within one `.bib` file, keep to whatever the file already does:

- Braces `{...}` vs quotes `"..."` for values — braces are safer.
- Whether `month` is a three-letter macro (`jan`) or a string.
- Whether page ranges use `--` (correct) or `-`.
- Whether `journal` names are abbreviated or spelled out — must be consistent, since styles
  do not normalise them.

### Unused entries

Entries in the `.bib` that nothing cites are harmless — most styles only print cited works.
Do not prune them without asking: coauthors often keep a working set of references they
intend to cite later.

To list them anyway:

```bash
# keys defined
grep -oE '^@[a-zA-Z]+\{[^,]+,' refs.bib | sed -E 's/^@[a-zA-Z]+\{//; s/,$//' | sort -u > /tmp/defined
# keys cited
grep -rhoE '\\[a-zA-Z]*cite[a-zA-Z]*\**(\[[^]]*\])*\{[^}]*\}' --include='*.tex' . \
  | grep -oE '\{[^}]*\}$' | tr -d '{}' | tr ',' '\n' | tr -d ' ' | sort -u > /tmp/cited
comm -23 /tmp/defined /tmp/cited
```

## Adding new references

When adding an entry:

1. Prefer the publisher's or DBLP's BibTeX over a hand-written entry — fewer errors.
2. Match the file's existing field style and key convention.
3. Include a `doi` where one exists; it is what makes future dedupe possible.
4. Brace-protect capitalization in the title.
5. Append to the end of the file, or into the file's existing grouping if it has one — do not
   re-sort the whole `.bib`, which destroys the diff (see `reference/latex-editing.md`).
