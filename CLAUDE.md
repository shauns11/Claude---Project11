#############################################
#CLAUDE.md (Project11 -Survey_estimation)
#############################################
  
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Purpose

- Execute Stata do-file using Stata in batch mode. 
- This do-file will load and analyse the Stata dataset (survey_data) in data folder. 
- The task involves opening and saving a new do-file in the code folder. 

## File Paths

- Working directory: `C:\CLAUDE\Projects\Project11`
- Stata executable: `C:\Program Files\StataNow19\StataMP-64.exe`
- Do-files: `code\`
- Log files, tables, figures: `output\`
- Dataset: `data\survey_data.dta`
- Example code: `\examples\Examples.do`

## Running a Do-File

- Open Stata
- Create a new do-file 

## Do-File Template

- Follow this structure in writing the do-file: 
- Open a log file at the top (using `replace`).
- Set the working directory.
- Load the "survey_data.dta" dataset.
- Confirm survey design variables exist in the dataset before proceeding. If not sure, stop and check with the user rather than guessing a variable name.
- Set negative values on all variables to missing using `mvdecode`.
- Use the `svyset` command using the survey/sampling weight, primary sampling unit (PSU) and strata variables. 
- Estimate survey statistics for the outcome variables using complex survey commands (e.g. `svy:mean`). If requested perform estimation for different groups using the `over` option. If requested perform domain estimation using the `subpop` option.
- Publish output using the `etable` or `dtable` commands. Use the `export` option to save output in a text file (results.txt). 
- When analyzing a subsample of the survey (e.g., only participants who attended a nurse visit or provided a blood sample), confirm that the correct weight variable is used for that subsample. Use `wt_nurse` for analyses restricted to the nurse visit subsample and `wt_blood` for analyses restricted to the blood sample subsample.
- Include all the commands in a single do-file (results.do). 
- Capture date and time, display them, then close the log file.

### Running and Saving the do-file in batch mode

- Run the do-file from within Stata
- Save the do-file in the code folder 

### Executing via command line

To run the do-file in batch mode, launch Stata with the `/e` flag from **PowerShell**, not the Bash tool. Git Bash rewrites leading-slash arguments like `/e` into filesystem paths, which silently breaks the flag — Stata then opens an idle interactive window instead of executing the do-file, and no log is produced.

Use `Start-Process` with `-Wait` so the call blocks until Stata exits and the log file is finalized:

```powershell
Start-Process -FilePath "C:\Program Files\StataNow19\StataMP-64.exe" -ArgumentList '/e do "C:\CLAUDE\Projects\Project11\code\Do_File_Name.do"' -Wait
```

After it returns, verify the expected `.log` file exists in `output\` before reporting the task as complete.

## Conventions

- Log file naming: `Do_File_Name.log` 
- Save do-files to `code\`, save log files to `output\`

## Examples 

- See ".\examples\Examples.do" for examples of work-flow.

## Settings

- Create a `.claude\settings.json` (project-level) that allows Claude to Read/Write/Edit any file under `C:\CLAUDE\Projects\Project11`

## Stata Skills

Comprehensive Stata reference files are stored locally at:

- [.claude/skills/stata/SKILL.md](.claude/skills/stata/SKILL.md) — Stata syntax, data management, econometrics, causal inference, graphics, Mata, and 20+ community packages (`reghdfe`, `estout`, `did`, `rdrobust`, etc.)
- [.claude/skills/stata-c-plugins/SKILL.md](.claude/skills/stata-c-plugins/SKILL.md) — C/C++ plugin development for Stata

When writing, debugging, or explaining Stata code, read the relevant SKILL.md first. Each file contains a routing table — follow it to load only the 1–3 reference files needed for the task. Reference files live alongside the SKILL.md in `references/` and `packages/` subdirectories.

# Stata Skills for this specific repository

- [.claude/skills/stata-survey-setup/SKILL.md]  - syntax to set up the survey dataset using `svyset`
- [.claude/skills/stata-survey-estimation/SKILL.md] - syntax for performing survey estimation 
- [.claude/skills/stata-survey-results/SKILL.md] - syntax for outputting the results of survey estimation 

## References

For additional background/reference material on survey estimation consult 
[.claude/skills/stata-survey-estimation/references/references.md]. Use as an optional resource.

## Git and GitHub

Remote: `https://github.com/shauns11/Claude---Project11.git` (branch `main`). The GitHub CLI (`gh`) is not installed, so use plain `git` and the GitHub website.

