#!/usr/bin/env bash
# fdcount - count files matching pattern
# Usage: fdcount [fd-args]

fd "$@" | wc -l
