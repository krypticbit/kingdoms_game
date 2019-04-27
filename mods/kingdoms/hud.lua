local kingdoms_hudids = {}

function kingdoms.update_hud(p)
   -- Get name and obj
   local name
   local player
   if type(p) == "string" then
      name = p
      player = minetest.get_player_by_name(p)
      if player == nil then return end
   else
      player = p
      name = p:get_player_name()
   end
   -- Get message
   local msg
   if kingdoms.members[name] == nil then
      msg = "You are not in a kingdom"
   else
      msg = "Kingdom " .. kingdoms.members[name].kingdom
   end
   -- If the player already has a hud elem, update it.
   -- Otherwise, create it
   if kingdoms_hudids[name] == nil then
      local id = player:hud_add({
         hud_elem_type = "text",
         position = {x = 1, y = 0},
         offset = {x = -20, y = 20},
         text = msg,
         alignment = {x = -1, y = 0},
         scale = {x = 100, y = 30},
         number = 0xFFFFFF
      })
      kingdoms_hudids[name] = id
   else
      player:hud_change(kingdoms_hudids[name], "text", msg)
   end
end

minetest.register_on_joinplayer(kingdoms.update_hud)

minetest.register_on_leaveplayer(function(p)
   kingdoms_hudids[p:get_player_name()] = nil
end)
