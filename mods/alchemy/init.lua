local mp = minetest.get_modpath(minetest.get_current_modname())

-- a reaction is a function that is called when a certain two solutions mix (or a solution and an item)
-- disasters are bad non-specific reactions
-- herbs are items gotten from leaves and used in making solutions
-- helpers are just helper functions
-- effects are things that happen when a beaker with solution is thrown

local s = minetest.get_mod_storage()
local ts = s:get_string("teleport_stones")
if ts ~= "" then
   ts = minetest.deserialize(ts)
else
   ts = {}
end

alchemy = {}
alchemy.solutions = {}
alchemy.reactions = {}
alchemy.disasters = {}
alchemy.herbs = {}
alchemy.helpers = {}
alchemy.effects = {}
alchemy.active_effects = {}
alchemy.effect_hud = {}
alchemy.hud = {}
alchemy.teleport_stones = ts
alchemy.concentrations = {}

alchemy.save = function()
   local ts = minetest.serialize(alchemy.teleport_stones)
   s:set_string("teleport_stones", ts)
end

-- Load helper functions
dofile(mp .. "/helpers.lua")
-- Load HUD system
dofile(mp .. "/hud.lua")
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
dofile(mp .. "/teleporting.lua")
-- Load plant processor
dofile(mp .. "/plant_processor.lua")
-- Load concentration
dofile(mp .. "/concentration.lua")
-- Load crafting recipes
dofile(mp .. "/crafting.lua")
