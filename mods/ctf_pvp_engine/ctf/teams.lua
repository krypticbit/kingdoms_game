-- Get or add a team
function ctf.team(name)
	if name == nil then
		return nil
	end
	if type(name) == "table" then
		if not name.add_team then
			ctf.error("team", "Invalid table given to ctf.team")
			return
		end

		return ctf.create_team(name.name, name)
	else
		local team = ctf.teams[name]
		if team then
			--Migration to version with applications
			if not team.applications then
				team.applications = {}
			end
			if not team.data or not team.players then
				ctf.warning("team", "Assertion failed, data{} or players{} not " ..
						"found in team{}")
			end
			return team
		else
			if name and name:trim() ~= "" then
				ctf.warning("team", dump(name) .. " does not exist!")
			end
			return nil
		end
	end
end

function ctf.create_team(name, data)
	ctf.log("team", "Creating team " .. name)

	ctf.teams[name] = {
		data = data,
		spawn = nil,
		players = {},
		applications = {},
		access = {},
		power = 0
	}

	for i = 1, #ctf.registered_on_new_team do
		ctf.registered_on_new_team[i](ctf.teams[name])
	end

	ctf.needs_save = true

	return ctf.teams[name]
end

function ctf.remove_team(name)
	local team = ctf.team(name)
	if team then
		for username, player in pairs(team.players) do
			player.team = nil
		end
		for i = 1, #team.flags do
			team.flags[i].team = nil
		end
		ctf.teams[name] = nil
		ctf.access_remove_team_all(name)
		ctf.needs_save = true
		return true
	else
		return false
	end
end

function ctf.list_teams(name)
	minetest.chat_send_player(name, "Teams:")
	for tname, team in pairs(ctf.teams) do
		if team and team.players then
			local details = ""

			local numPlayers = ctf.count_players_in_team(tname)
			details = numPlayers .. " members"

			if team.flags then
				local numFlags = 0
				for flagid, flag in pairs(team.flags) do
					numFlags = numFlags + 1
				end
				details = details .. ", " .. numFlags .. " flags"
			end

			minetest.chat_send_player(name, ">> " .. tname ..
					" (" .. details .. ")")
		end
	end
end

-- Count number of players in a team
function ctf.count_players_in_team(team)
	local count = 0
	for name, player in pairs(ctf.team(team).players) do
		count = count + 1
	end
	return count
end

function ctf.new_player(name)
	if name then
		ctf.players[name] = {
			name = name
		}
	else
		ctf.error("team", "Can't create a blank player")
		ctf.log("team", debug.traceback())
	end
end

-- get a player
function ctf.player(name)
	if not ctf.players[name] then
		ctf.new_player(name)
	end
	return ctf.players[name]
end

function ctf.player_or_nil(name)
	return ctf.players[name]
end

function ctf.remove_player(name)
	ctf.log("team", "Removing player ".. dump(name))
	local player = ctf.players[name]
	if player then
		local team = ctf.team(player.team)
		if team then
			team.players[name] = nil
		end
		ctf.players[name] = nil
		ctf.needs_save = true
		return true
	else
		return false
	end
end

ctf.registered_on_join_team = {}
function ctf.register_on_join_team(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_join_team, func)
end

-- Player joins team
-- Called by /join, /team join or auto allocate.
ctf.registered_on_join_team = {}
function ctf.register_on_join_team(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_join_team, func)
end

-- Player makes an application to team manager to join a team
-- Called by /apply
function ctf.application_join(name, tname)
	if not name or name == "" or not tname or tname == "" then
		ctf.log("teams", "Missing parameters to ctf.request_join")
	end
	local player = ctf.player(name)
	
	if player.team and player.team == tname then
		minetest.chat_send_player(name, "You are already a member of team " .. tname)
		return false
	end
	
	if not ctf.setting("players_can_change_team") and player.team and ctf.team(player.team) then
		ctf.action("teams", name .. " requested to change to " .. tname)
		minetest.chat_send_player(name, "You are not allowed to switch teams, traitor!")
		return false
	end
	
	local team_data = ctf.team(tname)
	if not team_data then
		minetest.chat_send_player(name, "No such team.")
		ctf.list_teams(name)
		minetest.log("action", name .. " requested to join to " .. tname .. ", which doesn't exist")
		return false
	end
	
	table.insert(team_data.applications,name)
	--ctf.post(tname, {msg = name .. " has applied to join!" })
	ctf.needs_save = true
	return true
