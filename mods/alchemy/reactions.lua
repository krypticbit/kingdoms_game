-- Return an itemstring to turn the cauldron into that item
-- Return false to do nothing
-- Return nil to turn it to slime

-----
-- Cauldron-beaker reactions
-----

local function register_put_take_reactions(potion)
   alchemy.reactions["alchemy:cauldron_empty alchemy:beaker_" .. potion] = function(pos, w)
      return "alchemy:cauldron_" .. potion .. "1"
   end
   alchemy.reactions["alchemy:cauldron_" .. potion .. "1 alchemy:beaker_" .. potion] = function(pos, w)
      return "alchemy:cauldron_" .. potion .. "2"
   end
   alchemy.reactions["alchemy:cauldron_" .. potion .. "2 alchemy:beaker_" .. potion] = function(pos, w)
      return "alchemy:cauldron_" .. potion .. "3", "alchemy:beaker_empty"
   end
   alchemy.reactions["alchemy:cauldron_" .. potion .. "1 alchemy:beaker_empty"] = function(pos, w)
      return "alchemy:cauldron_empty"
   end
   alchemy.reactions["alchemy:cauldron_" .. potion .. "2 alchemy:beaker_empty"] = function(pos, w)
      return "alchemy:cauldron_" .. potion .. "1"
   end
   alchemy.reactions["alchemy:cauldron_" .. potion .. "3 alchemy:beaker_empty"] = function(pos, w)
      return "alchemy:cauldron_" .. potion .. "2"
   end
end

alchemy.register_put_take_reactions = register_put_take_reactions

local function register_mix_reaction(potion1, clevel, potion2, result)
   local next = tostring(tonumber(clevel) + 1)
   alchemy.reactions["alchemy:cauldron_" .. potion1 .. clevel .. " alchemy:beaker_" .. potion2] = function(pos, w)
      return "alchemy:cauldron_" .. result .. next
   end
end

alchemy.register_mix_reaction = register_mix_reaction

-- Put-take reactions
register_put_take_reactions("base")
register_put_take_reactions("slime")
register_put_take_reactions("energized_base")
register_put_take_reactions("glycon_brew")
register_put_take_reactions("healing_brew")



-----
-- Cauldron-item reations
-----

local function register_basic_reaction(num, potion, with, to, itemNum)
   alchemy.reactions["alchemy:cauldron_" .. potion .. num .. " " .. with] = function(pos, itemCount, inv)
      local itemCountTot = alchemy.helpers.get_number_of_items_in_inv(inv, "main", with)
      if itemCountTot < itemNum then
         return false
      elseif itemCountTot == itemNum then
         return "alchemy:cauldron_" .. to .. num
      end
   end
end

local function register_basic_reactions(potion, with, to, itemNum)
   register_basic_reaction("1", potion, with, to, itemNum)
   register_basic_reaction("2", potion, with, to, itemNum * 2)
   register_basic_reaction("3", potion, with, to, itemNum * 3)
end

alchemy.register_basic_reactions = register_basic_reactions

-- Basic brew reactions
register_basic_reactions("base", "default:mese_crystal", "energized_base", 1)
register_basic_reactions("energized_base", "alchemy:herb_glycon", "glycon_brew", 5)
register_basic_reactions("energized_base", "alchemy:herb_celros", "celros_brew", 8)
register_basic_reactions("energized_base", "alchemy:herb_iceweed", "iceweed_brew", 2)
register_basic_reactions("energized_base", "alchemy:herb_shal_stalk", "shal_stalk_brew", 2)

-- Reaction for healing potion
register_mix_reaction("glycon_brew", 2, "celros_brew", "healing_brew")

-- Reaction for fire-resistance potion
register_basic_reactions("iceweed_brew", "default:snow", "fire_resistance", 5)

-- Reactions for jump boost potion
register_basic_reactions("shal_stalk_brew", "default:mese_crystal", "boost", 1)
register_mix_reaction("boost", 1, "celros_brew", "jump_boost")

-- Reactions for speed boost potion
register_mix_reaction("boost", 1, "glycon_brew", "speed_boost")
