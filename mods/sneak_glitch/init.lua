-- Enable the sneak glitch (horray!)

minetest.register_on_joinplayer(function(player)
	set_player_physics(player, {
		sneak_glitch = true,
		sneak = true,
		new_move = false}, 15, "enable sneak glitch")
end)
