#!/usr/bin/env bash

MINIFLUX_FEED_URL="https://feeds.heywoodlh.io/v1/categories/2/feeds"

directory=$(dirname -- "$( readlink -f -- "$0"; )";)
file="${directory}/reading-list.md"

echo '---' > ${file}
printf 'layout: page\ntitle: Reading List\npermalink: /reading-list/\n' >> ${file}
echo '---' >> ${file}
printf '\nMy tech reading list generated weekly.\n' >> ${file}
printf 'I use [Miniflux](https://miniflux.app/) to aggregate my feeds in combination with [Reeder5](https://www.reederapp.com/) on mobile.\n' >> ${file}
printf "\nGenerated on $(date +%D)\n\n" >> ${file}

curl --silent -H "X-Auth-Token: ${MINIFLUX_API_TOKEN}" "${MINIFLUX_FEED_URL}" | jq -r '.[] | "---\nTitle: " + .title,"\nURL: " + .site_url,"\nRSS: " + .feed_url + "\n"' | grep -v '.tailscale' >> ${file}