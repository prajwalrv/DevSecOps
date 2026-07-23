Contents : 

	1. .gitignore
	2. Native Git Pre-Commit Hooks (Custom Scripts)
	2. Block Commits with Gitleaks
	3. Gitleaks - Repository & Hstory Scanning
	4. Gitleaks in GitHub Actions
	5. Branch Protection Rules
	6. RBAC
	8. Mandatory Reviews
	9. CODEOWNERS
       10. Dependabot

-------------------------------------------------------------------------------------------

======> 1. .gitignore :

Scenario : 
[ Imagine there is an oraganisation & thi org has Microservice(Svc). 
  Source code of this Svc is within git repository. 
  Devleopers clone this repo and will work on this repo.
  Lets say one of the Devloper is working on this repo & he is basically 
  DB changes - (updated .env file with DB password) & commited the same. --> (P0 - Critical)
]    
--> Solution - .gitignore ->. Org -> Svc -> Repo -> Dev

example : .gitignore - read this file in this directory of the DevSecOps repo

This exact file ignore all the enlisted files/changes to ignore in commits.

-------------------------------------------------------------------------------------------

======> 2. Pre Commit Hook :

PRE-COMMIT HOOK WORKFLOW: BLOCKING SECRETS BEFORE COMMIT
=============================================================================

[ 1. CONFIGURE ] -----> [ 2. SCRIPT ] -----> [ 3. TRIGGER ] -----> [ 4. RESULT ]
      |                     |                    |                    |
      v                     v                    v                    v
+-------------+         +-------------+      +-------------+      +-------------+
| LOCATE HOOK |         | WRITE PATTERN|     | USER COMMITS|      | HOOK EXECUTES|
| DIRECTORY   |         | MATCHING LOGIC|    | WITH MSG    |      | & SCANS CODE |
+------+------+         +------+------+      +------+------+      +------+------+
       |                     |                    |                    |
       | Path:               | Script:            | Command:           | Check:
       | .git/hooks/         | pre-commit         | git commit         | - Regex for
       |                     | (Shell/Python)     | -m "Msg"           |   AWS Keys,
       | Create file:        |                    |                    |   Passwords,
       | 'pre-commit'        | Logic:             | Git pauses         |   Tokens.
       | (No extension)      | IF pattern found   | execution          |
       |                     | THEN exit 1        |                    |
       |                     | (Block)            |                    |
       |                     | ELSE exit 0        |                    |
       |                     | (Allow)            |                    |
       |                     |                    |                    |
       +----------+----------+----------+---------+----------+---------+
                  |                     |                    |
                  v                     v                    v
           [ SUCCESS CASE ]      [ FAILURE CASE ]      [ FEEDBACK ]
                  |                     |                    |
                  v                     v                    v
           +-------------+       +-------------+       +-------------+
           | COMMIT      |       | COMMIT      |       | DEVELOPER   |
           | PROCEEDS    |       | BLOCKED     |       | FIXES CODE  |
           | TO REPO     |       | + MESSAGE   |       | & RETRIES   |
           +-------------+       +-------------+       +-------------+
                  |                     |                    |
                  | "Commit successful" | "Secret detected!" | "Remove secret,
                  |                     |                    |  re-stage, re-commit"

=============================================================================
DETAILED STEP-BY-STEP EXECUTION (Based on your example):

STEP 1: ADD HOOK
   - Navigate to your repo: cd ~/Documents/DevSecOps
   - Go to hooks folder: cd .git/hooks
   - Create the file: touch pre-commit
   - Make it executable: chmod +x pre-commit

STEP 2: WRITE SCRIPT (The "Pattern Matcher")
   - Edit 'pre-commit' and add logic (simplified bash example):
     
     #!/bin/bash
     echo "Running native pre-commit hook...."
     
     # Check staged files for secret patterns
     if git diff --cached --name-only | xargs grep -l "secret\s*=\s*[0-9a-zA-Z]" ; then
         echo "+secret = 123"
         echo "Secret detected. Commit blocked."
         exit 1  # Stops the commit
     fi
     
     exit 0  # Allows the commit

STEP 3: TRIGGER (User Action)
   - Developer tries to commit a file with a hardcoded secret:
     $ git add main.py
     $ git commit -m "Committing a main.py file with hardcoded secret"

STEP 4: RESULT (The Gatekeeper Effect)
   - SCENARIO A (Secret Found):
     > Running native pre-commit hook....
     > +secret = 123
     > Secret detected. Commit blocked.
     [Process stops. Code is NOT saved to Git history.]
     
   - SCENARIO B (Clean Code):
     > Running native pre-commit hook....
     > No secrets found.
     [Commit proceeds to local repository.]

