-- Free-for-all hotel: every rank gets infinite credits/duckets/diamonds (purchases cost nothing)
-- and the floor plan editor (own rooms only), and the catalog has no HC or rank locks. Runs on first DB init; safe to re-run on an existing DB:
--   mysql -uarcturus -p"$MYSQL_PASSWORD" arcturus < /docker-entrypoint-initdb.d/07-free-hotel.sql
-- then type :update_permissions and :update_catalog in-game (or restart arcturus).

UPDATE permission_group_rights SET setting_type = '1'
WHERE right_name IN ('acc_infinite_credits', 'acc_infinite_pixels', 'acc_infinite_points', 'acc_floorplan_editor');

UPDATE catalog_pages SET club_only = '0', min_rank = 1;
UPDATE catalog_items SET club_only = '0';