end

function ctf.decide_application(applicant_name, acceptor_name, team_name, decision)
	if not applicant_name then
		return false
	end
	local applicant = ctf.player(applicant_name)
	if not applicant then
		return false
	end
	if decision == "Accept" then
		if applicant.team and ctf.setting("players_can_change_team") then
			minetest.chat_send_player(acceptor_name, "Player " .. applicant_name .. " already a member of team " .. applicant.team)
		else
			ctf.join(applicant_name, team_name, true, acceptor_name)
			if not ctf.teams[team_name].log then
				ctf.teams[team_name].log = {}
			end
			table.insert(ctf.teams[team_name].log,{msg=applicant_name .. " was recruited " .. acceptor_name .. "!"})
		end
	end
	for key, field in pairs(ctf.teams) do
		ctf.delete_application(applicant_name, key)
	end
	remove_application_log_entry(team_name, applicant_name)
end

function ctf.delete_application(name, tname)
	if not name or name == "" or not tname or tname == "" then
		ctf.log("teams", "Missing parameters to ctf.delete_application")
	end
	local team = ctf.team(tname)
	if not team then
		minetest.chat_send_player(name, "No such team.")
		return false
	end
	for key, field in pairs(team.applications) do
		if field == name then
			table.remove(team.applications, key)
			ctf.needs_save = true
			return true
		end
	end
	return false
end

function ctf.gen_access_table(t)
	if not t.access then
		t.access = {}
	end
	if not t.access.players then
		t.access.players = {}
	end
	if not t.access.teams then
		t.access.teams = {}
	end
	if t.access.open == nil then
		t.access.open = true
	end
	return t
end

function ctf.access_add(team, flag, team_or_player)
	local t = ctf.team(team)
	if flag == "all" then
		t = ctf.gen_access_table(t)
		if team_or_player ~= team and ctf.team(team_or_player) then
			t.access.teams[team_or_player] = 1
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		end
		if ctf.players[team_or_player] then
			t.access.players[team_or_player] = 1
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		end
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				if team_or_player ~= team and ctf.team(team_or_player) then
					t.flags[i].access.teams[team_or_player] = 1
					ctf.needs_save = true
					return true
				end
				if ctf.players[team_or_player] then
					t.flags[i].access.players[team_or_player] = 1
					ctf.needs_save = true
					return true
				end
			end
		end
	end
	return false
end

function ctf.access_remove(team, flag, team_or_player)
	local t = ctf.team(team)
	if flag == "all" then
		t = ctf.gen_access_table(t)
		if team_or_player ~= team and ctf.team(team_or_player) then
			t.access.teams[team_or_player] = nil
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		end
		if ctf.players[team_or_player] then
			t.access.players[team_or_player] = nil
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		end
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
			t.flags[i] = ctf.gen_access_table(t.flags[i])
				if team_or_player ~= team and ctf.team(team_or_player) then
					t.flags[i].access.teams[team_or_player] = nil
					ctf.needs_save = true
					return true
				end
				if ctf.players[team_or_player] then
					t.flags[i].access.players[team_or_player] = nil
					ctf.needs_save = true
					return true
				end
			end
		end
	end
	return false
end

function ctf.access_clear(team, flag, team_or_player)
	local t = ctf.team(team)
	if flag == "all" then
		t = ctf.gen_access_table(t)
		if team_or_player == "all" then
			t.access.teams = {}
			t.access.players = {}
			for i = 1, #t.flags do
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				t.flags[i].access.teams = {}
				t.flags[i].access.players = {}
			end
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		elseif team_or_player == "teams" then
			t.access.teams = {}
			for i = 1, #t.flags do
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				t.flags[i].access.teams = {}
			end
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		elseif team_or_player == "players" then
			t.access.players = {}
			for i = 1, #t.flags do
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				t.flags[i].access.players = {}
			end
			ctf.teams[team] = t
			ctf.needs_save = true
			return true
		end
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				if team_or_player == "all" then
					t.flags[i].access.teams = {}
					t.flags[i].access.players = {}
					ctf.needs_save = true
					return true
				elseif team_or_player == "teams" then
					t.flags[i].access.teams = {}
					ctf.needs_save = true
					return true
				elseif team_or_player == "players" then
					t.flags[i].access.players = {}
					ctf.needs_save = true
					return true
				end
			end
		end
	end
	return false
