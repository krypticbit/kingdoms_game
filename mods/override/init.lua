local players = {}

minetest.register_on_joinplayer(function(player)
    minetest.after(0.5, function(player)
        if player:is_player_connected(name) then
            players[#players + 1] = player
        end
    end, player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
    for i = #players, 1, -1 do
        local n = players[i]:get_player_name()
        if n == name then
            players[i] = nil
        end
    end
end)

minetest.get_connected_players = function()
    return players
end
