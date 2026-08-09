# Overleaf plugin — design

Date: 2026-08-09
Status: approved

## Problem

Colleagues use Overleaf. We want to drive Overleaf projects with AI agents: editing prose,
fixing compile errors, and managing bibliographies.

The apparent starting point, <https://www.overleaf.com/devs>, is a red herring. It documents
a single endpoint, `https://www.overleaf.com/docs` — the "Open in Overleaf" link generator.
It is unauthenticated, write-only, and *creates a new project* from publicly reachable
content. It cannot list, read, or edit an existing project. It is not usable as an agent
backend.

## Integration point

The **Git bridge**:

```
git clone https://git.overleaf.com/<PROJECT_ID>
```

Username `git`, password = an authentication token from Overleaf Account Settings. This
exposes the project as an ordinary file tree, which is the right shape for an agent.

It is a **premium feature** — the project *owner* needs a paid Overleaf plan. Whether the
user has this is unconfirmed, and affects only the fallback section of one reference file.

## Scope

In scope (user-selected): writing and editing prose, building and fixing compile errors,
bibliography management.

Out of scope: review/critique-only workflows; helper scripts; building on unofficial
cookie-scraping tools.

## Approach

A **pure documentation skill** — no code — matching the existing `pltr-cli` plugin pattern.

The transport is `git` and the build is `latexmk`; both already exist and work. What an
agent lacks is knowledge: that `/devs` is a dead end, the clone and auth mechanics, the
bridge's constraints, how to extract the real error from a 2000-line `.log`, and the
collaboration discipline for a document coauthors are live-editing.

The local machine has full MacTeX (`latexmk`, `pdflatex`/`xelatex`/`lualatex`, `biber`,
`bibtex`, `chktex`, `latexindent`), so a local compile-and-fix loop is viable.

### Push policy

The agent commits to a **local** branch. The user reviews the diff. Only then is it merged
to the remote's default branch and pushed. Never force-push. This is the safe choice for
papers colleagues are editing live in the browser.

## The four things the skill exists to teach

1. **`/devs` is a dead end — use the Git bridge.** Stated up front so no agent wastes a turn
   on it.

2. **Diff-friendly editing is the top rule.** An agent that reflows paragraphs while fixing a
   sentence produces a diff no coauthor can review — on a shared paper that is worse than the
   original problem. Match the file's existing line-wrapping convention; change only the lines
   you mean to change.

3. **Local build is a pre-check, not the truth.** Local MacTeX and Overleaf's pinned TeX Live
   differ; a package that resolves locally may be absent there. Build locally to iterate;
   Overleaf's build after push is authoritative.

4. **Collaboration discipline.** Always `git pull --rebase` first. Never force-push. The
   remote has no branches, and its default may be `main` *or* legacy `master` — detect, never
   assume. Overleaf can drop track-changes and comment metadata when you push over it, so do
   not mix git pushes with an in-browser review cycle.

## Structure

```
plugins/overleaf/
├── .claude-plugin/plugin.json
└── skills/overleaf/
    ├── SKILL.md
    ├── reference/
    │   ├── git-bridge.md      # token auth, clone URL, bridge constraints, no-premium fallbacks
    │   ├── building.md        # latexmk per engine, log triage, error-decode table
    │   ├── bibliography.md    # .bib hygiene, biber vs bibtex, missing/unused citations
    │   └── latex-editing.md   # diff-friendly editing rules, chktex/latexindent
    └── workflows/
        ├── start-working.md       # clone/refresh, detect main doc + engine, baseline build
        ├── edit-and-push.md       # branch → edit → build → user review → merge → push
        ├── fix-build.md           # systematic compile-failure triage
        └── sync-and-conflicts.md  # pull --rebase, rejected pushes, conflict resolution
```

Plus an `overleaf` entry in the root `.claude-plugin/marketplace.json`.

## Verification

- `claude plugin validate . --strict` and `claude plugin validate ./plugins/overleaf --strict`
  (what CI runs).
- SKILL.md frontmatter parses as YAML and uses only the six Agent Skills spec fields.
- Every `reference/` and `workflows/` file named in the SKILL.md tables exists.
- Local install via `/plugin marketplace add ./`.
- End-to-end smoke test against a real project once premium access is confirmed.
