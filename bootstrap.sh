#!/bin/bash

if [ -f "CLAUDE.md" ] || [ -f "AGENTS.md" ]; then
    echo "CLAUDE.md or AGENTS.md already exists."
    read -p "Continue anyway? [Y/n] " answer
    answer=${answer:-Y}
    if [[ "$answer" =~ ^[Nn]$ ]]; then
        echo "Exiting."
        exit 1
    fi
fi

curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md

cat >>CLAUDE.md <<'EOF'

# Recommended skills

No hard requirement but you are recommended to use these base skills along domain specific skills.

- `llm-wiki`: Knowledge base for this project
- `gh-cli`: How to use gh to clone references
- `lint-and-validate`
- `log`
- `systematic-development`: Good set of default project hygiene and work methods.
- `gstack`: Good set of default project hygiene and work methods.
- `using-superpowers`: Good set of default project hygiene and work methods.

# Folders

Follow this structure always unless it collides with
framework or language culture.

- `logs`: log/<action/process>/<date time>.log
- `docs`: docs/<domain>
- `plans`: docs/plans/<date>/
- `project-wiki`: use `llm-wiki` skill.
- `scripts`: non temporary scripts.
- `src`: source code for project
- `tests/unit/`: unit test code
- `tests/smoke/`: smoke tests.
- `temporary scripts and documents`: `/tmp/<project name>/
- `references`: Use gh or git clone to clone - reference code into this folder. Except for adding cloned code, treat it as read only and project related knowledge about dependencies and similar projects.

# Files

Hihly recommended base set of files for most projects.
All of these files must store logs into log/

- `repo-state.sh`: If a baseline check will matter again across sessions, scripts, or validations, promote it into the repo-state script.
- `run.sh`: build and run default project binary.
- `lint.sh`: lint / autofix issues in project.
- `test.sh`: run all tests.
- `.env`: environment variables for project. Don't put secrets here, but you can put references to secrets or non secret environment variables here.

# Project specific instructions

EOF

ln -s CLAUDE.md AGENTS.md
