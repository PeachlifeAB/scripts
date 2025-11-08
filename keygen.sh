#!/usr/bin/env bash
# keygen.sh - Generate a random API key
# Usage: ./keygen.sh [length]
# Default length: 32 (hex chars = 16 bytes)

LENGTH="${1:-32}"
openssl rand -hex "$LENGTH"
