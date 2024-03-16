#!/bin/sh

# set -x

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
  echo "Usage:
  $0 <dir containing images>"
  exit 1
fi

workdir=$1
shift

# export TRANSITION_TYPE=any
# export SWWW_TRANSITION_FPS=60
# export SWWW_TRANSITION_STEP=2

most_recent=$(find "$workdir" -type f -iregex '.*\.\(png\|gif\|jpg\|jpeg\)\|.*/feh_cache.txt' -printf '%T+ %p\n' | sort -r | head -n1 | awk '{print $2}')
if [[ $(basename "$most_recent") != "feh_cache.txt" ]]; then
  # at least one image is newer than our cache file so we need to update it
  feh -l "$(realpath "$workdir")" 2> /dev/null | tail -n +2 > "$workdir/feh_cache.txt"
fi
all_images=$(cat "$workdir/feh_cache.txt")

while IFS= read -r output; do
  read -r output_name width height <<< "$output"
  image=$(echo "$all_images" | awk "(\$3 / \$4) == ($width / $height) && \$3 >= $width { print \$8 }" | shuf -n 1)

  # echo "Set $output_name to $image"
  swww img --outputs "$output_name" \
    --transition-type fade \
    --transition-duration 3 \
    --transition-fps 60 \
    "$image"

done <<< $(swww query | awk -F, '{
  split($1, output_resolution, ":")
  split(output_resolution[2], resolution, "x")
  split($2, scale, ":")

  print output_resolution[1], resolution[1] * scale[2], resolution[2] * scale[2]
}')

