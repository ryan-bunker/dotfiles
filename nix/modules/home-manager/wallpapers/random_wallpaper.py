import os
import random
import subprocess
import sys
import json

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <dir containing images>")
    sys.exit(1)

workdir = sys.argv[1]

# Run hyprctl monitors in JSON mode for reliable parsing
try:
    result = subprocess.run(
        ["hyprctl", "monitors", "-j"],
        capture_output=True,
        text=True,
        check=True
    )
except subprocess.CalledProcessError as e:
    print(f"Error running hyprctl: {e}", file=sys.stderr)
    sys.exit(1)

try:
    monitors = json.loads(result.stdout)
except json.JSONDecodeError:
    print("Error parsing hyprctl output JSON", file=sys.stderr)
    sys.exit(1)

for monitor in monitors:
    name = monitor["name"]

    # hyprctl reports the native pixel resolution of the mode
    w = monitor["width"]
    h = monitor["height"]

    # Check rotation (transform).
    # 0=Normal, 1=90deg, 2=180deg, 3=270deg, etc.
    # If rotated 90 or 270, swap width and height to match visual orientation
    transform = monitor.get("transform", 0)
    if transform in [1, 3, 5, 7]:
        w, h = h, w

    directory = os.path.join(workdir, f"{w}x{h}")

    if not os.path.isdir(directory):
        print(f"Warning: directory not found for resolution {w}x{h} (Monitor: {name})", file=sys.stderr)
        continue

    files = [
        f for f in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, f))
    ]

    if not files:
        print(f"Warning: no wallpapers found in {directory}", file=sys.stderr)
        continue

    choice = random.choice(files)
    full_path = os.path.join(directory, choice)

    print(f"Setting {name} to {choice} ({w}x{h})")
    subprocess.run(["awww", "img", "--outputs", name, full_path], check=True)
