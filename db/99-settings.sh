# Sourced by the mysql entrypoint on first init (not executable on purpose, so docker_process_sql is available).
docker_process_sql --database="$MYSQL_DATABASE" <<SQL
REPLACE INTO emulator_settings (\`key\`, \`value\`) VALUES
    ('websockets.whitelist', '${GAME_DOMAIN}'),
    ('ws.nitro.ip.header', '${WS_IP_HEADER}'),
    ('console.mode', '0'),
    -- word filter is English-centric and mangles Spanish (e.g. "como")
    ('hotel.wordfilter.enabled', '0'),
    ('hotel.wordfilter.rooms', '0'),
    ('hotel.wordfilter.messenger', '0'),
    ('hotel.wordfilter.automute', '0'),
    ('camera.url', 'https://${ASSETS_DOMAIN}/usercontent/camera/'),
    ('imager.location.output.camera', '/app/assets/usercontent/camera/'),
    ('imager.location.output.thumbnail', '/app/assets/usercontent/camera/thumbnail/'),
    ('imager.url.youtube', 'https://${ASSETS_DOMAIN}/api/imageproxy/0x0/http://img.youtube.com/vi/%video%/default.jpg'),
    ('imager.location.output.badges', '/app/assets/usercontent/badgeparts/generated/'),
    ('imager.location.badgeparts', '/app/assets/swf/c_images/Badgeparts');
SQL
