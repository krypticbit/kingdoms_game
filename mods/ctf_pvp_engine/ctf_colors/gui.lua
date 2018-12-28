
ctf.gui.register_tab("settings", "Settings", function(name, team)
	local tcolor = ctf.team(team).data.color
	local index = 1
	local colors = {}

	-- Convert list into numerically-indexed array
	-- for obtaining it's size and index of matching color
	for color, _ in pairs(ctf.flag_colors) do
		table.insert(colors, color)
		if color == tcolor then
			index = #colors
		end
	end

	local fs
	if not ctf.can_mod(name,team) then
		fs = "label[0.5,1;You do not own this team!]"
	else
		fs = "label[3,1.5;Team color]"
			.. "dropdown[3,2;4;color;" .. table.concat(colors, ",")
			.. ";" .. index .. "]" .. "button[4,6;2,1;save;Save]"
	end
	fs = "size[10,7]" .. ctf.gui.get_tabs(name, team) .. fs
	minetest.show_formspec(name, "ctf:settings", fs)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "ctf:settings" then
		return false
	end

	-- Settings page
	if fields.save then
		local name = player:get_player_name()
		local pdata = ctf.player(name)
		local team = ctf.team(pdata.team)

		ctf.gui.show(name, "settings")
		if team and ctf.can_mod(name, pdata.team) then
			if team.data.color ~= fields.color then
				team.data.color = fields.color
				ctf.needs_save = true
				minetest.chat_send_player(name, "Team color set to " .. fields.color)
			end
		elseif team then
			minetest.chat_send_player(name, "You don't have the necessary " ..
											"privileges to change team settings.")
		else
			minetest.chat_send_player(name, "You are not in a team!")
		end

		return true
	end
end)
