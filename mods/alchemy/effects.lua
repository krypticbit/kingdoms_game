-- Effect duration system
active_effects = {}

local function decrease_effect_timer()
   for p, eList in pairs(active_effects) do
      for e, t in pairs(eList) do
         active_effects[p][e].time = t.time - 1
         if t.time < 0 then
            if t.on_end then
               t.on_end(t.target)
            end
            active_effects[p][e] = nil
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

local function register_timed_effect(e, time, on_start, on_end)
   alchemy.effects["alchemy:beaker_" .. e] = function(p, pos)
      if on_start then
         on_start(p, pos)
      end
      local n = p:get_player_name()
      if not active_effects[n] then
         active_effects[n] = {}
      end
      if active_effects[n][e] then
         active_effects[n][e].time = active_effects[n][e].time + time
      else
         active_effects[n][e] = {}
         active_effects[n][e].time = time
      end
      active_effects[n][e].on_end = on_end
      active_effects[n][e].target = p
   end
end

alchemy.register_effect = register_effect

-- Healing brew
register_effect("healing_brew", function(p, pos)
   local hp = p:get_hp() + 10
   if hp > 20 then hp = 20 end
   p:set_hp(hp)
end)

-- Fire resistance
register_timed_effect("fire_resistance", 300)
minetest.register_on_player_hpchange(function(p, change)
   if change > 0 then return change end
   local n = p:get_player_name()
   if active_effects[n] and active_effects[n]["fire_resistance"] then
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
register_timed_effect("jump_boost", 50, function(player, pos)
   set_player_physics_multiplier(player, {jump = 2}, 20, "potions jump boost")
end,
function(player)
   remove_player_physics_multiplier(player, "potions jump boost")
end)

-- Speed brew
register_timed_effect("speed_boost", 500, function(player, pos)
   set_player_physics_multiplier(player, {speed = 2}, 20, "potions speed boost")
end,
function(player)
   remove_player_physics_multiplier(player, "potions speed boost")
end)
