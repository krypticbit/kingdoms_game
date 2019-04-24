-- Helper functions
local function get_infotext(kname, aname, prog)
   local it = "Marker owned by kingdom " .. kname
   if aname then
      it = it .. "\nUnder attack from kingdom " .. aname
   end
   if prog then
      it = it .. "\nProgress: " .. tostring(math.floor(prog)) .. "% conquered"
   end
   return it
end

local function cancel_attack(meta, dname, aname)
   meta:set_string("attackers", "")
   meta:set_string("infotext", get_infotext(dname))
   minetest.chat_send_all("Kingdom " .. dname ..
      " warded off the attack of kingdom " .. aname .. "!")
   kingdoms.add_news("Kingdom " .. aname .. " attacked a territory of kingdom " .. dname .. " but failed to capture it")
end

local function finish_attack(pos, hpos, meta, dname, aname)
   kingdoms.markers[hpos].kingdom = aname
   meta:set_string("attackers", "")
   meta:set_string("infotext", get_infotext(aname))
   minetest.swap_node(pos, {name = "kingdoms:marker_" .. string.lower(kingdoms.kingdoms[aname].color)})
   minetest.chat_send_all("Kingdom " .. aname .. " conquered a territory of kingdom " .. dname)
   kingdoms.add_news("Kingdom " .. aname .. " captured a territory from kingdom " .. dname)
   kingdoms.helpers.save()
end

local function random_velocity()
   return {
      x = math.random() - 0.5,
      y = math.random() - 0.5,
      z = math.random() - 0.5
   }
end

local function add_particles(from, to, particle_dist, tex)
   local dist = vector.distance(from, to)
   local ang = vector.direction(from, to)
   local pidx = 0
   local offset
   while pidx * particle_dist < dist do
      offset = pidx * particle_dist
      minetest.add_particle({
         pos = {x = from.x + ang.x * offset,
            y = from.y + ang.y * offset,
            z = from.z + ang.z * offset},
         velocity = random_velocity(),
         acceleration = {x = 0, y = 0, z = 0},
         expirationtime = 0.6,
         texture = tex,
         glow = 100
      })
      pidx = pidx + 1
   end
end

-- Default marker
minetest.register_node("kingdoms:marker", {
   description = "Marker",
   tiles = {"kingdoms_marker.png^[noalpha"},
   stack_max = 1,
   on_place = function(istack, placer, pointed_thing)
      -- Check if the placer is a player
      if placer == nil or minetest.is_player(placer) == false then
         return istack
      end
      -- Check if the placer is on a team
      local pname = placer:get_player_name()
      if kingdoms.members[pname] == nil then
         minetest.chat_send_player(pname, "You cannot place a marker unless you are on a team")
         return istack
      end
      -- Check if placer has make_base permission
      if kingdoms.player_has_priv(pname, "make_base") ~= true then
         minetest.chat_send_player(pname, "Your king did not allow you to place markers")
         return istack
      end
      -- Check if protection would intersect with other teams
      local kname = kingdoms.members[pname].kingdom
      local mpos = pointed_thing.under
      for _, m in pairs(kingdoms.markers) do
         if m.kingdom ~= kname then
            local distsq = (m.pos.x - mpos.x) ^ 2 + (m.pos.z - mpos.z) ^ 2
            if distsq < kingdoms.marker_radius_sq * 2 then
               minetest.chat_send_player(pname, "Marker is too close to another team's marker")
               return istack
            end
         end
      end
      -- Place
      local mrkr = "kingdoms:marker_" .. string.lower(kingdoms.kingdoms[kname].color)
      local res = minetest.item_place(ItemStack(mrkr), placer, pointed_thing)
      if res:is_empty() then
         return res
      else
         return istack
      end
   end
})

