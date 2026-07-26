# DevSecOps: Secrets Management & Access Control Notes

## Table of Contents
1. [.gitignore](#1-gitignore)
2. [Native Git Pre-Commit Hooks (Custom Scripts)](#2-native-git-pre-commit-hooks-custom-scripts)
3. [Block Commits with Gitleaks (pre-commit framework)](#3-block-commits-with-gitleaks-pre-commit-framework)
4. [Gitleaks – Repository & History Scanning](#4-gitleaks--repository--history-scanning)
5. [Gitleaks in GitHub Actions](#5-gitleaks-in-github-actions)
6. [Branch Protection Rules](#6-branch-protection-rules)
7. [RBAC (Role-Based Access Control)](#7-rbac-role-based-access-control)
8. [Mandatory Reviews](#8-mandatory-reviews)
9. [CODEOWNERS](#9-codeowners)
10. [Dependabot](#10-dependabot)

---

## 1. .gitignore

**Scenario**

> An organization has a microservice (Svc), whose source code lives in a Git repository. Developers clone the repo and work on it. One developer, while making DB-related changes, updates a `.env` file with a **DB password** and commits it.
> 🔴 **P0 – Critical incident.**

**Solution**

```
Org → Svc → Repo → Dev
```

Use a `.gitignore` file. It tells Git to ignore specific files/patterns (like `.env`, credentials, keys) so they are never staged or committed in the first place.

> 📄 See the `.gitignore` file in the DevSecOps repo for the exact list of ignored files/secrets.

---

## 2. Native Git Pre-Commit Hooks (Custom Scripts)

### Workflow: Blocking Secrets Before Commit

```
1. CONFIGURE  →  2. SCRIPT  →  3. TRIGGER  →  4. RESULT
```

| Stage | 1. Configure | 2. Script | 3. Trigger | 4. Result |
|---|---|---|---|---|
| **What** | Locate hook directory | Write pattern-matching logic | User commits with message | Hook executes & scans code |
| **Where/How** | `.git/hooks/` — create file `pre-commit` (no extension) | Script: `pre-commit` (Shell/Python) | `git commit -m "msg"` — Git pauses execution | Regex checks for AWS keys, passwords, tokens |
| **Logic** | — | `IF pattern found → exit 1` (block) `ELSE exit 0` (allow) | — | — |

| Outcome | Result |
|---|---|
| ✅ Success (no secret found) | Commit proceeds to repo — *"Commit successful"* |
| ❌ Failure (secret found) | Commit blocked + message — *"Secret detected!"* → developer removes secret, re-stages, retries |

### Step-by-Step Execution

**Step 1 — Add the hook**
```bash
cd ~/Documents/DevSecOps
cd .git/hooks
touch pre-commit
chmod +x pre-commit
```

**Step 2 — Write the script (the "pattern matcher")**
```bash
#!/bin/bash
echo "Running native pre-commit hook...."

# Check staged files for secret patterns
if git diff --cached --name-only | xargs grep -l "secret\s*=\s*[0-9a-zA-Z]" ; then
    echo "+secret = 123"
    echo "Secret detected. Commit blocked."
    exit 1  # Stops the commit
fi

exit 0  # Allows the commit
```

**Step 3 — Trigger (developer action)**
```bash
git add main.py
git commit -m "Committing a main.py file with hardcoded secret"
```

**Step 4 — Result**

- **Scenario A — Secret found:**
  ```
  Running native pre-commit hook....
  +secret = 123
  Secret detected. Commit blocked.
  ```
  Process stops. Code is **not** saved to Git history.

- **Scenario B — Clean code:**
  ```
  Running native pre-commit hook....
  No secrets found.
  ```
  Commit proceeds to the local repository.

> **Key concept:** The hook runs **locally** on the developer's machine, *before* data is ever pushed to a remote server (GitHub/GitLab). This is "Shift Left" — catching the error at the source.

---

## 3. Block Commits with Gitleaks (pre-commit framework)

### Evolution: From Manual Scripts to Declarative Config

| | Manual Approach (`.git/hooks/pre-commit`) | Modern Framework (`.pre-commit-config.yaml`) |
|---|---|---|
| Format | Bash script | Declarative YAML |
| You must | Write regex logic, manage updates, install dependencies, hope everyone runs it | Just declare repo URL, version (`rev`), hook ID |
| Framework does | — | Downloads Gitleaks, isolates environment, enforces version, runs automatically |
| Result | ⚠️ Fragile & inconsistent | ✅ Robust & standardized |

### Configuration

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks   # Source of truth
    rev: v8.30.0                                 # Pinned version (critical!)
    hooks:
      - id: gitleaks                             # Hook to execute
```

### Execution Flow

```
1. DECLARE  →  2. INSTALL  →  3. COMMIT  →  4. RUN
```

| Stage | 1. Declare | 2. Install | 3. Commit | 4. Run |
|---|---|---|---|---|
| **What** | Create YAML file defining: Repo URL, Rev (`v8.30.0`), Hook ID | Run `pre-commit install` | Developer triggers `git commit -m "msg"` | Framework manages execution |
| **Result** | — | `.git/hooks/pre-commit` (now managed by the framework) | — | Clones Gitleaks, creates isolated env, runs Gitleaks v8.30.0 |

**Outcome:** Version locked → automated → consistent across every developer's machine.

### Activation Commands (one-time setup per developer)

```bash
# 1. Install the framework tool
pip install pre-commit

# 2. Read your YAML and install the hooks
pre-commit install

# Output: pre-commit installed at .git/hooks/pre-commit
# Git now automatically calls the framework, which calls Gitleaks.
```

### Why This Beats Custom Scripts

1. **Zero maintenance** — no manual regex updates; Gitleaks team maintains the rules, you just bump `rev`.
2. **Dependency isolation** — Gitleaks runs in its own virtual environment, no conflicts with your system's Go/Python.
3. **Team consistency** — the YAML is committed to Git, so every developer runs the exact same binary version ("works on my machine" problem eliminated).
4. **Composability** — easily add more hooks (e.g. `black`, `flake8`) to the same YAML without merging complex bash scripts.

---

## 4. Gitleaks – Repository & History Scanning

**Scenario**

> You've just joined a company as a DevSecOps engineer and gained repo access. The company never used pre-commit hooks before, so you need to scan **all historical commits** for secrets already leaked into the repo.

Use the `gitleaks detect` command.

> 💡 **Tip:** Schedule this as a cron job to re-check the commit history once a month.

### Example Run

```bash
┌──(kali㉿kali)-[~/Documents/DevSecOps]
└─$ gitleaks detect

   ○
   │╲
   │ ○
   ○ ░
   ░    gitleaks

5:28AM INF 9 commits scanned.
5:28AM INF scanned ~35498 bytes (35.50 KB) in 71.1ms
5:28AM INF no leaks found
```

---

## 5. Gitleaks in GitHub Actions

**Scenario**

> `.gitignore`, pre-commit hooks, and local Gitleaks are all standard practices — but a new joiner or trainee might skip setting these up locally. To keep the repo secure regardless, add a **CI/CD check** that runs on every `pull_request`, `push`, and `workflow_dispatch`.

### Setup

Go to your repo on GitHub → **Add file** → `your-repo/.github/workflows/gitleaks.yml`

```yaml
name: gitleaks
on: [pull_request, push, workflow_dispatch]
jobs:
  scans:
    name: gitleaks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Example Output (leak found)

```
   ○
   │╲
   │ ○
   ○ ░
   ░    gitleaks

10:07AM DBG using github.com/wasilibs/go-re2 regex engine
10:07AM DBG no gitleaks config found in path .gitleaks.toml, using default gitleaks config
10:07AM DBG executing: git log -p -U0 --no-merges --first-parent <commit>^..<commit>
10:07AM DBG SCM platform parsed from host host=github.com platform=github

Finding:     AWS_SECRET_ACCESS_KEY=REDACTED
Secret:      REDACTED
RuleID:      generic-api-key
Entropy:     3.546594
File:        secrets.env
Line:        1
Commit:      <commit-sha>
Author:      <author-username>
Email:       <author-email>
Date:        2026-07-26T09:59:09Z
Fingerprint: <commit-sha>:secrets.env:generic-api-key:1
Link:        https://github.com/<repo>/blob/<commit-sha>/secrets.env#L1

10:07AM INF 1 commits scanned.
10:07AM DBG Note: this number might be smaller than expected due to commits with no additions
10:07AM INF scanned ~36 bytes (36 bytes) in 150ms
10:07AM WRN leaks found: 1
Artifact name is valid!
Root directory input is valid!
```

---

## 6. Branch Protection Rules

**Scenario**

> Never let anyone push directly to `main`. Force them to raise a pull request, which you review before merging. **How do you protect the main branch?**

### Steps

1. Go to **Settings → Branches → Add branch ruleset**
2. Configure:
   - **Ruleset name**
   - **Enforcement status:** `Active`
   - **Branch targeting criteria:** Add target → `Default`, plus patterns like `release-*` (covers all branches matching the pattern)
   - **Branch rules:**
     - ☑️ Require a pull request before merging
3. Click **Create**

---

## 7. RBAC (Role-Based Access Control)

**Example RBAC Matrix**

| Role | Access Level |
|---|---|
| DevSecOps Engineer | Admin |
| Developers / Contributors | Read & Write |
| QA Engineers | Read only |

### How To Do It

1. Go to **Settings → Collaborators**
2. Select the user and grant their appropriate RBAC permission level.

---

## 8. Mandatory Reviews

**Scenario**

> You want to enforce **two mandatory reviews** and require **CI checks to pass** every time a pull request is created. How?

### Steps

1. **Settings → Branches → Branch Protection Rules**
2. Under **Branch Rules**:
   - ☑️ Require a pull request before merging
     - ☑️ Required approvals: **2**
     - ☑️ Required review from specific teams
     - ☑️ Required review from Code Owners

---

## 9. CODEOWNERS

Once **"Required review from Code Owners"** is checked and saved:

1. Create a file named `CODEOWNERS` in the repo.
2. Add the list of people you want designated as code owners.
3. GitHub will automatically notify these code owners to review any relevant pull request.

---

## 10. Dependabot

### How Dependabot Finds & Fixes Vulnerable Versions

```
DevSecOps ──► Dependabot ──► scans "versions" in dependency manifests
                                    │
                 ┌──────────────────┼──────────────────┬───────────────┐
                 ▼                  ▼                  ▼               ▼
                go               go.mod            pom.xml /         Dockerfile
             (Go modules)      (version list)      npm (package.json)
                 │                  │                  │               │
                 └──────────────────┴──────────────────┴───────────────┘
                                    │
                                    ▼
                         Current version: 1.0
                                    │
                        Checked against vulnerability
                              database
                                    │
                         Vulnerability found? ──► Yes
                                    │
                                    ▼
                          Bump to safe version: 2.0
                                    │
                                    ▼
                            Open Pull Request
                                    │
                                    ▼
                            Review ──► Merge
```

**Reading it step by step:**
1. **DevSecOps → Dependabot** — Dependabot is configured (via `.github/dependabot.yml`) to watch the repo.
2. **Versions** — it scans the dependency manifests for each ecosystem in use: `go.mod` (Go), `pom.xml` (Maven), `package.json` (npm), and `Dockerfile` (Docker base images).
3. **1.0 → vulnerability check** — the currently pinned version is checked against known vulnerability databases.
4. **1.0 → 2.0** — if the current version is vulnerable, Dependabot identifies a fixed/safe version to bump to.
5. **Pull → Merge** — Dependabot opens a pull request with the version bump; once reviewed (and CI passes), it's merged in.

### Automated Workflow

```
[ GitHub Repository ] ◄── Daily/Weekly Scan ── [ Dependabot Engine ]
                                                        │
                                            (Checks database for
                                             vulnerable packages)
                                                        │
                                                        ▼
                                          If updates found
                                                        │
                                                        ▼
                                    [ Automated Pull Request 📦 ]
                                          │
                                          ├──► Runs your CI/CD tests automatically ✅
                                          └──► One-click merge to secure your repo 🚀
```

### Configuration — `.github/dependabot.yml`

```yaml
version: 2
updates:
  # 1. Enable updates for npm (Node.js) ecosystem
  - package-ecosystem: "npm"
    directory: "/"                    # Location of package.json
    schedule:
      interval: "daily"               # Scan every single day
    open-pull-requests-limit: 5       # Prevent spam by capping at 5 open PRs

  # 2. Enable updates for your GitHub Actions workflows
  - package-ecosystem: "github-actions"
    directory: "/"                    # Location of .github/workflows
    schedule:
      interval: "weekly"              # Scan once a week
```

---

## Quick Recap

| # | Control | Layer | Purpose |
|---|---|---|---|
| 1 | `.gitignore` | Local | Prevent staging sensitive files |
| 2 | Native pre-commit hook | Local | Custom secret pattern blocking |
| 3 | Gitleaks + pre-commit framework | Local | Standardized, version-locked secret scanning |
| 4 | `gitleaks detect` | Repo history | Audit past commits for leaked secrets |
| 5 | Gitleaks GitHub Action | CI/CD | Catch secrets even if local hooks are skipped |
| 6 | Branch protection rules | Repo | Block direct pushes to `main` |
| 7 | RBAC | Org | Least-privilege access per role |
| 8 | Mandatory reviews | Repo | Enforce peer review + CI before merge |
| 9 | CODEOWNERS | Repo | Auto-notify the right reviewers |
| 10 | Dependabot | CI/CD | Automated dependency vulnerability patching |