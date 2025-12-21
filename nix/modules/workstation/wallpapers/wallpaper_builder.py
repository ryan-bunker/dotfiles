import os
import sys
import shutil
from PIL import Image


def matches_ratio(w, h, target_w, target_h, tolerance):
    current_ratio = w / h
    target_ratio = target_w / target_h

    # Check if the difference is negligible
    return abs(current_ratio - target_ratio) < tolerance


def get_matching_ratio(w, h, targets, tolerance):
    for target_w, target_h in targets:
        if matches_ratio(w, h, target_w, target_h, tolerance):
            return (target_w, target_h)
    return None


# Arguments passed from the runCommand below
src_dir = sys.argv[1]
out_dir = sys.argv[2]
# Parse space-separated list of targets: "1920x1080 2560x1440"
target_resolutions = [tuple(map(int, res.split("x"))) for res in sys.argv[3].split()]

print(f"Processing wallpapers for targets: {target_resolutions}")

# Create directories for each target
for res_w, res_h in target_resolutions:
    os.makedirs(os.path.join(out_dir, f"{res_w}x{res_h}"), exist_ok=True)

for filename in os.listdir(src_dir):
    filepath = os.path.join(src_dir, filename)
    if not os.path.isfile(filepath):
        continue
    if not filename.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
        continue

    try:
        with Image.open(filepath) as img:
            w, h = img.size
            print(f"*** Processing {filename}: resolution {w}x{h} (ratio {w / h})")

            target = get_matching_ratio(w, h, target_resolutions, 0.06)
            if target is None:
                print(f"Skipping {filename}: does not match any target resolutions")
                continue

            res_string = f"{target[0]}x{target[1]}"
            target_path = os.path.join(out_dir, res_string, filename)
            shutil.copy(filepath, target_path)

    except Exception as e:
        print(f"Skipping {filename}: {e}")
