#!/bin/sh
# Render Nitro configs from env. Explicit var list keeps Nitro's own ${asset.url}-style placeholders intact.
set -eu
for f in renderer-config ui-config; do
    envsubst '${SOCKET_URL} ${ASSETS_URL} ${CMS_URL}' < "/etc/nitro/$f.json" > "/usr/share/nginx/html/$f.json"
done
