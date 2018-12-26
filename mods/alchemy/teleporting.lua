-- Teleporting potions get their own file because they are so complicated

local function register_teleport_solution(shortname, stonetype, tex, ing, num)
   -- Register solution / reactions
   alchemy.register_solution(shortname, "Teleport Solution Type " .. stonetype, tex)
   alchemy.register_basic_reactions("emen_brew", ing, shortname, num)
   -- Register node / craft
   local beakerName = "alchemy:beaker_" .. shortname
   local nodeName = "alchemy:block_" .. shortname
   local beakerImg = minetest.registered_nodes[beakerName].inventory_image
   local sideImg = "teleporter_block.png^(" .. beakerImg .. ")"
   local topBottomImg = "teleporter_block.png"
   minetest.register_node(nodeName, {
      description = "Teleport Stone Type " .. stonetype,
      tiles = {topBottomImg, topBottomImg, sideImg, sideImg, sideImg, sideImg},
      groups = {cracky = 1, level = 2},
      on_place = function(itemstack, placer, pointed_thing)
         -- Ensure placer is not nil
         if placer == nil then return end
         -- Ensure that it is a player
         local name = placer:get_player_name()
         if name == nil then return end
         -- Create tables if necessary
         if alchemy.teleport_stones[name] == nil then
            alchemy.teleport_stones[name] = {}
         else
            -- Check if a teleport stone for this potion already exists
            if alchemy.teleport_stones[name][shortname] ~= nil then
               local pos = minetest.pos_to_string(alchemy.teleport_stones[name][shortname])
               minetest.chat_send_player(name, "You already have a teleport stone at " .. pos .. ".  Destroy it to be able to place another one of the same type.")
               return
            end
         end
         -- Create a teleport stone at the current position
         minetest.item_place(itemstack, placer, pointed_thing)
         return itemstack
      end,
      after_place_node = function(pos, placer)
         -- Set up node metadata
         local meta = minetest.get_meta(pos)
         local name = placer:get_player_name()
         meta:set_string("placer", name)
         meta:set_string("infotext", name .. "'s teleport stone (Type " .. stonetype .. ")")
         -- Save into teleport stone table
         alchemy.teleport_stones[name][shortname] = pos
         alchemy.save()
      end,
      after_dig_node = function(pos, oldnode, oldmetadata, digger)
         local placerName = oldmetadata["fields"]["placer"]
         if placerName == nil then return end
         alchemy.teleport_stones[placerName][shortname] = nil
         alchemy.save()
      end
   })
   minetest.register_craft({
      type = "shapeless",
      output = nodeName,
      recipe = {beakerName, "default:steelblock"}
   })
   -- Register potion effects
   -- (Registered as timed so that there will be a nice countdown before teleporting)
   alchemy.register_timed_effect(shortname, {
      effect_name = "Warp countdown",
      duration = 5,
      on_end = function(n)
         local p = minetest.get_player_by_name(n)
         if p then
            local pos = alchemy.teleport_stones[n][shortname]
            if pos == nil then
               minetest.chat_send_player(n, "You have not placed a type " .. stonetype .. " warp stone!")
               return
            else
               if minetest.is_protected(pos, n) then
                  minetest.chat_send_player(n "This warpstone is in a protected area!")
                  return
               end
               p:set_pos(pos)
            end
         end
      end
   })
end

register_teleport_solution("teleport1", "A", "teleport1_solution.png", "default:diamond", 5)
register_teleport_solution("teleport2", "B", "teleport2_solution.png", "default:mese_crystal", 10)
