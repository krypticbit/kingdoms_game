-- Return an itemstring to turn the cauldron into that item
-- Return false to do nothing
-- Return nil to turn it to slime

-----
-- Cauldron-beaker reactions
-----

local function register_put_take_reactions(potion)
   witchcraft.reactions["witchcraft:cauldron_empty witchcraft:beaker_" .. potion] = function(pos, w)
      return "witchcraft:cauldron_" .. potion .. "1"
   end
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. "1 witchcraft:beaker_" .. potion] = function(pos, w)
      return "witchcraft:cauldron_" .. potion .. "2"
   end
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. "2 witchcraft:beaker_" .. potion] = function(pos, w)
      return "witchcraft:cauldron_" .. potion .. "3", "witchcraft:beaker_empty"
   end
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. "1 witchcraft:beaker_empty"] = function(pos, w)
      return "witchcraft:cauldron_empty"
   end
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. "2 witchcraft:beaker_empty"] = function(pos, w)
      return "witchcraft:cauldron_" .. potion .. "1"
   end
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. "3 witchcraft:beaker_empty"] = function(pos, w)
      return "witchcraft:cauldron_" .. potion .. "2"
   end
end

local function register_mix_reaction(potion1, clevel, potion2, result)
   local next = tostring(tonumber(clevel) + 1)
   witchcraft.reactions["witchcraft:cauldron_" .. potion1 .. clevel .. " witchcraft:beaker_" .. potion2] = function(pos, w)
      return "witchcraft:cauldron_" .. result .. next
   end
end

-- Put-take reactions
register_put_take_reactions("base")
register_put_take_reactions("slime")
register_put_take_reactions("energized_base")
register_put_take_reactions("glycon_brew")
register_put_take_reactions("healing_brew")

witchcraft.register_put_take_reactions = register_put_take_reactions

-----
-- Cauldron-item reations
-----

local function register_basic_reaction(num, potion, with, to, itemNum)
   witchcraft.reactions["witchcraft:cauldron_" .. potion .. num .. " " .. with] = function(pos, itemCount, inv)
      local itemCountTot = witchcraft.helpers.get_number_of_items_in_inv(inv, "main", with)
      if itemCountTot < itemNum then
         return false
      elseif itemCountTot == itemNum then
         return "witchcraft:cauldron_" .. to .. num
      end
   end
end

local function register_basic_reactions(potion, with, to, itemNum)
   register_basic_reaction("1", potion, with, to, itemNum)
   register_basic_reaction("2", potion, with, to, itemNum)
   register_basic_reaction("3", potion, with, to, itemNum)
end

-- Basic brew reactions
register_basic_reactions("base", "default:mese_crystal", "energized_base", 1)
register_basic_reactions("energized_base", "witchcraft:herb_glycon", "glycon_brew", 5)
register_basic_reactions("energized_base", "witchcraft:herb_celros", "celros_brew", 8)
register_basic_reactions("energized_base", "witchcraft:herb_iceweed", "iceweed_brew", 2)
register_basic_reactions("energized_base", "witchcraft:herb_shal_stalk", "shal_stalk_brew", 2)

-- Reaction for healing potion
register_mix_reaction("glycon_brew", 2, "celros_brew", "healing_brew")

-- Reaction for fire-resistance potion
register_basic_reactions("iceweed_brew", "default:snow", "fire_resistance", 5)

-- Reactions for jump boost potion
register_basic_reactions("shal_stalk_brew", "default:mese_crystal", "boost", 1)
register_mix_reaction("boost", 1, "celros_brew", "jump_boost")

-- Reactions for speed boost potion
register_mix_reaction("boost", 1, "glycon_brew", "speed_boost")
