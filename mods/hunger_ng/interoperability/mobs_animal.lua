local add = hunger_ng.functions.add_hunger_data

-- Mobs Redo Animals: https://forum.minetest.net/viewtopic.php?t=9917
--
-- The `mobs_animal` mod registers it’s stuff under the `mobs` prefix.
add('mobs:cheese',              { satiates = 2.5 })
add('mobs:chicked_egg_fried',   { satiates = 2 })
add('mobs:chicken_cooked',      { satiates = 5 })
add('mobs:chicken_egg_fried',   { satiates = 2 })
add('mobs:chicken_raw',         { satiates = 2, heals = -2 })
add('mobs:honey',               { satiates = 2 })
add('mobs:meat',                { satiates = 5.5 })
add('mobs:meat_raw',            { satiates = 2.5, heals = -1 })
add('mobs:mutton_cooked',       { satiates = 6, heals = 1 })
add('mobs:mutton_raw',          { satiates = 2, heals = -1 })
add('mobs:pork_cooked',         { satiates = 4 })
add('mobs:pork_raw',            { satiates = 1 })
add('mobs:rabbit_cooked',       { satiates = 4.5 })
add('mobs:rabbit_raw',          { satiates = 2, heals = -1 })
add('mobs:rat_cooked',          { satiates = 1.5 })
