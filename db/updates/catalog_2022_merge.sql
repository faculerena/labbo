-- Replace the catalog with upstream's 2022 catalog (nitro-docker arcturus/catalog_2022.sql), keeping the
-- live ms4 schema. The 2022 items_base is a superset of the base one (same ids, same furni), so owned
-- items are unaffected. Run as root with catalog_2022.sql already loaded into a scratch schema `cat2022`:
--   mysql -uroot -p -e 'CREATE DATABASE cat2022' && mysql -uroot -p cat2022 < catalog_2022.sql
--   mysql -uroot -p arcturus < catalog_2022_merge.sql && mysql -uroot -p arcturus < 07-free-hotel.sql
--   mysql -uroot -p -e 'DROP DATABASE cat2022'
-- then restart arcturus.
-- - allow_* are enum('0','1') there and tinyint here: compare, don't copy (an enum copies as its index)
-- - page layouts ms4 doesn't know are hidden; VIP-only (club_only 2) becomes HC-only

SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

DELETE FROM `items_base`;
INSERT INTO `items_base` (`id`,`sprite_id`,`public_name`,`item_name`,`type`,`width`,`length`,`stack_height`,`allow_stack`,`allow_sit`,`allow_lay`,`allow_walk`,`allow_gift`,`allow_trade`,`allow_recycle`,`allow_marketplace_sell`,`allow_inventory_stack`,`interaction_type`,`interaction_modes_count`,`vending_ids`,`multiheight`,`customparams`,`effect_id_male`,`effect_id_female`,`clothing_on_walk`)
SELECT `id`,`sprite_id`,`public_name`,`item_name`,`type`,`width`,`length`,`stack_height`,(`allow_stack` = '1'),(`allow_sit` = '1'),(`allow_lay` = '1'),(`allow_walk` = '1'),(`allow_gift` = '1'),(`allow_trade` = '1'),(`allow_recycle` = '1'),(`allow_marketplace_sell` = '1'),(`allow_inventory_stack` = '1'),`interaction_type`,`interaction_modes_count`,`vending_ids`,`multiheight`,`customparams`,`effect_id_male`,`effect_id_female`,`clothing_on_walk` FROM cat2022.`items_base`;

DELETE FROM `catalog_pages`;
INSERT INTO `catalog_pages` (`id`,`parent_id`,`caption_save`,`caption`,`page_layout`,`icon_color`,`icon_image`,`min_rank`,`order_num`,`visible`,`enabled`,`club_only`,`vip_only`,`page_headline`,`page_teaser`,`page_special`,`page_text1`,`page_text2`,`page_text_details`,`page_text_teaser`,`room_id`,`includes`)
SELECT `id`,`parent_id`,`caption_save`,`caption`,IF(`page_layout` IN ('builders_club_addons','builders_club_frontpage','builders_club_loyalty','mad_money','monkey','niko'), 'default_3x3', `page_layout`),`icon_color`,`icon_image`,`min_rank`,`order_num`,IF(`page_layout` IN ('builders_club_addons','builders_club_frontpage','builders_club_loyalty','mad_money','monkey','niko'), '0', `visible`),`enabled`,`club_only`,`vip_only`,`page_headline`,`page_teaser`,`page_special`,`page_text1`,`page_text2`,`page_text_details`,`page_text_teaser`,`room_id`,`includes` FROM cat2022.`catalog_pages`;

DELETE FROM `catalog_items`;
INSERT INTO `catalog_items` (`id`,`item_ids`,`page_id`,`catalog_name`,`cost_credits`,`cost_points`,`points_type`,`amount`,`limited_stack`,`limited_sells`,`order_number`,`offer_id`,`song_id`,`extradata`,`have_offer`,`club_only`)
SELECT `id`,`item_ids`,`page_id`,`catalog_name`,`cost_credits`,`cost_points`,`points_type`,`amount`,`limited_stack`,`limited_sells`,`order_number`,`offer_id`,`song_id`,`extradata`,`have_offer`,IF(`club_only` = '2', '1', `club_only`) FROM cat2022.`catalog_items`;

DELETE FROM `catalog_items_limited`;
INSERT INTO `catalog_items_limited` (`catalog_item_id`,`number`,`user_id`,`timestamp`,`item_id`)
SELECT `catalog_item_id`,`number`,`user_id`,`timestamp`,`item_id` FROM cat2022.`catalog_items_limited`;

DELETE FROM `items_crackable`;
INSERT INTO `items_crackable` (`item_id`,`item_name`,`count`,`prizes`,`achievement_tick`,`achievement_cracked`,`required_effect`,`subscription_duration`,`subscription_type`)
SELECT `item_id`,`item_name`,`count`,`prizes`,`achievement_tick`,`achievement_cracked`,`required_effect`,`subscription_duration`,`subscription_type` FROM cat2022.`items_crackable`;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