-- Colored markers
for c,v in pairs(kingdoms.colors) do
   minetest.register_node("kingdoms:marker_" .. string.lower(c), {
      description = c .. " Marker (You haxxor you)",
      tiles = {"kingdoms_marker.png^[colorize:" .. v .. "^kingdoms_marker.png"},
      light_source = 1,
      drop = "kingdoms:marker",
      groups = {kingdoms_marker = 1, oddly_breakable_by_hand = 1, cracky = 1},
      after_place_node = function(pos, placer, _, _)
         -- Add to marker list
         local kname = kingdoms.members[placer:get_player_name()].kingdom
         kingdoms.markers[minetest.hash_node_position(pos)] = {
            kingdom = kname,
            pos = pos
         }
         kingdoms.helpers.save()
         -- Set infotext
         minetest.get_meta(pos):set_string("infotext", get_infotext(kname))
      end,
      on_punch = function(pos, node, puncher, pointed_thing)
         -- Check if puncher is a player
         if puncher == nil or minetest.is_player(puncher) == false then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            return
         end
         -- Check if puncher is in a kingdom
         local pname = puncher:get_player_name()
         local member = kingdoms.members[pname]
         if member == nil then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            minetest.chat_send_player(pname, "You cannot capture this marker because you are not in a kingdom")
            return
         end
         -- Check if puncher is attacking their own kingdom
         local hpos = minetest.hash_node_position(pos)
         local marker = kingdoms.markers[hpos]
         if marker.kingdom == member.kingdom then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            minetest.chat_send_player(pname, "This marker already belongs to your kingdom")
            return
         end
         -- Check if marker is already under attack
         local meta = minetest.get_meta(pos)
         local attackers = meta:get_string("attackers")
         if attackers ~= "" then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            minetest.chat_send_player(pname, "This marker is already under attack by kingdom " .. attackers)
            return
         end
         -- Check if puncher is wielding a scepter
         if puncher:get_wielded_item():get_name() ~= "kingdoms:scepter" then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            minetest.chat_send_player(pname, "Punch this marker with a scepter to capture it")
            return
         end
         -- Begin attack
         puncher:set_wielded_item("")
         minetest.chat_send_all("Kingdom " .. member.kingdom ..
            " is attacking a territory of kingdom " .. marker.kingdom .. "!")
         local timer = minetest.get_node_timer(pos)
         timer:start(0.5)
         -- Set up metadata
         meta:set_float("countdown", kingdoms.marker_capture_time)
         meta:set_string("attackers", member.kingdom)
         meta:set_string("infotext", get_infotext(marker.kingdom, member.kingdom))
         -- Run callbacks
         minetest.node_punch(pos, node, puncher, pointed_thing)
      end,
      on_timer = function(pos, elapsed)
         -- Get meta
         local hpos = minetest.hash_node_position(pos)
         local meta = minetest.get_meta(pos)
         local akingdom = meta:get_string("attackers")
         local dkingdom = kingdoms.markers[hpos].kingdom
         -- Check if attackers are near marker
         local objs = minetest.get_objects_inside_radius(pos, kingdoms.marker_capture_range)
         local numAttackers = 0
         local numDefenders = 0
         for _, o in pairs(objs) do
            if minetest.is_player(o) and o:get_hp() > 0 then
               local n = o:get_player_name()
               if kingdoms.members[n] then
                  local start_pos = o:get_pos()
                  if kingdoms.members[n].kingdom == akingdom then -- Enemy
                     numAttackers = numAttackers + 1
                     add_particles(start_pos, pos, 0.2,
                        "kingdoms_circle.png^[colorize:" .. kingdoms.colors[kingdoms.kingdoms[akingdom].color])
                  elseif kingdoms.members[n].kingdom == dkingdom then -- Friend
                     numDefenders = numDefenders + 1
                     add_particles(start_pos, pos, 0.2,
                        "kingdoms_circle.png^[colorize:" .. kingdoms.colors[kingdoms.kingdoms[dkingdom].color])
                  end
               end
            end
         end
         -- If there are no attackers, the attackers lost
         if numAttackers == 0 then
            cancel_attack(meta, dkingdom, akingdom)
            return
         end
         -- Decrease countdown
         local cd = meta:get_float("countdown")
         cd = cd + elapsed * (numDefenders - numAttackers)
         -- Check if the attackers won
         if cd < 0 then -- attackers won
            finish_attack(pos, hpos, meta, dkingdom, akingdom)
            return
         elseif cd > kingdoms.marker_capture_time then -- defenders won
            cancel_attack(meta, dkingdom, akingdom)
            return
         end
         -- Set metadata
         meta:set_string("infotext", get_infotext(dkingdom, akingdom, (1 - (cd / kingdoms.marker_capture_time)) * 100))
         meta:set_float("countdown", cd)
         return true
      end
   })
end

-- Scepter to capture markers
minetest.register_tool("kingdoms:scepter", {
   description = "Scepter",
   inventory_image = "kingdoms_scepter.png",
})

minetest.register_craft({
   output = "kingdoms:scepter",
   recipe = {
      {"default:goldblock", "default:goldblock", "default:goldblock"},
      {"default:goldblock", "default:diamondblock", "default:goldblock"},
      {"default:goldblock", "default:goldblock", "default:goldblock"}
   }
})

-- LBM to ensure that markers are the right colors and valid markers
minetest.register_lbm({
   label = "Correct markers",
   name = "kingdoms:correct_markers",
   nodenames = {"group:kingdoms_marker"},
   run_at_every_load = true,
   action = function(pos, node)
      local hpos = minetest.hash_node_position(pos)
      -- Check if marker is recorded
      if kingdoms.markers[hpos] == nil then
         minetest.log("warning", "Invalid marker at " .. minetest.pos_to_string(pos) .. ", removing")
         minetest.set_node(pos, {name = "air"})
         return
      end
      -- Check if marker's kingdom exists
      local k = kingdoms.kingdoms[kingdoms.markers[hpos].kingdom]
      if k == nil then
         minetest.log("warning", "Removing marker at " .. minetest.pos_to_string(pos) ..
            " because kingdom no longer exists")
            minetest.set_node(pos, {name = "air"})
            kingdoms.markers[hpos] = nil
            kingdoms.helpers.save()
         return
      end
      -- Check if name is correct
      local correct_name = "kingdoms:marker_" .. string.lower(k.color)
      if node.name ~= correct_name then -- Wrong color
         minetest.swap_node(pos, {name = correct_name})
      end
   end
})

-- Make markers actually protect things
local function new_is_protected(pos, name)
   -- Get the closest marker to pos within the marker radius
   local distsq
   local mindist
   local k
   for _,m in pairs(kingdoms.markers) do
      distsq = (m.pos.x - pos.x) ^ 2 + (m.pos.z - pos.z) ^ 2
      if distsq < kingdoms.marker_radius_sq then
         if mindist == nil or distsq < mindist then
            mindist = distsq
            k = m.kingdom
         end
      end
   end
   -- Check if area is protected at all
   if k == nil then -- No marker near enough was found
      return false
   end
   -- If name is nil, we can't check
   if name == nil then
      return true
   end
   -- Check if player has access to the area
   if kingdoms.members[name] == nil or kingdoms.members[name].kingdom ~= k then
      minetest.chat_send_player(name, "This area is protected by kingdom " .. k)
      return true
   end
   -- Check if player is allowed to interact
   if kingdoms.player_has_priv(name, "interact") ~= true then
      minetest.chat_send_player(name, "This area is protected by kingdom " .. k ..
         ", but you are not allowed to interact with it")
      return true
   end
   return false
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
   if new_is_protected(pos, name) then
      return true
   end
   return old_is_protected(pos, name)
end
