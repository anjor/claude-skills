# The Overleaf Git bridge

The only supported way to read and write an existing Overleaf project programmatically.

## Not the Git bridge: `overleaf.com/devs`

Before anything else: <https://www.overleaf.com/devs> is not a project API. It documents
one endpoint, `https://www.overleaf.com/docs`, which takes LaTeX source (as `snip`,
`encoded_snip`, or a `snip_uri` pointing at a publicly reachable file or `.zip`) and
**creates a new project** from it.

- No authentication, no API key, no registration.
- Write-only. There is no read, list, or update.
- The target file must be reachable from Overleaf's servers over HTTP/HTTPS.

Its legitimate use is putting an "Open in Overleaf" button on a website. It is useless for
working on an existing project. Do not reach for it.

## Getting an authentication token

Token authentication is the only login method for the Git bridge on both Overleaf Cloud and
Server Pro. Password-based authentication was removed.

1. Overleaf → **Account Settings**.
2. Find the **Git integration** / authentication tokens section.
3. Create a token and copy it — it is shown once.

One token works for all of your projects.

**Confirming you have access:** open any project, look in the left sidebar under
**Integrations** for a **Git** entry. If it shows a clone URL, the bridge is enabled for
that project. If the section is missing, the project owner does not have a qualifying plan.

## Cloning

```bash
git clone https://git.overleaf.com/<PROJECT_ID> my-paper
```

When prompted:

- Username: `git`
- Password: the token

`<PROJECT_ID>` is the identifier in the project URL:
`https://www.overleaf.com/project/<PROJECT_ID>`.

For **Server Pro** (v4.0+) the URL form is instead:

```bash
git clone git@<SHARELATEX_SITE_URL>/git/<PROJECT_ID>
```

### Storing the token

Use the platform credential helper so the token is entered once and stored in the keychain:

```bash
git config --global credential.helper osxkeychain    # macOS
```

**Never:**

- commit the token to any repository;
- embed it in the clone URL (`https://git:TOKEN@git.overleaf.com/...`) — it lands in
  `.git/config` in plaintext and in shell history;
- `export` it from a shell rc file.

If a token is ever exposed, delete it in Account Settings and create a new one.

### Name the clone directory yourself

Project IDs are opaque. `git clone <url>` alone produces a directory named after the ID,
which is unreadable a week later. Always pass an explicit directory name, and if you manage
several projects, keep a note mapping names to IDs.

## Bridge constraints

These are hard limits of the bridge, not preferences.

| Constraint | Consequence |
|---|---|
| **No branches on the remote** | You cannot push a feature branch. Work on a local branch, merge locally, push the default branch. |
| **Default branch may be `main` or legacy `master`** | Detect it with `git branch -r`. Never hardcode either. |
| **No tags** | Tag locally if you want, but they will not sync. |
| **Symlinks and Git LFS unsupported** | Do not introduce them. |
| **File execute permissions not preserved** | Do not depend on the executable bit. |
| **Project file-count and size limits apply** | A push that exceeds the plan's limits is rejected. |
| **Folder renames leave the old empty folder behind** | Clean it up in the web UI afterwards. |
| **File renames/moves can lose tracked changes and comments** | Warn the user before renaming anything in a project under review. |

### Track changes and comments

Overleaf explicitly does not recommend combining Git pushes with track-changes and comments.
Pushing can drop that metadata. If coauthors have review activity in the browser, tell the
user before pushing and let them decide.

## Standard hygiene for a cloned project

Overleaf projects frequently arrive with no `.gitignore` and sometimes with build artefacts
already committed. Before working:

```bash
git branch -r          # find the default branch
ls -a                  # is there a .gitignore?
git ls-files | grep -E '\.(aux|log|out|bbl|blg|synctex\.gz|fdb_latexmk|fls)$'
```

A reasonable `.gitignore` for a LaTeX project:

```gitignore
*.aux
*.bbl
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.synctex.gz
*.toc
```

Do not delete already-committed artefacts without asking — a coauthor may be relying on a
committed `.bbl` if the project builds without a bibliography tool.

## When the Git bridge is unavailable

The bridge is a premium feature: it works only if the **project owner** has a paid Overleaf
plan (or was grandfathered/beta-granted access). Note that it is the owner's plan that
matters, not yours — you can often clone a colleague's project even on a free account, if
they are paying.

If it is genuinely unavailable:

**Supported fallback — manual `.zip` round-trip.** In the project, Menu → Download →
Source, which gives a `.zip` of the whole project. Unzip it, work locally under normal git,
and upload the modified files back through the web UI. Slow and fully manual, but it is
within the terms of service and cannot corrupt anything.

**Unsupported tools.** Community projects such as
[pyoverleaf](https://github.com/jkulhanek/pyoverleaf) and
[overleaf-sync](https://github.com/moritzgloeckl/overleaf-sync) drive Overleaf's internal
web endpoints with a scraped session cookie. They exist and they work for some people, but
they are unofficial, break when Overleaf changes its frontend, require handing your session
credentials to a third-party script, and are not covered by any support agreement.

This skill does not build on them. If the user wants to go that route, say plainly that it
is unsupported and let them choose.
