-- Fixes for the 2022 catalog on top of the base DB's rooms and icons. Run after catalog_2022_merge.sql,
-- then :update_catalog in-game.

-- Room bundle pages point at the 2022 template room ids; the base DB has the templates at 50-56.
UPDATE catalog_pages SET room_id = 52 WHERE id = 5000; -- Piglet's Habitat
UPDATE catalog_pages SET room_id = 53 WHERE id = 5001; -- Polar Bear's Habitat
UPDATE catalog_pages SET room_id = 54 WHERE id = 5002; -- Kitten's Habitat (room is "Cat's Habitat Bundle")
UPDATE catalog_pages SET room_id = 55 WHERE id = 5003; -- Puppy's Habitat
UPDATE catalog_pages SET room_id = 56 WHERE id = 5004; -- Terrier's Habitat
-- Abandoned Hut / Easter Treehouse templates (rooms 60, 61) don't exist here
UPDATE catalog_pages SET visible = '0' WHERE id IN (5010, 5011);

-- Page icons that exist neither in the SWF pack nor in Habbo's current catalogue icons:
-- use the parent's icon when that one exists, else a generic one.
UPDATE catalog_pages p LEFT JOIN catalog_pages pp ON pp.id = p.parent_id
SET p.icon_image = IF(pp.icon_image IS NOT NULL AND pp.icon_image NOT IN (500, 501, 502, 503, 504, 505, 506, 507, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009), pp.icon_image, 1)
WHERE p.icon_image IN (500, 501, 502, 503, 504, 505, 506, 507, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
