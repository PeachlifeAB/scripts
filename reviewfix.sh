#!/bin/bash
read -p "[A]ppend or [W]rite new review.md? " choice
choice="${choice:-w}"

if [[ "$choice" == "a" || "$choice" == "A" ]]; then
    coderabbit review --plain >> review.md
else
    coderabbit review --plain > review.md
fi

taskr review.md
