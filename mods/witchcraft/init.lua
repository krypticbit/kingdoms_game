local mp = minetest.get_modpath(minetest.get_current_modname())

-- a reaction is a function that is called when a certain two solutions mix (or a solution and an item)
-- disasters are bad non-specific reactions
-- herbs are items gotten from leaves and used in making solutions
-- helpers are just helper functions
-- effects are things that happen when a beaker with solution is thrown

witchcraft = {}
witchcraft.solutions = {}
witchcraft.reactions = {}
witchcraft.disasters = {}
witchcraft.herbs = {}
witchcraft.helpers = {}
witchcraft.effects = {}

-- Load helper functions
dofile(mp .. "/helpers.lua")
-- Load registering functions
dofile(mp .. "/beakers.lua")
dofile(mp .. "/cauldron.lua")
dofile(mp .. "/herbs.lua")
-- Load reactions / disasters
dofile(mp .. "/reactions.lua")
dofile(mp .. "/disasters.lua")
-- Load solutions
dofile(mp .. "/solutions.lua")
dofile(mp .. "/effects.lua")
-- Load plant processor
dofile(mp .. "/plant_processor.lua")
-- Load crafting recipes
dofile(mp .. "/crafting.lua")
