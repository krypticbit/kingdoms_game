local max_concentration = 8

--
-- Concentrator
--
local function get_progress_indicator(percent, brewImage)
   if percent == 0 then
      return "concentration_progress_bg.png"
   else
      local fg = brewImage .. "^concentration_progress_mask.png^[makealpha:0,0,0"
      return "concentration_progress_bg.png^[lowpart:" .. percent .. ":" .. fg
   end
end

local function get_formspec(percent, brewImage)
   return "size[8,9]" ..
   "list[current_player;main;0,5;8,4;]" ..
   "list[context;src1;2.45,3.5;1,1;]" ..
   "list[context;src2;4.6,3.5;1,1;]" ..
   "list[context;dst;3.55,0.05;1,1;]" ..
   "image[2.7,0.9;3,3;" .. get_progress_indicator(percent, brewImage) .. "]"
end

local function reset(meta, oc)
   meta:set_int("percent", 0)
   meta:set_string("formspec", get_formspec(0))
   meta:set_string("infotext", oc and "Overconcentrated!" or "Idle")
end

local function check_move_protection(pos, player)
   local pName = player:get_player_name()
   if minetest.is_protected(pos, pName) then
      minetest.record_protection_violation(pos, pName)
      return false
   end
   return true
end

local function allow_put(pos, listname, index, stack, player)
   if check_move_protection(pos, player) then
      if listname == "dst" then
         if stack:get_name() == "alchemy:beaker_empty" then
            return 1
         end
      else
         return 1
      end
   end
   return 0
end

minetest.register_node("alchemy:concentrator", {
   description = "Brew Concentrator",
   paramtype2 = "facedir",
   groups = {cracky = 1, level = 2},
   tiles = {
      "concentrator_side.png",
      "concentrator_side.png",
      "concentrator_side.png",
      "concentrator_side.png",
      "concentrator_side.png",
      "concentrator_front.png"
   },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size("src1", 1)
      inv:set_size("src2", 1)
      inv:set_size("dst", 1)
      meta:set_string("formspec", get_formspec(0))
      meta:set_string("infotext", "Idle")
      meta:set_int("percent", 0)
   end,
   on_timer = function(pos, elapsed)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      -- Make sure nothing is empty
      if inv:is_empty("src1") or inv:is_empty("src2") or inv:is_empty("dst") then
         reset(meta)
         return
      end
      -- Get items
      local src1 = inv:get_stack("src1", 1)
      local src2 = inv:get_stack("src2", 1)
      local src1n = src1:get_name()
      local src2n = src2:get_name()
      local dst = inv:get_stack("dst", 1)
      -- Make sure dst is a single empty beaker
      if dst:get_count() ~= 1 or dst:get_name() ~= "alchemy:beaker_empty" then
         reset(meta)
         return
      end
      -- Make sure both sources are full beakers, the same, and can be concentrated
      if alchemy.helpers.is_full_beaker(src1n) and alchemy.helpers.is_full_beaker(src2n) and src1n == src2n and alchemy.concentrations[src1n] then
         local oc = false
         local c = alchemy.concentrations[src1n]
         local solutionTex = src1n:sub(16, -1) .. "_solution.png"
         local percent = meta:get_int("percent")
         percent = percent + 1
         if percent >= 100 then
            -- Get levels of source beakers
            local src1Lvl = src1:get_meta():get_int("concentration")
            local src2Lvl = src2:get_meta():get_int("concentration")
            if src1Lvl == 0 then src1Lvl = 1 end
            if src2Lvl == 0 then src2Lvl = 1 end
            local newLvl = src1Lvl + src2Lvl
            if newLvl > max_concentration then
               oc = true
               if c.on_overconcentrate then
                  reset(meta, oc)
                  c.on_overconcentrate(pos, inv)
                  return
               else
                  newLvl = 10
               end
            end
            -- Create new dst item stack
            local newDst = ItemStack(c.result)
            local newDstMeta = newDst:get_meta()
            local desc = minetest.registered_nodes[c.result].description
            newDstMeta:set_int("concentration", newLvl)
            newDstMeta:set_string("description", desc .. "\nConcentration: " .. newLvl)
            inv:set_stack("dst", 1, newDst)
            -- Create new src item stacks
            inv:set_stack("src1", 1, "alchemy:beaker_empty")
            inv:set_stack("src2", 1, "alchemy:beaker_empty")
            -- Reset
            reset(meta, oc)
         else
            meta:set_string("formspec", get_formspec(percent, solutionTex))
            meta:set_int("percent", percent)
            return true
         end
      else
         reset(meta)
      end
   end,
   allow_metadata_inventory_put = allow_put,
   allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local stack = inv:get_stack(from_list, from_index)
      return allow_put(pos, to_list, to_index, stack, player)
   end,
   allow_metadata_inventory_take = function(pos, listname, index, stack, player)
      if check_move_protection(pos, player) then
         return stack:get_count()
      end
      return 0
   end,
   on_metadata_inventory_move = function(pos)
      local meta = minetest.get_meta(pos)
      minetest.get_node_timer(pos):start(1.0)
      meta:set_string("infotext", "Concentrating solution ...")
   end,
   on_metadata_inventory_put = function(pos)
      local meta = minetest.get_meta(pos)
      minetest.get_node_timer(pos):start(1.0)
      meta:set_string("infotext", "Concentrating solution ...")
   end
})

minetest.register_craft({
   output = "alchemy:concentrator",
   recipe = {
      {"default:mese", "default:mese", "default:mese"},
      {"alchemy:beaker_empty", "default:steelblock", "alchemy:beaker_empty"},
      {"group:wood", "default:diamondblock", "group:wood"}
   }
})

--
-- Concentration recipies
--

local function register_concentration(solution, def)
   local bName = "alchemy:beaker_" .. solution
   alchemy.concentrations[bName] = {
      result = def.result or "alchemy:beaker_empty",
      on_overconcentrate = def.on_overconcentrate or function() end,
   }
end

alchemy.register_concentration = register_concentration

register_concentration("healing_brew", {
   result = "alchemy:beaker_healing_brew"
})

register_concentration("fire_resistance", {
   result = "alchemy:beaker_fire_resistance",
   on_overconcentrate = function(pos, inv)
      alchemy.disasters.ice_block(pos)
      inv:set_stack("dst", 1, "")
      inv:set_stack("src1", 1, "")
      inv:set_stack("src2", 1, "")
   end
})

register_concentration("jump_boost", {
   result = "alchemy:beaker_jump_boost",
   on_overconcentrate = function(pos, inv)
      alchemy.disasters.explode_up(pos, 15, true)
      inv:set_stack("dst", 1, "")
      inv:set_stack("src1", 1, "")
      inv:set_stack("src2", 1, "")
   end
})

register_concentration("speed_boost", {
   result = "alchemy:beaker_speed_boost",
   on_overconcentrate = function(pos, inv)
      tnt.boom(pos, {
         radius = 4,
         damage_radius = 8,
         ignore_protection = true,
      })
      inv:set_stack("dst", 1, "")
      inv:set_stack("src1", 1, "")
      inv:set_stack("src2", 1, "")
   end
})

register_concentration("invisibility_brew", {
   result = "alchemy:beaker_invisibility_brew",
   on_overconcentrate = function(pos, inv)
      minetest.remove_node(pos)
   end
})

register_concentration("water_breathing_brew", {
   result = "alchemy:water_breathing_brew",
   on_overconcentrate = function(pos, inv)
      tnt.boom(pos, {
         radius = 0,
         damage_radius = 20,
         ignore_protection = true,
      })
   end
})
