#!/bin/sh

# set -x

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
  echo "Usage:
  $0 <dir containing images>"
  exit 1
fi

workdir=$1
shift

export SWWW_TRANSITION=fade
export SWWW_TRANSITION_DURATION=3
export SWWW_TRANSITION_FPS=60

while IFS= read -r output; do
  read -r output_name width height <<< "$output"
  image=$(find "$workdir/${width}x${height}" | shuf -n 1)

  swww img --outputs "$output_name" $@ "$image"

done <<< $(swww query | awk -F, '{
  split($1, output_resolution, ":")
  split(output_resolution[2], resolution, "x")
  split($2, scale, ":")

  print output_resolution[1], resolution[1] * scale[2], resolution[2] * scale[2]
}')

