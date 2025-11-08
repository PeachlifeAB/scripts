#!/usr/bin/env python3
"""
JSON Scrubber: Shifts all string values while preserving type, length, and separators.
Replaces: letters -> next letter (a->b, z->a), digits -> next digit (0->1, 9->0)
Preserves: non-alphanumeric characters (-, _, ., etc.)

Usage:
    ./scrub.sh file.json
    cat file.json | ./scrub.sh
"""

import json
import sys


def scrub_string(s):
    """Shift each character: letters rotate through alphabet, digits rotate 0-9"""
    result = []
    for char in s:
        if char.isalpha():
            if char.islower():
                # Rotate lowercase: a->b, z->a
                result.append(chr((ord(char) - ord("a") + 1) % 26 + ord("a")))
            else:
                # Rotate uppercase: A->B, Z->A
                result.append(chr((ord(char) - ord("A") + 1) % 26 + ord("A")))
        elif char.isdigit():
            # Rotate digits: 0->1, 9->0
            result.append(str((int(char) + 1) % 10))
        else:
            # Preserve separators, special characters
            result.append(char)
    return "".join(result)


def scrub_json(obj):
    """Recursively scrub all string values in JSON object/array"""
    if isinstance(obj, dict):
        return {k: scrub_json(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [scrub_json(item) for item in obj]
    elif isinstance(obj, str):
        return scrub_string(obj)
    else:
        # Numbers, booleans, null - preserve as-is
        return obj


def main():
    # Read from file, argument, or stdin
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        # Strip leading/trailing whitespace to check if it's JSON
        arg_stripped = arg.lstrip()

        # Check if it's JSON (starts with { or [)
        if arg_stripped.startswith("{") or arg_stripped.startswith("["):
            # It's JSON
            data = json.loads(arg_stripped)
        else:
            # Try as file first
            try:
                with open(arg, "r") as f:
                    data = json.load(f)
            except (FileNotFoundError, OSError):
                # Maybe it's JSON without leading brace?
                try:
                    data = json.loads(arg_stripped)
                except json.JSONDecodeError:
                    print(
                        f"Error: '{arg[:50]}...' is not a valid file or JSON",
                        file=sys.stderr,
                    )
                    sys.exit(1)
    else:
        data = json.load(sys.stdin)

    # Scrub and output
    scrubbed = scrub_json(data)
    json.dump(scrubbed, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
