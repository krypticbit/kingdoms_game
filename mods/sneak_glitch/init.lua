-- Enable the sneak glitch (horray!)

local use_old_code = minetest.settings:get_bool("sneak_glitch.use_old_code")
if use_old_code == nil then
	-- Default to the new sneak code
	use_old_code = false
end

minetest.register_on_joinplayer(function(player)
	set_player_physics(player, {
		sneak_glitch = true,
		sneak = true,
		new_move = not use_old_code}, 10, "enable sneak glitch")
end)
