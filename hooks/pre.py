"""Pre-hook: runs before the Claude invocation.

sys.argv[1] contains the prompt.
"""

import sys


def main() -> None:
    prompt = sys.argv[1]


if __name__ == "__main__":
    main()