end

function ctf.access_list(name, team, flag)
	local t = ctf.team(team)
	if flag == "all" then
		t = ctf.gen_access_table(t)
		minetest.chat_send_player(name,"Teams:")
		for i in pairs(t.access.teams) do
			minetest.chat_send_player(name,i .. " (all)")
		end
		for i = 1, #t.flags do
			t.flags[i] = ctf.gen_access_table(t.flags[i])
			for l in pairs(t.flags[i].access.teams) do
				minetest.chat_send_player(name, l .. " (" .. t.flags[i].name .. ")")
			end
		end
		minetest.chat_send_player(name,"Players:")
		for i in pairs(t.access.players) do
			minetest.chat_send_player(name, i .. " (all)")
		end
		for i = 1, #t.flags do
			t.flags[i] = ctf.gen_access_table(t.flags[i])
			for l in pairs(t.flags[i].access.players) do
				minetest.chat_send_player(name,l .. " (" .. t.flags[i].name .. ")")
			end
		end
		return true
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				minetest.chat_send_player(name,"Teams:")
				for l in pairs(t.flags[i].access.teams) do
					minetest.chat_send_player(name,l .. " (" .. t.flags[i].name .. ")")
				end
				minetest.chat_send_player(name,"Players:")
				for l in pairs(t.flags[i].access.players) do
					minetest.chat_send_player(name,l .. " (" .. t.flags[i].name .. ")")
				end
				return true
			end
		end
	end
	return false
end

function ctf.access_open(team, flag)
	local t = ctf.team(team)
	if flag == "all" then
		for i = 1, #t.flags do
			t.flags[i] = ctf.gen_access_table(t.flags[i])
			t.flags[i].access.open = true
			ctf.teams[team] = t
			ctf.needs_save = true
		end
		return true
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				t.flags[i].access.open = true
				ctf.needs_save = true
				return true
			end
		end
	end
	return false
end

function ctf.access_close(team, flag)
	local t = ctf.team(team)
	if flag == "all" then
		for i = 1, #t.flags do
			t.flags[i] = ctf.gen_access_table(t.flags[i])
			t.flags[i].access.open = false
			ctf.teams[team] = t
			ctf.needs_save = true
		end
		return true
	else
		for i = 1, #t.flags do
			if t.flags[i].name == flag then
				t.flags[i] = ctf.gen_access_table(t.flags[i])
				t.flags[i].access.open = false
				ctf.needs_save = true
				return true
			end
		end
	end
	return false
end

function ctf.access_remove_team_all(name)
	for i in pairs(ctf.teams) do
		local t = ctf.teams[i]
		t = ctf.gen_access_table(t)
		t.access.teams[name] = nil
		for i = 1, #t.flags do
			t.flags[i] = ctf.gen_access_table(t.flags[i])
			t.flags[i].access.teams[name] = nil
		end
		ctf.teams[i] = t
	end
	ctf.needs_save = true
end
 
