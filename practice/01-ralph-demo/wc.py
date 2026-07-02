#!/usr/bin/env python3
"""CLI word counter — counts lines, words, and characters in a file."""

import sys

def count(text: str) -> tuple[int, int, int]:
    lines = text.count("\n")
    words = len(text.split())
    chars = len(text)
    return lines, words, chars

def format_table(filename: str, lines: int, words: int, chars: int) -> str:
    col_w = max(len(str(v)) for v in (lines, words, chars, "Lines", "Words", "Chars"))
    sep = "+" + "-" * (col_w + 2) + "+" + "-" * (col_w + 2) + "+"
    row = lambda label, val: f"| {label:<{col_w}} | {val:>{col_w}} |"
    return "\n".join([
        f"File: {filename}",
        sep,
        row("Lines", lines),
        row("Words", words),
        row("Chars", chars),
        sep,
    ])

def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: wc.py <filename>", file=sys.stderr)
        return 1
    filename = sys.argv[1]
    try:
        with open(filename) as f:
            text = f.read()
    except FileNotFoundError:
        print(f"Error: file not found: {filename}", file=sys.stderr)
        return 1
    lines, words, chars = count(text)
    print(format_table(filename, lines, words, chars))
    return 0

if __name__ == "__main__":
    sys.exit(main())
