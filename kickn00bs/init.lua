minetest.register_on_joinplayer(function(player)
        if string.match(player:get_player_name(), "%D+%d%d%d") ~= nil then
           minetest.kick_player(player:get_player_name(), "Please use the official Minetest client.")
           end
end)