-- Player joins team
-- Called by /join, /team join, auto allocate or by response of the team manager.
function ctf.join(name, team, force, by)
	if not name or name == "" or not team or team == "" then
		ctf.log("team", "Missing parameters to ctf.join")
		return false
	end

	local player = ctf.player(name)

	if not force and not ctf.setting("players_can_change_team")
			and player.team and ctf.team(player.team) then
		if by then
			if by == name then
				ctf.action("teams", name .. " attempted to change to " .. team)
				minetest.chat_send_player(by, "You are not allowed to switch teams, traitor!")
			else
				ctf.action("teams", by .. " attempted to change " .. name .. " to " .. team)
				minetest.chat_send_player(by, "Failed to add " .. name .. " to " .. team ..
						" as players_can_change_team = false")
			end
		else
			ctf.log("teams", "failed to add " .. name .. " to " .. team ..
					" as players_can_change_team = false")
		end
		return false
	end

	local team_data = ctf.team(team)
	if not team_data then
		if by then
			minetest.chat_send_player(by, "No such team.")
			ctf.list_teams(by)
			if by == name then
				minetest.log("action", by .. " tried to move " .. name .. " to " .. team .. ", which doesn't exist")
			else
				minetest.log("action", name .. " attempted to join " .. team .. ", which doesn't exist")
			end
		else
			ctf.log("teams", "failed to add " .. name .. " to " .. team ..
					" as team does not exist")
		end
		return false
	end

	if player.team then
		local oldteam = ctf.team(player.team)
		if oldteam then
			oldteam.players[player.name] = nil
		end
	end

	player.team = team
	team_data.players[player.name] = player
	
	ctf.team(team).power = ctf.team(team).power + 1
	
	ctf.needs_save = true

	minetest.log("action", name .. " joined team " .. team)
	minetest.chat_send_all(name.." has joined team "..team)

	for i = 1, #ctf.registered_on_join_team do
		ctf.registered_on_join_team[i](name, team)
	end
	return true
end

-- Cleans up the player lists
function ctf.clean_player_lists()
	ctf.log("utils", "Cleaning player lists")
	for _, str in pairs(ctf.players) do
		if str and str.team and ctf.teams[str.team] then
			ctf.log("utils", " - Adding player "..str.name.." to team "..str.team)
			ctf.teams[str.team].players[str.name] = str
		else
			ctf.log("utils", " - Skipping player "..str.name)
		end
	end
end

-- Sees if the player can change stuff in a team
function ctf.can_mod(player,team)
	local privs = minetest.get_player_privs(player)

	if privs then
		if privs.ctf_admin == true then
			return true
		end
	end

	if player and ctf.teams[team] and ctf.teams[team].players and ctf.teams[team].players[player] then
		if ctf.teams[team].players[player].auth == true then
			return true
		end
	end
	return false
end

-- post a message to a team board
function ctf.post(team, msg)
	if not ctf.team(team) then
		return false
	end

	if not ctf.team(team).log then
		ctf.team(team).log = {}
	end


	ctf.log("team", "message posted to team board")

	table.insert(ctf.team(team).log, 1, msg)
	ctf.needs_save = true

	return true
end

