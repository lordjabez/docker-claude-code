"""Post-hook: runs after the Claude invocation.

sys.argv[1] contains the full JSON input object.
sys.argv[2] contains Claude's response.
"""

import json
import sys


def main() -> None:
    input_data = json.loads(sys.argv[1])
    response = sys.argv[2]


if __name__ == "__main__":
    main()
