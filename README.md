# habbo-holo

A Habbo retro stack packaged for [Dokploy](https://dokploy.com): the Nitro HTML5 client, the Arcturus Morningstar (ms4) emulator, AtomCMS, and an asset server with the avatar imager.

It's adapted from [Gurkengewuerz/nitro-docker](https://github.com/Gurkengewuerz/nitro-docker) (MIT, see `LICENSE`). Upstream's manual HeidiSQL, asset download and config-editing steps are automated here, so deploying comes down to setting env vars, adding domains, and clicking deploy.

## What runs

| Service       | Role                                               | Dokploy domain              |
|---------------|----------------------------------------------------|-----------------------------|
| `cms`         | AtomCMS website, registration, housekeeping        | `CMS_DOMAIN` → port 8080    |
| `nitro`       | Nitro game client (static)                         | `GAME_DOMAIN` → port 80     |
| `assets`      | nginx serving SWFs, `.nitro` bundles, usercontent  | `ASSETS_DOMAIN` → port 80   |
| `arcturus`    | Game server, websocket                             | `WS_DOMAIN` → port 2096     |
| `db`          | MySQL 8, schema auto-imported on first start       | none                        |
| `backup`      | Daily DB dump into the `db-backup` volume          | none                        |
| `imager`      | Avatar image renderer (behind `assets/api/imager`) | none                        |
| `imgproxy`    | YouTube thumbnail proxy                            | none                        |
| `assets-init` | One-shot job that downloads and converts assets    | none                        |

What happens automatically on the first deploy:
- `db` imports the Arcturus base schema, the 3.0 → 4.0 updates, and the permission groups, then points the emulator settings (websocket whitelist, camera URLs, and so on) at your domains. See `db/Dockerfile` and `db/99-settings.sh`.
- `assets-init` clones the default SWF pack and the Nitro assets into the `assets` volume, then converts the figures, effects and pets. This is several GB and takes a while. Later deploys skip this step.
- `cms` runs `migrate --seed` on the first boot only. On every boot it re-applies the AtomCMS asset URLs and ranks from the env vars (`atomcms/entrypoint.d/60-atom-init.sh`).
- `nitro` renders `renderer-config.json` and `ui-config.json` from env vars every time it starts.

## Deploy on Dokploy

1. **DNS.** Create A records for all four domains, pointing at the server.
2. **Push this repo** to GitHub or GitLab (or any git remote Dokploy can reach).
3. In Dokploy, open a project, choose **Create Service → Compose**, and pick the **Docker Compose** type (not Stack). Point it at the repo and use `compose.yaml` as the compose path.
4. **Environment tab.** Paste `.env.example` and fill it in:
   ```sh
   openssl rand -hex 24                   # MYSQL_ROOT_PASSWORD, then run again for MYSQL_PASSWORD
   echo "base64:$(openssl rand -base64 32)"   # APP_KEY
   ```
5. **Domains tab.** Add the four domains from the table above, with HTTPS on and Let's Encrypt as the certificate provider. For `arcturus`, the port is **2096**. Traefik passes the websocket upgrade through on its own; the client connects to `wss://WS_DOMAIN`.
6. **Deploy.** The first build compiles Java, Node and PHP, and `assets-init` downloads GBs, so expect a long wait. Watch the logs:
   - `db`: wait for `ready for connections ... port: 3306`.
   - `assets-init`: it ends with `assets initialized` and then exits. That exit is expected.
   - `cms`: look for `AtomCMS initialized`.
7. Open `https://CMS_DOMAIN`, finish the AtomCMS setup screen, and register an account.
8. **Make yourself an admin.** Open `db` → Terminal in Dokploy and run:
   ```sh
   mysql -uarcturus -p"$MYSQL_PASSWORD" arcturus -e "UPDATE users SET \`rank\` = 7 WHERE username = 'YOURNAME';"
   ```
   The rank IDs come from `db/06-perms_groups.sql`: 4 is staff, 6 gets housekeeping, 7 is the top rank.

## Operating notes

- **Free hotel.** `db/07-free-hotel.sql` gives every rank infinite credits, duckets and diamonds, so purchases cost nothing, and removes the HC and rank locks from the catalog. It runs automatically on the first DB init. To apply it to an existing DB, run `mysql -uarcturus -p"$MYSQL_PASSWORD" arcturus < /docker-entrypoint-initdb.d/07-free-hotel.sql` in the `db` container, then restart `arcturus`.

- **Changing a domain later.** `nitro` and `cms` pick up new domains on redeploy. The emulator settings are only written on the first DB init, so after a domain change you also need to update the settings by hand:
  ```sql
  UPDATE emulator_settings SET value = 'new.game.domain' WHERE `key` = 'websockets.whitelist';
  -- also camera.url and imager.url.youtube
  ```
  After that, run `docker compose restart arcturus`, or restart the service from Dokploy.
- **Re-running the asset job.** Delete `/data/.initialized` from the `assets` volume, then redeploy.
- **Backups.** The `backup` service writes a gzipped dump into the `db-backup` volume when it starts and every 24 hours after that, and keeps 7 days of dumps. Copy those dumps off the server yourself, or set up Dokploy's volume backups to S3.
- **RCON** is bound to the emulator's localhost (same as upstream), so AtomCMS housekeeping actions that go through RCON (live alerts, kicks) won't work. Everything based on the DB works.
- **Upstream quirks patched here:**
  - Arcturus's `ms4/dev` branch was renamed to `archived/ms4/dev`, and upstream's Dockerfile no longer builds because of it.
  - Two upstream SQL files break under the `mysql` CLI: one has `--comment` lines without a space, the other a hardcoded `aurora` schema name. Both are fixed during the image build.
- **2022 catalog (applied by hand, not on fresh installs).** `db/updates/catalog_2022_merge.sql` copies upstream's `catalog_2022.sql` into the live tables; the SQL comments in that file describe the steps. It only makes sense together with the newer furni files: download current furni with `habbo-downloader` from a home connection (habbo.com blocks datacenter IPs), convert the ones missing on the server, upload them along with their icons, and add the new ids to `FurnitureData.json` without removing existing entries.
- **Translation scripts** from upstream are not included.

Habbo assets are © Sulake. Keep the hotel private or non-commercial.
