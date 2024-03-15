#!/bin/sh

page=0

while :; do
  let "page++"
  data=$(curl -s "https://wallhaven.cc/api/v1/collections/TheMightyApophis/$1?apikey=$WALLHAVEN_API_KEY&page=$page")
  last_page=$(echo $data | jq .meta.last_page)

  for url in $(echo $data | jq -r '.data[] | .path')
  do
    if [[ -f $(basename "$url") ]]; then
      echo "$url already exists. Skipping..."
    else
      echo "Downloading $url"
      curl -O $url -s
    fi
  done

  if [[ $page == $last_page ]]; then
    break 
  fi
done
