#!/bin/sh
# One-shot: download default SWF pack + Nitro assets into the shared volume and convert figures/effects/pets/furniture.
# Needs the `assets` nginx service up, since configuration.json fetches SWFs from http://assets/.
set -eu
cd /data
mkdir -p usercontent/avatar usercontent/camera/thumbnail usercontent/badgeparts/generated

if [ -f .initialized ]; then
    echo "assets already initialized, delete /data/.initialized to redo"
    exit 0
fi

rm -rf swf assets
git clone --depth 1 https://git.mc8051.de/nitro/arcturus-morningstar-default-swf-pack.git swf
git clone --depth 1 https://git.mc8051.de/nitro/default-assets.git assets
wget -qO /tmp/room.nitro.zip https://git.mc8051.de/attachments/e948e603-d0ea-4948-b313-e8290a1c4bc9
unzip -o /tmp/room.nitro.zip -d assets/bundled/generic
rm -rf swf/.git assets/.git /tmp/room.nitro.zip
# the client looks for furni icons next to the SWFs, the pack ships them in icons/
cp -n swf/dcr/hof_furni/icons/* swf/dcr/hof_furni/

ln -sfn /data/assets /app/assets
cd /app && node dist/Main.js

# the converter logs its errors and still exits 0
if [ ! -f /data/assets/gamedata/FigureData.json ] || [ -z "$(ls /data/assets/bundled/figure 2>/dev/null)" ]; then
    echo "conversion failed, see errors above" >&2
    exit 1
fi

touch /data/.initialized
echo "assets initialized"
