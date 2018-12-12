local marker = {}

minetest.register_chatcommand("mrkr", {
	params = "<x> <y> <z>",
	description = "Adds a waypoint marker at the selected position.",
	privs = {interact = true},
	func = function(name, param)
		local x, y, z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		local player = minetest.get_player_by_name(name)

		if (not x or not y or not z) and param ~= "" then
			return false, "You must provide 3 coordinates!"
		elseif param == "" then
			local pos = vector.round(player:get_pos())

			x = pos.x
			y = pos.y
			z = pos.z
		end
		
		if marker[name] then
			player:hud_remove(marker[name])
			marker[name] = nil
		end

		marker[name] = player:hud_add({
			hud_elem_type = "waypoint",
			name = x .. ", " .. y .. ", " .. z,
			number = 0xFF0000,
			world_pos = {x = x, y = y, z = z}
		})

		minetest.chat_send_player(name, "Marker set to: "..x..", "..y..", "..z)
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
			player:hud_remove(marker[name])
			marker[name] = nil
			minetest.chat_send_player(name, "Marker removed")
		end
		return true
	end
})

minetest.register_chatcommand("marker",
								minetest.registered_chatcommands["mrkr"])
minetest.register_chatcommand("clearmarker",
								minetest.registered_chatcommands["clrmrkr"])

minetest.register_on_leaveplayer(function(player)
	marker[player:get_player_name()] = nil
end)

