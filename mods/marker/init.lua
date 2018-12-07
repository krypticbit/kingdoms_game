local marker = {}

minetest.register_chatcommand("mrkr", {
	params = "<x> <y> <z>",
	description = "Adds a waypoint marker at the selected position.",
	privs = {interact = true},
	func = function(name, param)
		local x, y, z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		local player = minetest.get_player_by_name(name)
		if not x or not y or not z then
			return false, "You must provide 3 coordinates!"
		end

		if marker[name] then
			player:hud_change(marker[name], "name", x .. ", " .. y .. ", " .. z)
			player:hud_change(marker[name], "world_pos", {x = x, y = y, z = z})
		else
			marker[name] = player:hud_add({
				hud_elem_type = "waypoint",
				name = x .. ", " .. y .. ", " .. z,
				number = 0xFF0000,
				world_pos = {x = x, y = y, z = z}
			})
		end
		return true
	end
})

minetest.register_chatcommand("clrmrkr", {
	params = "",
	description = "Removes the marker waypoint.",
	privs = {},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player and marker[name] then
			if player:hud_remove(marker[name]) then
				marker[name] = nil
			end
		end
		return true
	end
})

minetest.register_chatcommand("marker",
								minetest.registered_chatcommands["mrkr"])
minetest.register_chatcommand("clearmarker",
								minetest.registered_chatcommands["clrmrkr"])
