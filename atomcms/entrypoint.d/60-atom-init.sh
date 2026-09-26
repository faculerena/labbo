#!/bin/sh
# First boot: create AtomCMS tables. Every boot: point its settings at the current assets domain.
set -eu
cd /var/www/html

marker=/var/www/html/storage/app/public/.atom-seeded
if [ ! -f "$marker" ]; then
    php artisan migrate --seed --force
    touch "$marker"
fi

php <<'PHP'
<?php
$db = new PDO(
    'mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT') . ';dbname=' . getenv('DB_DATABASE'),
    getenv('DB_USERNAME'),
    getenv('DB_PASSWORD'),
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION],
);
$assets = 'https://' . getenv('ASSETS_DOMAIN');
$settings = [
    // the /game/nitro page iframes this, not NITRO_CLIENT_PATH
    'nitro_path' => 'https://' . getenv('GAME_DOMAIN'),
    'avatar_imager' => "$assets/api/imager/?figure=",
    'badges_path' => "$assets/swf/c_images/album1584",
    'group_badge_path' => "$assets/usercontent/badgeparts/generated",
    'furniture_icons_path' => "$assets/swf/dcr/hof_furni",
    'housekeeping_url' => '/housekeeping',
    'rcon_ip' => 'arcturus',
    'rcon_port' => '3001',
    'min_staff_rank' => '4',
    'min_maintenance_login_rank' => '5',
    'min_housekeeping_rank' => '6',
    'cloudflare_turnstile_enabled' => '0',
];
$update = $db->prepare('UPDATE website_settings SET value = ? WHERE `key` = ?');
foreach ($settings as $key => $value) {
    $update->execute([$value, $key]);
}
echo "AtomCMS settings applied\n";
PHP