=============================================================================
KEY CONCEPT:
The hook runs LOCALLY on your machine (in the Kali terminal shown) 
BEFORE the data is ever sent to a remote server (GitHub/GitLab).
This is the essence of "Shift Left": catching the error at the source.
=============================================================================   

-------------------------------------------------------------------------------------------

======> 3. Block Commits with Gitleaks :

EVOLUTION: FROM MANUAL SCRIPTS TO DECLARATIVE CONFIG
=============================================================================

[ MANUAL APPROACH ]                      [ MODERN FRAMEWORK APPROACH ]
      |                                         |
      v                                         v
+------------------+                    +------------------+
| .git/hooks/      |                    | .pre-commit-     |
| pre-commit       |                    | config.yaml      |
| (Bash Script)    |                    | (Declarative)    |
+------------------+                    +------------------+
      |                                         |
      | YOU MUST:                               | YOU DECLARE:
      | 1. Write regex logic                    | 1. Repo URL
      | 2. Manage updates                       | 2. Version (rev)
      | 3. Install dependencies                 | 3. Hook ID
      | 4. Hope everyone runs it                |
      |                                         | Framework DOES:
      |                                         | 1. Downloads Gitleaks
      |                                         | 2. Isolates environment
      |                                         | 3. Enforces version
      |                                         | 4. Runs automatically
      v                                         v
[ FRAGILE & INCONSISTENT ]              [ ROBUST & STANDARDIZED ]

=============================================================================
YOUR CONFIGURATION BREAKDOWN:

repos:
  - repo: https://github.com/gitleaks/gitleaks   <-- Source of truth
    rev: v8.30.0                                 <-- Pinned Version (Critical!)
    hooks:
      - id: gitleaks                             <-- Hook to execute

=============================================================================
EXECUTION FLOW WITH YAML CONFIG:

[ 1. DECLARE ] -----> [ 2. INSTALL ] -----> [ 3. COMMIT ] -----> [ 4. RUN ]
      |                   |                    |                    |
      v                   v                    v                    v
+-------------+       +-------------+      +-------------+      +-------------+
| CREATE YAML |       | RUN         |      | DEVELOPER   |      | FRAMEWORK   |
| FILE        |       | pre-commit  |      | TRIGGERS    |      | MANAGES     |
|             |       | install     |      | GIT COMMIT  |      | EXECUTION   |
+------+------+       +------+------+      +------+------+      +------+------+
       |                   |                    |                    |
       | Define:           | Command:           | Action:            | Magic:
       | - Repo URL        | $ pre-commit       | $ git commit       | - Clones
       | - Rev (v8.30.0)   |   install          | -m "msg"           |   Gitleaks
       | - Hook ID         |                    |                    | - Creates
       |                   | Result:            | Git triggers       |   isolated
       |                   | .git/hooks/        | .git/hooks/        |   env
       |                   | pre-commit         | pre-commit         | - Runs
       |                   | (Managed by        | (Wrapper script)   |   Gitleaks
       |                   |  Framework)        |                    |   v8.30.0
       |                   |                    |                    |
       +----------+--------+----------+---------+----------+---------+
                  |                   |                    |
                  v                   v                    v
           [ VERSION LOCKED ]   [ AUTOMATED ]       [ CONSISTENT ]
                  |                   |                    |
                  | Everyone uses     | No manual script   | Same result on
                  | exactly v8.30.0   | writing required   | Mac, Linux, Win

=============================================================================
WHY THIS IS BETTER THAN CUSTOM SCRIPTS:

1. ZERO MAINTENANCE:
   - No need to update regex patterns manually.
   - Gitleaks team updates the rules; you just bump the 'rev' number.

2. DEPENDENCY ISOLATION:
   - Framework installs Gitleaks in a virtual environment.
   - Does not conflict with your system's Go or Python installations.

3. TEAM CONSISTENCY:
   - The YAML file is committed to Git.
   - Every developer runs the EXACT same binary version.
   - Eliminates "it works on my machine" due to different script versions.

4. COMPOSABILITY:
   - Easily add more hooks (e.g., black, flake8) to the same YAML file.
   - No need to merge complex bash scripts.

=============================================================================
ACTIVATION COMMANDS (One-time setup per developer):

# 1. Install the framework tool
pip install pre-commit

# 2. Read your YAML and install the hooks
pre-commit install

# Output: pre-commit installed at .git/hooks/pre-commit
# Now Git automatically calls the framework, which calls Gitleaks.
=============================================================================   
