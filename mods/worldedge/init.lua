local edge = 100
local step_time = 5

local function step()
   for _, p in pairs(minetest.get_connected_players()) do
      local pos = p:get_pos()
      local do_set = false
      if pos.x > edge then
         pos.x = edge - 10
         do_set = true
      elseif pos.x < -edge then
         pos.x = -edge + 10
         do_set = true
      end
      if pos.z > edge then
         pos.z = edge - 10
         do_set = true
      elseif pos.z < -edge then
         pos.z = -edge + 10
         do_set = true
      end
      if do_set then
         p:set_pos(pos)
         minetest.chat_send_player(p:get_player_name(), "You cannot go any father away from spawn")
      end
   end
   minetest.after(step_time, step)
end

minetest.after(step_time, step)
