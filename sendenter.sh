#!/usr/bin/env bash

usage() {
    printf '%s\n' \
        "Usage: sendenter -t|--target <pane_id> -m|--minutes <minutes> [-r|--repeat <count>]" \
        "" \
        "Required:" \
        "  -t, --target   Pane id (with or without %)" \
        "  -m, --minutes  Minutes between sends" \
        "" \
        "Optional:" \
        "  -r, --repeat   Number of times (default: 1)" \
        "  -h, --help     Show this help"
}

repeat=1
while [ $# -gt 0 ]; do
    case "$1" in
    -t | --target)
        target="$2"
        shift 2
        ;;
    -m | --minutes)
        minutes="$2"
        shift 2
        ;;
    -r | --repeat)
        repeat="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done

[ -n "$target" ] && [ -n "$minutes" ] || {
    usage
    exit 1
}

target="${target#%}"
i=0
while [ "$i" -lt "$repeat" ]; do
    sleep "$((minutes * 60))"
    tmux send-keys -t "%$target" C-m
    i=$((i + 1))
done
