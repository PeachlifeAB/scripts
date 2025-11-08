#!/bin/zsh
opencode "$@"
# oc - Open opencode with pattern-driven agent in current directory
# Usage: oc [OPTIONS]

# set -euo pipefail
#
# show_help() {
#     cat <<EOF
# oc - Open opencode with pattern-driven agent
#
# Usage: oc [OPTIONS]
#
# Options:
#     -h, --help              Show this help message
#     -n, --new               Start a new session (do not use --continue)
#     -s, --session NAME      Start/continue a specific session instead of default continue behavior
#
# Examples:
#     oc                      Continue the most recent session (default)
#     oc --new                Start a new session
#     oc --session feature    Start/continue session named "feature"
#     oc -s bugfix            Start/continue session named "bugfix"
#
# EOF
#     exit 0
# }
#
# session_name=""
# start_new="false"
#
# while [[ $# -gt 0 ]]; do
#     case $1 in
#     -h | --help)
#         show_help
#         ;;
#     -n | --new)
#         start_new="true"
#         shift
#         ;;
#     -s | --session)
#         if [[ -n "${2:-}" ]]; then
#             session_name="$2"
#             shift 2
#         else
#             echo "Error: --session requires a session name argument"
#             exit 1
#         fi
#         ;;
#     *)
#         echo "Error: Unknown option: $1"
#         echo "Run 'oc --help' for usage information"
#         exit 1
#         ;;
#     esac
# done
#
# if [[ "$start_new" == "true" && -n "$session_name" ]]; then
#     echo "Error: --new cannot be used with --session"
#     exit 1
# fi
#
# # Ensure git repo exists with at least one commit to avoid "global" sessions
# if [ -d .git ]; then
#     if ! git rev-parse HEAD >/dev/null 2>&1; then
#         echo "# $(basename "$PWD")" >README.md
#         git add README.md
#         git commit -m "chore: initial commit" --quiet
#     fi
# elif [ ! -f .git ]; then
#     git init --quiet
#     echo "# $(basename "$PWD")" >README.md
#     git add README.md
#     git commit -m "chore: initial commit" --quiet
# fi
#
# original_shell="$SHELL"
# export SHELL="/bin/bash"
#
# if [[ -n "$session_name" ]]; then
#     opencode --agent pattern-driven --session "$session_name"
# elif [[ "$start_new" == "true" ]]; then
#     opencode --agent pattern-driven
# else
#     opencode --agent pattern-driven --continue
# fi
#
# export SHELL="$original_shell"
