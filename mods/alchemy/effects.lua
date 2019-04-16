local time_multiplier = 1.3

-- Effect duration system
local function decrease_effect_timer()
   for p, eList in pairs(alchemy.active_effects) do
      local player = minetest.get_player_by_name(p)
      if player then
         for e, t in pairs(eList) do
            alchemy.active_effects[p][e].time = t.time - 1
            if t.time <= 0 then
               if t.on_end then
                  t.on_end(player)
               end
               alchemy.hud.remove_effect(player, t.number, t)
               alchemy.active_effects[p][e] = nil
            else
               -- Update the HUD
               alchemy.hud.update_effect(player, t.number, t)
               -- Run on_tick function
               if t.on_tick then t.on_tick(player) end
            end
         end
      end
   end
   minetest.after(1, decrease_effect_timer)
end

-- Start timer
decrease_effect_timer()

-- Effect registering
local function register_effect(name, effect)
   alchemy.effects["alchemy:beaker_" .. name] = effect
end

local function register_timed_effect(e, def)
   local eName = def.effect_name
   local time = def.duration
   local on_start = def.on_start
   local on_tick = def.on_tick
   local on_end = def.on_end
   alchemy.effects["alchemy:beaker_" .. e] = function(p, pos, cLevel)
      -- Get correct time
      local cTime = math.floor(time * (time_multiplier ^ (cLevel - 1)))
      -- Run on_start
      local new_effect = false
      if on_start then
         on_start(p, pos)
      end
      -- Add effect to array
      local n = p:get_player_name()
      if not alchemy.active_effects[n] then
         alchemy.active_effects[n] = {}
      end
      if alchemy.active_effects[n][e] then
         alchemy.active_effects[n][e].time = alchemy.active_effects[n][e].time + cTime
      else
         alchemy.active_effects[n][e] = {}
         alchemy.active_effects[n][e].time = cTime
         new_effect = true
      end
      alchemy.active_effects[n][e].on_tick = on_tick
      alchemy.active_effects[n][e].on_end = on_end
      alchemy.active_effects[n][e].target = n
      alchemy.active_effects[n][e].name = eName
      -- Add to HUD if its a new effect
      if new_effect then
         local eNum = alchemy.hud.add_effect(p, alchemy.active_effects[n][e])
         alchemy.active_effects[n][e].number = eNum
      end
   end
end

-- When the player rejoins, re-add their HUDs
minetest.register_on_joinplayer(function(player)
   local n = player:get_player_name()
   if alchemy.active_effects[n] == nil then return end
   for e, eTable in pairs(alchemy.active_effects[n]) do
      local eNum = alchemy.hud.add_effect(player, eTable)
      alchemy.active_effects[n][e].number = eNum
   end
end)

alchemy.register_effect = register_effect
alchemy.register_timed_effect = register_timed_effect

-- Energized base (some things shouldnt be drunk)
register_effect("energized_base", function(p, pos, cLevel)
   local function explode(p, pos)
      -- Work-around because of how TNT protection checking works
      local ignore_protection = not minetest.is_protected(pos, p:get_player_name())
      local radius = 5 + cLevel
      tnt.boom(p:get_pos(), {
         radius = radius,
         damage_radius = radius + 3,
         ignore_protection = ignore_protection,
      })
      p:set_hp(0)
   end
   -- Slight delay so that the beaker is correctly dropped
   minetest.after(0.1, explode, p, pos)
end)

-- Drinking slime is just dumb
register_effect("slime", function(p, pos, cLevel)
   p:set_hp(p:get_hp() - 2)
end)

-- Healing brew
register_effect("healing_brew", function(p, pos, cLevel)
   local hp = p:get_hp() + 5 + (cLevel - 1) * 2
   if hp > 20 then hp = 20 end
   p:set_hp(hp)
end)

-- Fire resistance
register_timed_effect("fire_resistance", {
   effect_name = "Fire Resistance",
   duration = 40
})
minetest.register_on_player_hpchange(function(p, change)
   if change > 0 then return change end
   local n = p:get_player_name()
   if alchemy.active_effects[n] and alchemy.active_effects[n]["fire_resistance"] then
      local pos = p:get_pos()
      -- Check bottom node
      local node = minetest.get_node(pos)
      if node == nil then return 0 end
      if node.name:find("default:lava_") or
      node.name == "fire:basic_flame" or
      node.name == "fire:permanent_flame" then
         local d = node.damage_per_second or minetest.registered_nodes["default:lava_flowing"].damage_per_second
         if d == -change then
            return 0
         end
      end
      -- Check upper node
      local above_node = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
      if above_node == nil then return 0 end
      if above_node.name:find("default:lava_") or
      above_node.name == "fire:basic_flame" or
      above_node.name == "fire:permanent_flame" then
         local d_above = above_node.damage_per_second or minetest.registered_nodes["default:lava_flowing"].damage_per_second
         if d_above == -change then
            return 0
         end
      end
   end
   return change
end, true)

-- Jump brew
register_timed_effect("jump_boost", {
   effect_name = "Jump Boost",
   duration = 70,
   on_start = function(player, pos)
      set_player_physics_multiplier(player, {jump = 2}, 20, "potions jump boost")
   end,
   on_end = function(player)
      remove_player_physics_multiplier(player, "potions jump boost")
   end
})

-- Speed brew
register_timed_effect("speed_boost", {
   effect_name = "Speed Boost",
   duration = 200,
   on_start = function(player, pos)
      set_player_physics_multiplier(player, {speed = 2}, 20, "potions speed boost")
   end,
   on_end = function(player)
      remove_player_physics_multiplier(player, "potions speed boost")
   end
})

-- Invisibility potion
register_timed_effect("invisibility_brew", {
   effect_name = "Invisibility",
   duration = 60,
   on_start = function(player, pos)
      player:set_properties({visual_size = {x = 0, y = 0}})
   end,
   on_end = function(player)
      player:set_properties({visual_size = {x = 1, y = 1}})
   end
})

-- Water-breathing potion
register_timed_effect("water_breathing_brew", {
   effect_name = "Water Breathing",
   duration = 120,
   on_tick = function(player)
      player:set_breath(20)
   end
})
