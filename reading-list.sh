#!/usr/bin/env bash

CATEGORY="2"
MINIFLUX_FEED_URL="https://feeds.heywoodlh.io/v1/categories/${CATEGORY}/feeds"

directory=$(dirname -- "$( readlink -f -- "$0"; )";)
file="${directory}/reading-list.md"

echo '---' > ${file}
printf 'layout: page\ntitle: Reading List\npermalink: /reading-list/\n' >> ${file}
echo '---' >> ${file}
printf '\nMy tech reading list generated weekly via [reading-list.yml](https://github.com/heywoodlh/heywoodlh.io/blob/main/.github/workflows/reading-list.yml).\n' >> ${file}
printf "\n<div class="date">\nGenerated on $(date +%D)\n</div>\n" >> ${file}

curl --silent -H "X-Auth-Token: ${MINIFLUX_API_TOKEN}" "${MINIFLUX_FEED_URL}" | jq -r '.[] | "---\nTitle: " + .title,"\nURL: <" + .site_url + ">","\nRSS: <" + .feed_url + ">\n"' | grep -vE '.tailscale|ts\.net|rsshub' >> ${file}
