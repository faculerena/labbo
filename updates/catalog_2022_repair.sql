-- Repair upstream catalog_2022.sql's offer names. Run after catalog_2022_merge.sql.
-- In ~650 offers catalog_name is the classname of some *other* furni while item_ids point at the right
-- one for the page (e.g. "guitar_v" on 2011 Rares giving dng_throne), so the shop titled/searched them
-- as one furni and showed/gave another. Checked against page furnilines: the item side is the correct one.
-- Code-style names ("A1 HYN", "poster 42", "DEV window_basic", wallpaper/floor/landscape) are left alone.

UPDATE catalog_items c
JOIN items_base b ON b.id = c.item_ids
JOIN (SELECT DISTINCT item_name FROM items_base) n ON n.item_name = c.catalog_name
SET c.catalog_name = b.item_name
WHERE c.item_ids REGEXP '^[0-9]+$' AND c.catalog_name <> b.item_name;

-- Offers whose item doesn't exist can't be bought; hide them by moving them off every page.
UPDATE catalog_items c
LEFT JOIN items_base b ON b.id = c.item_ids
SET c.page_id = -1
WHERE c.item_ids REGEXP '^[0-9]+$' AND b.id IS NULL;
