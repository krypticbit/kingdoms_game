-- Get modpath
local mp = minetest.get_modpath(minetest.get_current_modname())

-- Define tables
projectiles = {}
local gun_uid = 1

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
         minetest.chat_send_all("Hit entity")
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
            minetest.chat_send_all(dump(pos))
            break
         end
      end
   end
   -- Damage victim (if any)
   if hit then
      local hit_pos = hit.intersection_point
      local hit_height = hit_pos.y - hit.ref:get_pos().y
      minetest.chat_send_all(tostring(hit_height))
      if hit_height > 1.7 then -- headshot
         hit.ref:punch(shooter, nil, {damage_groups = {fleshy = damage * 1.5}})
      else
         hit.ref:punch(shooter, nil, {damage_groups = {fleshy = damage}})
      end
   end
end

-- Reloading functions
local function should_continue_reload(player, shooter_uid)
   return player:get_wielded_item():get_meta():get_int("shooter_uid") == shooter_uid
end

local function abort_reload(player, hudid)
   minetest.chat_send_all("aborted")
   player:hud_remove(hudid)
end

local function finish_reload(player, shooter_uid, hudid, rounds)
   -- Check if the player is still holding the gun
   if should_continue_reload(player, shooter_uid) ~= true then
      abort_reload(player, hudid)
   end
   -- Remove hud
   player:hud_remove(hudid)
   -- Reload gun
   local w = player:get_wielded_item()
   local meta = w:get_meta()
   meta:set_string("rounds", rounds)
   player:set_wielded_item(w)
end

local function update_reload(player, shooter_uid, hudid, rounds, quartertime, to)
   -- Check if the player is still holding the gun
   if should_continue_reload(player, shooter_uid) ~= true then
      abort_reload(player, hudid)
      return
   end
   -- Update the HUD
   player:hud_change(hudid, "text", "projectiles_reloading_" .. to .. ".png")
   -- Figure out what function to call next
   if to >= 3 then
      minetest.after(quartertime, finish_reload, player, shooter_uid, hudid, rounds)
   else
      minetest.after(quartertime, update_reload, player, shooter_uid, hudid, rounds, quartertime, to + 1)
   end
end

local function reload(player, shooter_uid, speed, rounds)
   minetest.chat_send_all("reloading")
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
   minetest.after(quartertime, update_reload, player, shooter_uid, hudid, rounds, quartertime, 1)
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
   -- Register shooter as tool
   minetest.register_tool("projectiles:" .. name, {
      description = description,
      inventory_image = texture,
      range = 0,
      on_use = function(istack, user, pointed_thing)
         if user == ni or user:is_player() == false then return end
         local meta = istack:get_meta()
         local rounds = meta:get_int("rounds")
         -- Shoot if loaded
         if rounds > 0 then
            meta:set_int("rounds", rounds - 1)
            shoot(user, damage, range)
         else
            -- Attempt to reload
            local user_inv = user:get_inventory()
            if user_inv:contains_item("main", ammo) then
               user_inv:remove_item("main", ammo)
               meta:set_int("shooter_uid", gun_uid)
               reload(user, gun_uid, reload_speed, max_rounds)
               gun_uid = gun_uid + 1
            end
         end
         return istack
      end
   })
end

-- Register guns
dofile(mp .. "/colonial_guns.lua")
