-- Get modpath
local mp = minetest.get_modpath(minetest.get_current_modname())

-- Define tables
projectiles = {}
local shooters_reloading = {}
local shooter_uid = 1

-- Shooting functions
local function shoot(shooter, damage, range)
   -- Make raycast
   local from = shooter:get_pos()
   from.y = from.y + shooter:get_properties().eye_height
   local dir = shooter:get_look_dir()
   local to = vector.add(vector.multiply(dir, range), from)
   local ray = minetest.raycast(from, to, true, false)
   -- Figure out what was hit
   local hit = nil
   for pointed_thing in ray do
      if pointed_thing.type == "object" and pointed_thing.ref ~= shooter then
         hit = pointed_thing
         break
      elseif pointed_thing.type == "node" then
         -- Check if the bullet can go through the node
         local pos = minetest.get_pointed_thing_position(pointed_thing, from.y < to.y)
         local node = minetest.get_node_or_nil(pos)
         if node == nil or node.name == nil then -- Unloaded / broken node
            break
         end
         local n_def = minetest.registered_nodes[node.name]
         if n_def == nil then -- Unknown node
            break
         end
         if n_def.walkable then -- Hit a solid node
            break
         end
      end
   end
   -- Damage victim (if any)
   if hit then
      local hit_pos = hit.intersection_point
      local hit_height = hit_pos.y - hit.ref:get_pos().y
      -- Account for distance; do 3/4 damage at max range
      local dist = vector.distance(from, hit_pos)
      damage = damage * (1 - dist / range / 4)
      if hit_height > 1.2 then -- headshot
         damage = damage * 1.5
      end
      hit.ref:punch(shooter, nil, {damage_groups = {fleshy = damage}})
   end
end

-- Reloading functions
local function should_continue_reload(player, shooter_uid)
   return player:get_wielded_item():get_meta():get_int("shooter_uid") == shooter_uid
end

local function abort_reload(player, hudid, ammo, shooter_uid)
   player:hud_remove(hudid)
   local user_inv = player:get_inventory()
   user_inv:add_item("main", ammo)
   shooters_reloading[shooter_uid] = nil
end

local function finish_reload(player, shooter_uid, hudid, rounds, ammo)
   -- Check if the player is still holding the gun
   if should_continue_reload(player, shooter_uid) ~= true then
      abort_reload(player, hudid, ammo, shooter_uid)
   end
   -- Remove hud
   player:hud_remove(hudid)
   -- Reload gun
   local w = player:get_wielded_item()
   local meta = w:get_meta()
   meta:set_string("rounds", rounds)
   w:set_wear(1)
   player:set_wielded_item(w)
   -- Remove reloading status
   shooters_reloading[shooter_uid] = nil
end

local function update_reload(player, shooter_uid, hudid, rounds, ammo, quartertime, to)
   -- Check if the player is still holding the gun
   if should_continue_reload(player, shooter_uid) ~= true then
      abort_reload(player, hudid, ammo, shooter_uid)
      return
   end
   -- Update the HUD
   player:hud_change(hudid, "text", "projectiles_reloading_" .. to .. ".png")
   -- Figure out what function to call next
   if to >= 3 then
      minetest.after(quartertime, finish_reload, player, shooter_uid, hudid, rounds, ammo)
   else
      minetest.after(quartertime, update_reload, player, shooter_uid, hudid, rounds, ammo, quartertime, to + 1)
   end
end

local function reload(player, shooter_uid, speed, rounds, ammo)
   -- Calculate quartertime
   local quartertime = speed / 4.0
   -- Add the hud
   local hudid = player:hud_add({
      hud_elem_type = "image",
      position = {x = 0.5, y = 0.5},
      offset = {x = 0, y = 0},
      scale = {x = 1, y = 1},
      alignment = {x = 0, y = 0},
      text = "projectiles_reloading_0.png"
   })
   -- Start reload cycle
   minetest.after(quartertime, update_reload, player, shooter_uid, hudid, rounds, ammo, quartertime, 1)
end

projectiles.register_shooter = function(name, def)
   -- Input sanitzation
   if type(name) ~= "string" then
      minetest.log("[PROJECTILES] Invalid name '" .. name .. "'; not registering")
   end
   local texture = def.texture or ""
   local damage = def.damage or 1
   local range = def.range or 40
   local ammo = def.ammo or "default:stone"
   local description = def.description or ""
   local max_rounds = def.rounds or 1
   local reload_speed = def.reload_speed or 1
   local scale = def.scale or {x = 1, y = 1, z = 1}
   local iname = "projectiles:" .. name
   -- Register shooter as tool
   minetest.register_tool(iname, {
      description = description,
      inventory_image = texture,
      range = 0,
      wield_scale = scale,
      wear_represents = "reloading", -- For anvil
      on_use = function(istack, user, pointed_thing)
         if user == nil or user:is_player() == false then return end
         local meta = istack:get_meta()
         local rounds = meta:get_int("rounds")
         -- Shoot if loaded
         if rounds > 0 then
            rounds = rounds - 1
            meta:set_int("rounds", rounds)
            local wear = 1 - rounds / max_rounds
            local wearfinal = wear * 65535
            if wear == 1 then wearfinal = 65534 end -- Don't let it break
            istack:set_wear(wearfinal)
            shoot(user, damage, range)
         else
            -- Check if the gun is already reloading
            local s_uid = meta:get_int("shooter_uid")
            if shooters_reloading[s_uid] ~= nil then
               return
            end
            -- Attempt to reload
            local user_inv = user:get_inventory()
            if user_inv:contains_item("main", ammo) then
               user_inv:remove_item("main", ammo)
               meta:set_int("shooter_uid", shooter_uid)
               shooters_reloading[shooter_uid] = true
               reload(user, shooter_uid, reload_speed, max_rounds, ammo)
               shooter_uid = shooter_uid + 1
            end
         end
         return istack
      end
   })
   -- Register craft
   if def.craft then
      def.craft.output = iname
      minetest.register_craft(def.craft)
   end
end

-- Register guns
dofile(mp .. "/colonial_guns.lua")
