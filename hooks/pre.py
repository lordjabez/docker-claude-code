"""Pre-hook: runs before the Claude invocation.

sys.argv[1] contains the full JSON input object.
"""

import json
import sys


def main() -> None:
    input_data = json.loads(sys.argv[1])


if __name__ == "__main__":
    main()
