"""Post-hook: runs after the Claude invocation.

sys.argv[1] contains the prompt.
sys.argv[2] contains Claude's response.
"""

import sys


def main() -> None:
    prompt = sys.argv[1]
    response = sys.argv[2]


if __name__ == "__main__":
    main()
