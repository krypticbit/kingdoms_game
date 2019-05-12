local player_ghosts = {} -- Table of player postions a second ago
local players_glitching = {} -- Table of players using wifi glitch
local players_violating = {} -- Table of players violating protection
local timeout = tonumber(minetest.settings:get("protection_timeout")) or 2.0

-- Updates players_glitching and player_ghosts
local function step()
	for _, player in pairs(minetest.get_connected_players()) do
      -- Check if player is wifi glitching
		local name = player:get_player_name()
		local info = minetest.get_player_information(name)
		if name ~= nil and info ~= nil then
			if info.avg_jitter > timeout and not players_glitching[name] then
				players_glitching[name] = player:get_pos()
			elseif info.avg_jitter < timeout and players_glitching[name] then
				minetest.after(0.5, function() players_glitching[name] = nil end)
			end
		elseif name ~= nil then
			if not players_glitching[name] then
				players_glitching[name] = player:get_pos()
			end
		end
      -- Check if player is violating protection
      if players_violating[name] ~= nil then
         local diff = os.time() - players_violating[name]
         if diff > 2 then players_violating[name] = nil end
      end
      -- Set player ghost if the player is not violating protection
      if players_violating[name] == nil then
         player_ghosts[name] = player:get_pos()
      end
	end
	minetest.after(1, step)
end

minetest.register_on_leaveplayer(function(player)
   local n = player:get_player_name()
	players_glitching[n] = nil
   player_ghosts[n] = nil
end)

minetest.after(5, step)

-- Update players_violating
minetest.register_on_protection_violation(function(pos, name)
   players_violating[name] = os.time()
end)

-- Marker protection function
local function new_is_protected(pos, name)
   -- If the pos is below y = -50, it's not protected
   if pos.y < -50 then
      return false
   end
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

-- Protection implementation
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
   -- If wifi-glitching, everything is protected
   local g_pos = players_glitching[name]
	if g_pos then
		minetest.get_player_by_name(name):set_pos(g_pos)
		return true
	end
   -- Check if node if protected by a kingdom
   if new_is_protected(pos, name) then
      -- Node is protected => teleport back
      local p = minetest.get_player_by_name(name)
      if player_ghosts[name] then
         p:set_pos(player_ghosts[name])
      else
         p:set_pos(p:get_pos())
      end
      return true
   end
   -- Run other protection functions
   return old_is_protected(pos, name)
end