-- Automatic Allocation
function ctf.autoalloc(name, alloc_mode)
	if alloc_mode == 0 then
		return
	end
	local max_players = ctf.setting("maximum_in_team")

	local mtot = false -- more than one team
	for key, team in pairs(ctf.teams) do
		mtot = true
		break
	end
	if not mtot then
		ctf.error("autoalloc", "No teams to allocate " .. name .. " to!")
		return
	end

	if alloc_mode == 1 then
		local index = {}

		for key, team in pairs(ctf.teams) do
			if max_players == -1 or ctf.count_players_in_team(key) < max_players then
				table.insert(index, key)
			end
		end

		if #index == 0 then
			ctf.error("autoalloc", "No teams to join!")
		else
			return index[math.random(1, #index)]
		end
	elseif alloc_mode == 2 then
		local one = nil
		local one_count = -1
		local two = nil
		local two_count = -1
		for key, team in pairs(ctf.teams) do
			local count = ctf.count_players_in_team(key)
			if (max_players == -1 or count < max_players) then
				if count > one_count then
					two = one
					two_count = one_count
					one = key
					one_count = count
				end

				if count > two_count then
					two = key
					two_count = count
				end
			end
		end

		if not one and not two then
			ctf.error("autoalloc", "No teams to join!")
		elseif one and two then
			if math.random() > 0.5 then
				return one
			else
				return two
			end
		else
			if one then
				return one
			else
				return two
			end
		end
	elseif alloc_mode == 3 then
		local smallest = nil
		local smallest_count = 1000
		for key, team in pairs(ctf.teams) do
			local count = ctf.count_players_in_team(key)
			if not smallest or count < smallest_count then
				smallest = key
				smallest_count = count
			end
		end

		if not smallest then
			ctf.error("autoalloc", "No teams to join!")
		else
			return smallest
		end
	else
		ctf.error("autoalloc", "Unknown allocation mode: "..ctf.setting("allocate_mode"))
	end
end

-- updates the spawn position for a team
function ctf.get_spawn(team)
	if ctf.team(team) and ctf.team(team).spawn then
		return ctf.team(team).spawn
	else
		return nil
	end
end

function ctf.move_to_spawn(name)
	local player = minetest.get_player_by_name(name)
	local tplayer = ctf.player(name)
	if ctf.team(tplayer.team) then
		local spawn = ctf.get_spawn(tplayer.team)
		if spawn then
			player:moveto(spawn, false)
			return true
		end
	end
	return false
end
--[[
minetest.register_on_respawnplayer(function(player)
	if not player then
		return false
	end

	return ctf.move_to_spawn(player:get_player_name())
end)--]]

function ctf.get_territory_owner(pos)
	if pos.y < -100 then
		return nil
	end
	local pd = ctf.setting("flag.protect_distance")
	local pdSQ = pd * pd
	for tname, team in pairs(ctf.teams) do
		for f = 1, #team.flags do
			local fPos = team.flags[f]
			local diffX = fPos.x - pos.x
			local diffZ = fPos.z - pos.z
			local distSQ = diffX * diffX + diffZ * diffZ
			if distSQ < pdSQ then
				return tname, f
			end
		end
	end
end

minetest.register_on_newplayer(function(player)
	local alloc_mode = tonumber(ctf.setting("allocate_mode"))
	if alloc_mode == 0 then
		return
	end
	local name = player:get_player_name()
	local team = ctf.autoalloc(name, alloc_mode)
	if team then
		ctf.log("autoalloc", name .. " was allocated to " .. team)
		ctf.join(name, team)
		ctf.move_to_spawn(player:get_player_name())
	end
end)


minetest.register_on_joinplayer(function(player)
	if not ctf.setting("autoalloc_on_joinplayer") then
		return
	end

	local name = player:get_player_name()
	if ctf.team(ctf.player(name).team) then
		return
	end

	local alloc_mode = tonumber(ctf.setting("allocate_mode"))
	if alloc_mode == 0 then
		return
	end
	local team = ctf.autoalloc(name, alloc_mode)
	if team then
		ctf.log("autoalloc", name .. " was allocated to " .. team)
		ctf.join(name, team)
		ctf.move_to_spawn(player:get_player_name())
	end
end)

-- Disable friendly fire.
ctf.registered_on_killedplayer = {}
function ctf.register_on_killedplayer(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_killedplayer, func)
end
local dead_players = {}
minetest.register_on_respawnplayer(function(player)
	dead_players[player:get_player_name()] = nil
end)
minetest.register_on_joinplayer(function(player)
	dead_players[player:get_player_name()] = nil
end)
minetest.register_on_punchplayer(function(player, hitter,
		time_from_last_punch, tool_capabilities, dir, damage)
	if player and hitter then
		local to = ctf.player(player:get_player_name())
		local from = ctf.player(hitter:get_player_name())

		if dead_players[player:get_player_name()] then
			return
		end

		if to.team == from.team and to.team ~= "" and to.team ~= nil and to.name ~= from.name then
			minetest.chat_send_player(hitter:get_player_name(), player:get_player_name() .. " is on your team!")
			if not ctf.setting("friendly_fire") then
				return true
			end
		end

		if player:get_hp() - damage <= 0 then
			dead_players[player:get_player_name()] = true
			local wielded = hitter:get_wielded_item()
			local wname = wielded:get_name()
			print(wname)
			local type = "sword"
			if wname:sub(1, 8) == "shooter:" then
				if wname == "shooter:grenade" then
					type = "grenade"
				else
					type = "bullet"
				end
			end
			if tool_capabilities.damage_groups.grenade then
				type = "grenade"
			end
			for i = 1, #ctf.registered_on_killedplayer do
				ctf.registered_on_killedplayer[i](player:get_player_name(), hitter:get_player_name(), type)
			end
			return false
		end
	end
end)
