import os
import random
import re
import subprocess
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <dir containing images>")
    sys.exit(1)

workdir = sys.argv[1]

result = subprocess.run(["swww", "query"], capture_output=True, text=True, check=True)
lines = result.stdout.splitlines()

for line in lines:
    #: DP-1: 3440x1440, scale: 1, currently displaying: color: 000000
    #: HDMI-A-1: 1440x2560, scale: 1, currently displaying: color: 000000
    match = re.search(r":([^:]+):\s*(\d+)x(\d+)", line)
    if not match:
        print(f"Error: could not parse resolution from line: '{line}'", file=sys.stderr)
        sys.exit(1)

    name = match.group(1).strip()
    w = int(match.group(2))
    h = int(match.group(3))

    directory = os.path.join(workdir, f"{w}x{h}")
    files = [
        f for f in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, f))
    ]

    if not files:
        print(f"Warning: no wallpapers found for resolution {w}x{h}", file=sys.stderr)
        continue

    choice = random.choice(files)
    full_path = os.path.join(directory, choice)

    subprocess.run(["swww", "img", "--outputs", name, full_path], check=True)