### First-time setup (new project)

1. Create `.gitignore` in the project root **before** the first commit, so ignored files are never committed:

```text
# Secondary logs created by batch mode (/e) in the project root
/*.log

# Stata datasets (anywhere in the project)
*.dta

# R datasets (anywhere in the project)
*.rds

# Claude Code local settings
.claude/settings.json
```

2. Initialise the repository, check what will and won't be committed, then commit:

```powershell
git init -b main
git add .
git status --short             # files to be committed
git status --short --ignored   # lines starting "!!" are ignored (e.g. 01.log)
git commit -m "Initial commit"
```

3. Create an **empty** repository on github.com (no README, .gitignore or licence) and choose Public or Private.
4. Before pushing, confirm the remote exists and is empty. `git ls-remote` returns nothing for an empty repo and "Repository not found" if the URL is wrong, deleted or private without access:

```powershell
git ls-remote https://github.com/shauns11/Claude---Project11.git
```

5. Add the remote and push `main`:

```powershell
git remote add origin https://github.com/shauns11/Claude---Project11.git
git push -u origin main
git status -sb                 # should show: ## main...origin/main
```

6. Update the `Remote:` line at the top of this section.

Notes:
- Never use `git push --force` against a repository that already has history unless you intend to permanently replace it.
- Warnings like "LF will be replaced by CRLF" are Windows line-ending notices and can be ignored.

### Day-to-day

```powershell
git status                 # see what changed
git add .                  # stage changes
git commit -m "Message"    # commit
git push                   # upload to GitHub
```

### What is tracked

- Tracked: `code\` (Stata do-files), `output\` (logs, tables, figures), `examples\` (Examples.do), `CLAUDE.md`, `.gitignore`
- Ignored (see `.gitignore`):
  - `/*.log` — root-level logs created by batch mode
  - `*.dta` — Stata datasets, anywhere in the project
  - `*.rds` — R datasets, anywhere in the project
  - `.claude/settings.json` — Claude Code local permission settings (kept on disk, not uploaded)

  To save future changes, run git add ., then git commit -m "message", then git push.


## Additions to CLAUDE.md

Please add any settings necessary to complete this task to the CLAUDE.md file so that claude can create/edit files and perform common filesystem operations such as creating directories without repeatedly asking you. Please add steps necessary to perform task in the CLAUDE.file

### Settings in place

`.claude/settings.json` allows, without prompting: Read/Write/Edit on any file under `C:\CLAUDE\Projects\Project11\**`; Bash `mkdir`, `ls`, `cat`; PowerShell `Get-ChildItem`, `New-Item`, `Start-Process` (needed to run Stata in batch mode).

### Steps to perform a survey estimation task

1. Read `examples\Examples.do` and the three `stata-survey-*` skills.
2. Pick the weight for the analytic subsample: `wt_int` (interview), `wt_nurse` (nurse-visit measures such as `omsysval`, `omdiaval`), `wt_blood` (blood sample). PSU = `psu`, strata = `strata`. Ask the user if a variable's role is unclear.
3. Write `code\results.do` following the template (log → cd → use → `describe` checks → `mvdecode _all, mv(-9/-1)` → weight checks → `svyset` → `svy:` estimation with `over()`/`subpop()` → `etable`/`dtable` export to `output\results.txt` → date/time → `log close`).
4. Run it from PowerShell with `Start-Process ... '/e do "...\code\results.do"' -Wait`.
5. Check `output\results.log` exists and has no `r(...)` errors, then read `output\results.txt`.
6. Batch mode also writes a copy `results.log` in the project root; it is ignored by `.gitignore` (`/*.log`).












