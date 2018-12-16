-- This mod is used to protect nodes in the capture the flag game
ctf.register_on_init(function()
	ctf.log("chat", "Initialising...")

	-- Settings: Chat
	ctf._set("node_ownership",          true)
end)

players_glitching = {}

local function step()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local info = minetest.get_player_information(name)
		-- 2.0 seconds.
		if info.avg_jitter > 2.0 and not players_glitching[name] then
			players_glitching[name] = player:get_pos()
		elseif info.avg_jitter < 2.0 and players_glitching[name] then
			minetest.after(0.5, function() players_glitching[name] = nil end)
		end
	end
	minetest.after(1, step)
end

minetest.register_on_leaveplayer(function(player)
	players_glitching[player:get_player_name()] = nil
end)

minetest.after(5, step)

local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	if not ctf.setting("node_ownership") then
		return old_is_protected(pos, name)
	end
	
	local g_pos = players_glitching[name]
	if g_pos then
		minetest.get_player_by_name(name):set_pos(g_pos)
		return true
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
			minetest.chat_send_player(name, "You need to be white listed in-order to build on flag " .. f.name .. "'s land")
		else
			minetest.chat_send_player(name, "You need to be white listed in-order to build on this flag's land")
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
				player:set_pos({
					x = pla_pos.x,
					y = pla_pos.y + 0.8,
					z = pla_pos.z
				})
			else
				player:set_pos(pla_pos)
			end
		end
		minetest.chat_send_player(name, "You cannot dig on team "..team.."'s land")
		return true
	end
end
