-- This mod is used to protect nodes in the capture the flag game
ctf.register_on_init(function()
	ctf.log("chat", "Initialising...")

	-- Settings: Chat
	ctf._set("node_ownership",          true)
end)

local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	if not ctf.setting("node_ownership") then
		return old_is_protected(pos, name)
	end
	
	local team, index = ctf.get_territory_owner(pos)

	if not team or not ctf.team(team) then
		return old_is_protected(pos, name)
	end
	
	local player_team = ctf.player(name).team
	if player_team == team then
		local t = ctf.team(team)
		local f = t.flags[index]
		t = ctf.gen_access_table(t)
		f = ctf.gen_access_table(f)
		ctf.teams[team] = t
		t.flags[index] = f
		if not f.access or f.access.teams[player_team] or f.access.players[name] or f.access.open == true or not t.access or t.access.teams[player_team] or t.access.players[name] then
			return old_is_protected(pos, name)
		end
		if f.name then 
			minetest.chat_send_player(name, "You need to be white listed in-order to interact on flag " .. f.name .. "'s land")
		else
			minetest.chat_send_player(name, "You need to be white listed in-order to interact on this flag's land")
		end
		return true
	else
		local player = minetest.get_player_by_name(name)
		if player then
			local t = ctf.team(team)
			local f = t.flags[index]
			t = ctf.gen_access_table(t)
			f = ctf.gen_access_table(f)
			ctf.teams[team] = t
			t.flags[index] = f
			if (t.access and (t.access.teams[player_team] or t.access.players[name])) or (f.access and (f.access.teams[player_team] or f.access.players[name])) then
				return old_is_protected(pos, name)
			end
			--[[ yaw + 180°
			local yaw = player:get_look_horizontal() + math.pi
			if yaw > 2 * math.pi then
				yaw = yaw - 2 * math.pi
			end
			player:set_look_yaw(yaw)

			-- invert pitch
			player:set_look_vertical(-player:get_look_vertical())
			--]]
			-- if digging below player, move up to avoid falling through hole
			local pla_pos = player:get_pos()

			if pos.y < pla_pos.y then
				player:setpos({
					x = pla_pos.x,
					y = pla_pos.y + 0.8,
					z = pla_pos.z
				})
			else
				player:setpos(pla_pos)
			end
		end
		minetest.chat_send_player(name, "You cannot interact on team "..team.."'s land")
		return true
	end
end
