#!/usr/bin/env python3

import sys
import json
import ast

# Read input from stdin
data = sys.stdin.read().strip()

# Remove outer quotes if present
data = data.strip('"')

# Parse Python dict string and convert to JSON
try:
    parsed_data = ast.literal_eval(data)
    json_output = json.dumps(parsed_data)
    print(json_output)
except (SyntaxError, ValueError) as e:
    print(f"Error parsing input: {e}", file=sys.stderr)
    sys.exit(1)
