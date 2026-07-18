#!/usr/bin/env python3
"""Run c_formatter_42 with the native clang-format found in PATH."""

from pathlib import Path
import shutil
import sys


def fail(message: str) -> None:
    print(f"c_formatter_42: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    clang_format = shutil.which("clang-format")
    if clang_format is None:
        fail("clang-format was not found in PATH")

    try:
        import c_formatter_42.formatters.clang_format as formatter
        from c_formatter_42.run import run_all
    except ImportError:
        fail("the c_formatter_42 Python package is not installed")

    formatter.CLANG_FORMAT_EXEC = Path(clang_format)
    source = sys.stdin.read()
    try:
        formatted = run_all(source)
    except Exception as error:
        fail(str(error))
    sys.stdout.write(formatted)


if __name__ == "__main__":
    main()
