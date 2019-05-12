-- Make markers actually protect things
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

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
   if new_is_protected(pos, name) then
      return true
   end
   return old_is_protected(pos, name)
end
