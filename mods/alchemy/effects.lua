-- Effect duration system
local function decrease_effect_timer()
   for p, eList in pairs(alchemy.active_effects) do
      local player = minetest.get_player_by_name(p)
      for e, t in pairs(eList) do
         alchemy.active_effects[p][e].time = t.time - 1
         if t.time <= 0 then
            if t.on_end then
               t.on_end(t.target)
            end
            if player then
               alchemy.hud.remove_effect(player, t.number, t)
            end
            alchemy.active_effects[p][e] = nil
         else
            if player then
               alchemy.hud.update_effect(player, t.number, t)
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

local function register_timed_effect(e, eName, time, on_start, on_end)
   alchemy.effects["alchemy:beaker_" .. e] = function(p, pos)
      local new_effect = false
      if on_start then
         on_start(p, pos)
      end
      local n = p:get_player_name()
      if not alchemy.active_effects[n] then
         alchemy.active_effects[n] = {}
      end
      if alchemy.active_effects[n][e] then
         alchemy.active_effects[n][e].time = alchemy.active_effects[n][e].time + time
      else
         alchemy.active_effects[n][e] = {}
         alchemy.active_effects[n][e].time = time
         new_effect = true
      end
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

alchemy.register_effect = register_effect

-- Energized base (some things shouldnt be drunk)
register_effect("energized_base", function(p, pos)
   -- Work-around because of how TNT protection checking works
   local ignore_protection = not minetest.is_protected(pos, p:get_player_name())
   tnt.boom(p:get_pos(), {
      radius = 6,
      damage_radius = 7,
      ignore_protection = ignore_protection,
   })
   p:set_hp(0)
end)

-- Drinking slime is just dumb
register_effect("slime", function(p, pos)
   p:set_hp(p:get_hp() - 2)
end)

-- Healing brew
register_effect("healing_brew", function(p, pos)
   local hp = p:get_hp() + 5
   if hp > 20 then hp = 20 end
   p:set_hp(hp)
end)

-- Fire resistance
register_timed_effect("fire_resistance", "Fire Resistance", 30)
minetest.register_on_player_hpchange(function(p, change)
   if change > 0 then return change end
   local n = p:get_player_name()
   if alchemy.active_effects[n] and alchemy.active_effects[n]["fire_resistance"] then
      local pos = p:get_pos()
      -- Check bottom node
      local node = minetest.get_node(pos)
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
      if above_node.name:find("default:lava_") or
      above_node.name == "fire:basic_flame" or
      above_node.name == "fire:permanent_flame" then
         local d_above = node_above.damage_per_second or minetest.registered_nodes["default:lava_flowing"].damage_per_second
         if d_above == -change then
            return 0
         end
      end
   end
   return change
end, true)

-- Jump brew
register_timed_effect("jump_boost", "Jump Boost", 20, function(player, pos)
   set_player_physics_multiplier(player, {jump = 2}, 20, "potions jump boost")
end,
function(n)
   local player = minetest.get_player_by_name(n)
   if player then
      remove_player_physics_multiplier(player, "potions jump boost")
   end
end)

-- Speed brew
register_timed_effect("speed_boost", "Speed Boost", 120, function(player, pos)
   set_player_physics_multiplier(player, {speed = 2}, 20, "potions speed boost")
end,
function(n)
   local player = minetest.get_player_by_name(n)
   if player then
      remove_player_physics_multiplier(player, "potions speed boost")
   end
end)

-- Invisibility potion
register_timed_effect("invisibility_brew", "Invisibility", 20, function(player, pos)
   player:set_properties({visual_size = {x = 0, y = 0}})
end,
function(n)
   local player = minetest.get_player_by_name(n)
   if player then
      player:set_properties({visual_size = {x = 1, y = 1}})
   end
end)
