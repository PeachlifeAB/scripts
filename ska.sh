#!/bin/bash
cwd="$(pwd)"
cd "$SKILLS_PATH" || exit 1
cd ../..
bunx skills find
cd "$SKILLS_PATH" || exit 1
yazi
cd "$cwd" || exit 1
