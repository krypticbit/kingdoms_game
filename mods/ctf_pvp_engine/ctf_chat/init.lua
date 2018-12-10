ctf.register_on_init(function()
	ctf.log("chat", "Initialising...")

	-- Settings: Chat
	ctf._set("chat.team_channel",          true)
	ctf._set("chat.global_channel",        true)
	ctf._set("chat.default",               "global")
end)

local function team_console_help(name)
	minetest.chat_send_player(name, "Try:")
	minetest.chat_send_player(name, "/team - show team panel")
	minetest.chat_send_player(name, "/team all - list all teams")
	minetest.chat_send_player(name, "/team <team> - show details about team 'name'")
	minetest.chat_send_player(name, "/team <name> - get which team 'player' is in")
	minetest.chat_send_player(name, "/team player <name> - get which team 'player' is in")
	minetest.chat_send_player(name, "/team add <team> - add a team called name")

	local privs = minetest.get_player_privs(name)
	if privs and privs.ctf_admin == true then
		minetest.chat_send_player(name, "/team remove <team> - add a team called name (ctf_admin only)")
		minetest.chat_send_player(name, "/team join <name> <team> - add 'player' to team 'team' (ctf_admin only)")
		minetest.chat_send_player(name, "/team removeply <name> - add 'player' to team 'team' (ctf_admin only)")
	end
end

minetest.register_chatcommand("team", {
	description = "Open the team console, or run team command (see /team help)",
	func = function(name, param)
		local test   = string.match(param, "^player ([%a%d_-]+)")
		local create = string.match(param, "^add ([%a%d_-]+)")
		local remove = string.match(param, "^remove ([%a%d_-]+)")
		local j_name, j_tname = string.match(param, "^join ([%a%d_-]+) ([%a%d_]+)")
		local l_name = string.match(param, "^removeplr ([%a%d_-]+)")
		if create then
			if ctf and ctf.players and ctf.players[name] and not ctf.players[name].team and not ctf.team(create) then
				if (
					string.match(create, "([%a%b_]-)")
					and create ~= ""
					and create ~= nil
					and ctf.team({name=create, add_team=true})
				) then
					ctf.join(name, create, false, name)
					ctf.player(name).auth = true
					minetest.chat_send_all(name.." was upgraded to an admin of "..create)
					return true, "Added team '"..create.."'"
				else
					return false, "Error adding team '"..create.."'"
				end
			else
				if ctf.team(create) then
					return false, "There is already a team with the name "..create
				else
					return false, "You need to leave your current team to create a new one."
				end
			end
		elseif remove then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_admin then
				if ctf.remove_team(remove) then
					return true, "Removed team '" .. remove .. "'"
				else
					return false, "Error removing team '" .. remove .. "'"
				end
			else
				return false, "You are not a ctf_admin!"
			end
		elseif param == "all" then
			ctf.list_teams(name)
		elseif ctf.team(param) then
			minetest.chat_send_player(name, "Team "..param..":")
			local count = 0
			for _, value in pairs(ctf.team(param).players) do
				count = count + 1
				if value.auth then
					minetest.chat_send_player(name, count .. ">> " .. value.name
							.. " (team owner)")
				elseif value.recruit then
					minetest.chat_send_player(name, count .. ">> " .. value.name
							.. " (team recruiter)")
				else
					minetest.chat_send_player(name, count .. ">> " .. value.name)
				end
			end
		elseif ctf.player_or_nil(param) or test then
			if not test then
				test = param
			end
			if ctf.player(test).team then
				if ctf.player(test).auth then
					return true, test ..
							" is in team " .. ctf.player(test).team.." (team owner)"
				elseif ctf.player(test).recruit then
					return true, test ..
							" is in team " .. ctf.player(test).team.." (team recruiter)"
				else
					return true, test ..
							" is in team " .. ctf.player(test).team
				end
			else
				return true, test.." is not in a team"
			end
		elseif j_name and j_tname then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_admin then
				if ctf.join(j_name, j_tname, true, name) then
					return true, "Successfully added " .. j_name .. " to " .. j_tname
				else
					return false, "Failed to add " .. j_name .. " to " .. j_tname
				end
			else
				return true, "You are not a ctf_admin!"
			end
		elseif l_name then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_admin then
				if ctf.remove_player(l_name) then
					return true, "Removed player " .. l_name
				else
					return false, "Failed to remove player."
				end
			else
				return false, "You are not a ctf_admin!"
			end
		elseif param=="help" then
			team_console_help(name)
		else
			if param ~= "" and param ~= nil then
				minetest.chat_send_player(name, "'"..param.."' is an invalid parameter to /team")
				team_console_help(name)
			end
			if ctf.setting("gui") then
				if (ctf and
						ctf.players and
						ctf.players[name] and
						ctf.players[name].team) then
					print("showing")
					ctf.gui.show(name)
					return true, "Showing the team window"
				else
					return false, "You're not part of a team!"
				end
			else
				return false, "GUI is disabled!"
			end
		end
		return false, "Nothing could be done"
	end
})

minetest.register_chatcommand("apply", {
	params = "teamname",
	description = "Apply to join to team",
	func = function(name, param)
		if ctf.application_join(name, param) then
			return true, "Application sent to team " .. param .. "!"
		else
			return false, "Failed to apply to team!"
		end
	end
})

minetest.register_chatcommand("accept", {
	params = "<applicant name>",
	description = "Accept an application",
	func = function(name, aname)
		local tplayer = ctf.player(name)
		if not tplayer.auth and not tplayer.recruit then
			return false, "You are not a team owner/recruiter!"
		end

		aname = aname:trim()
		if aname == "" then
			return false, "You must provide a player name!"
		end

		if not minetest.player_exists(aname) then
			return false, "Player '" .. aname .. "' doesn't exist!"
		end

		local aplayer = ctf.player(aname)
		if aplayer.team then
			return false, aname .. " is already in a team!"
		end

		if ctf.decide_application(aname, name, tplayer.team, "Accept") then
			return true, "Successfully recruited " .. aname ..
								" to " .. tplayer.team .. "!"
		else
			return false, "Failed to recruit " .. aname .. "!"
		end
	end
})

minetest.register_chatcommand("reject", {
	params = "<applicant name>",
	description = "Reject an application",
	func = function(name, aname)
		local tplayer = ctf.player(name)
		if not tplayer.auth and not tplayer.recruit then
			return false, "You are not a team owner/recruiter!"
		end

		aname = aname:trim()
		if aname == "" then
			return false, "You must provide a player name!"
		end

		if not minetest.player_exists(aname) then
			return false, "Player '" .. aname .. "' doesn't exist!"
		end

		local aplayer = ctf.player(aname)
		if aplayer.team then
			return false, aname .. " is already in a team!"
		end

		if ctf.decide_application(aname, name, tplayer.team) then
			return true, "Rejected " .. aname .. "'s application" ..
								" to join " .. tplayer.team .. "!"
		else
			return false, "Failed to reject " .. aname .. "'s application!"
		end
	end
})

minetest.register_chatcommand("list_applications", {
	description = "List all applications",
	func = function(name)
		local tplayer = ctf.player(name)

		if not tplayer.team then
			return false, "You are not in a team!"
		end

		if not tplayer.auth and not tplayer.recruit then
			return false, "You are not a team owner/recruiter!"
		end

		local team = ctf.team(tplayer.team)
		if #team.applications == 0 then
			return true, "No pending applications!"
		else
			local ret = "List of applicants for " .. tplayer.team .. ":\n"
			for i, aname in pairs(team.applications) do
				ret = ret .. "  " .. i .. ") " .. aname .. "\n"
			end
			ret = ret .. "(Use /accept <name> to accept, and /reject <name> to reject)"
			return true, ret
		end
	end
})

--[[
minetest.register_chatcommand("join", {
	params = "player name",
	description = "Add to team",
	func = function(name, param)
		local team = ctf.player(name).team
		if minetest.get_auth_handler().get_auth(param) == nil then
			return false, "Player '" .. param .. "' doesn't exist!"
		elseif ctf.player(param).team then
			return false, param .. " is already in a team!"
		else
		if ctf.player(name).auth or ctf.player(name).recruit then
				if ctf.join(param, team, false, name) then
					return true, "Joined " .. param .. " to " .. team .. "!"
				else
					return false, "Failed to join team!"
				end
			else
				return false, "You are not a team owner/recruiter!"
			end
		end
	end
})
--]]

minetest.register_chatcommand("teamkick", {
	params = "player name",
	description = "Kick player from your team",
	func = function(name, param)
	local team = ctf.player(name).team
	if ctf.player(param).team ~= team then
		return false, param .. " is not in your team!"
	else
	if ctf.player(name).auth or ctf.player(name).recruit then
		if ctf.player(param).auth or ctf.player(param).recuiter then
			return false, param.. " is a team owner or recruiter!"
		else
			if ctf.remove_player(param) then
				ctf.player(param).auth = false
				ctf.player(param).recuiter = false
				ctf.team(team).power = ctf.team(team).power - 1
				return true, "Kicked " .. param .. " from " .. team .. "!"
			else
				return false, "Failed to kick " .. param.. "!"
			end
		end
	else
		return false, "You are not the team owner!"
	end
end
end})

minetest.register_chatcommand("teamleave", {
	params = "none",
	description = "Leave your team",
	func = function(name, param)
	local team = ctf.player(name).team
	if ctf.player(name).team ~= nil then
		if ctf.remove_player(name) then
			ctf.player(name).auth = false
			ctf.player(name).recuiter = false
			ctf.team(team).power = ctf.team(team).power - 1
			-- Disband if there are zero players lefted on team
			local disband = true
			local teamdata = ctf.team(team)
			for username, player in pairs(teamdata.players) do
				disband = false
				break
			end
			if disband == true then
				if ctf.remove_team(team) then
					ctf.needs_save = true
					minetest.chat_send_all("team '" .. team .. "'" .. " disbanded " .. "from having zero players on team.")
				else
					minetest.chat_send_all("Error disbanding team '" .. team .. "'")
				end
			end
			return true, "You have left " .. team .. "!"
		else
			return false, "Failed to leave " .. team.. "!"
		end
	else
		return false, "You are not in a team!"
	end
end
})

minetest.register_chatcommand("teamdisband", {
	params = "none",
	description = "Disband your team",
	func = function(name, param)
	if ctf.player(name).auth or minetest.get_player_privs(name).ctf_admin then
		local team = ctf.player(name).team
		if ctf.remove_team(team) then
			ctf.needs_save = true
			return true, "team '" .. team .. "'" .. " disbanded."
		else
			return false, "Error disbanding team '" .. team .. "'"
		end
	else
		return false, "You are not a team_owner!"
	end
end
})

minetest.register_chatcommand("tc", {
	params = "msg",
	description = "Send a message to the team channel",
	func = function(name, param)
	local tname = ctf.player(name).team
	if ctf.player(name).team ~= nil then
		local team = ctf.team(tname)
		if team then
			local color, colorHex = ctf_colors.get_color(name,ctf.player(name))
			local playerslist = minetest.get_connected_players()
			for i in pairs(playerslist) do
				local realplayer = playerslist[i]
				if team.players[realplayer:get_player_name()] then
					minetest.chat_send_player(realplayer:get_player_name(),
							minetest.colorize("#" .. colorHex:sub(3, 8), "<" .. name .. "> ** " .. param .. " **"))
				end
			end
		end
	else
		return false, "You're not in a team, so you have no team to talk to."
	end
end
})

minetest.register_chatcommand("ac", {
	params = "msg",
	description = "Send a message to the alliance channel",
	func = function(name, param)
	local tname = ctf.player(name).team
	if ctf.player(name).team ~= nil then
		local team = ctf.team(tname)
		if team then
			local color, colorHex = ctf_colors.get_color(name,ctf.player(name))
			local playerslist = minetest.get_connected_players()
			for i in pairs(playerslist) do
				local realplayer = playerslist[i]
				local ot = ctf.player(realplayer:get_player_name()).team
				if ot then
					local diplo = ""
					if tname ~= ot then
						diplo = ctf.diplo.get(tname,ot)
					end
					if team.players[realplayer:get_player_name()] or diplo == "alliance" then
						minetest.chat_send_player(realplayer:get_player_name(),
								minetest.colorize("#" .. colorHex:sub(3, 8), "<" .. name .. "> ** " .. param .. " **"))
					end
				end
			end
		end
	else
		return false, "You're not in a team, so you have no team to talk to."
	end
end
})

--[[
minetest.register_chatcommand("join", {
	params = "player name",
	description = "Add to team",
	func = function(name, param)
		if ctf.join(name, param, false, name) then
			return true, "Joined team " .. param .. "!"
		else
			return false, "Failed to join team!"
		end
	end
})--]]

minetest.register_chatcommand("ctf_clean", {
	description = "Do admin cleaning stuff",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.log("chat", "Cleaning CTF...")
		ctf.clean_player_lists()
		if ctf_flag and ctf_flag.assert_flags then
			ctf_flag.assert_flags()
		end
		return true, "CTF cleaned!"
	end
})

minetest.register_chatcommand("ctf_reset", {
	description = "Delete all CTF saved states and start again.",
	privs = {ctf_admin=true},
	func = function(name, param)
		minetest.chat_send_all("The CTF core was reset by the admin. All team memberships," ..
				"flags, land ownerships etc have been deleted.")
		ctf.reset()
		return true, "Reset CTF core."
	end,
})

minetest.register_chatcommand("ctf_reload", {
	description = "reload the ctf main frame and get settings",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.needs_save = true
		ctf.init()
		return true, "CTF core reloaded!"
	end
})

minetest.register_chatcommand("ctf_ls", {
	description = "ctf: list settings",
	privs = {ctf_admin=true},
	func = function(name, param)
		minetest.chat_send_player(name, "Settings:")
		for set, def in orderedPairs(ctf._defsettings) do
			minetest.chat_send_player(name, " - " .. set .. ": " .. dump(ctf.setting(set)))
			print("\"" .. set .. "\"   " .. dump(ctf.setting(set)))
		end
		return true
	end
})

minetest.register_chatcommand("team_owner", {
	params = "player name",
	description = "Make player team owner",
	func = function(name, param)
		if ctf.player(name).auth or minetest.get_player_privs(name).ctf_admin then
			if ctf and ctf.players and ctf.player(param) and ctf.player(param).team and ctf.team(ctf.player(param).team) then
				if ctf.player(param).auth == true then
					ctf.player(param).auth = false
					return true, param.." was downgraded from team admin status"
				else
					ctf.player(param).auth = true
					return true, param.." was upgraded to an admin of "..ctf.player(name).team
				end
				ctf.needs_save = true
			else
				return false, "Unable to do that :/ "..param.." does not exist, or is not part of a valid team."
			end
		end
	end
})

minetest.register_chatcommand("team_recruiter", {
	params = "player name",
	description = "Make player able to recruit",
	func = function(name, param)
		if ctf.player(name).auth or minetest.get_player_privs(name).ctf_admin then
			if ctf and ctf.players and ctf.player(param) and ctf.player(param).team and ctf.team(ctf.player(param).team) then
				if ctf.player(param).recruit == true then
					ctf.player(param).recruit = false
					return true, param.." was downgraded from team recruiter status"
				else
					ctf.player(param).recruit = true
					return true, param.." was upgraded to a recruiter of "..ctf.player(name).team
				end
				ctf.needs_save = true
			else
				return false, "Unable to do that :/ "..param.." does not exist, or is not part of a valid team."
			end
		else
			return false, "You are not the team owner!"
		end
	end
})

minetest.register_chatcommand("post", {
	params = "message",
	description = "Post a message on your team's message board",
	func = function(name, param)
		if ctf and ctf.players and ctf.players[name] and ctf.players[name].team and ctf.teams[ctf.players[name].team] then
			if not ctf.player(name).auth then
				minetest.chat_send_player(name, "You do not own that team")
			end

			if not ctf.teams[ctf.players[name].team].log then
				ctf.teams[ctf.players[name].team].log = {}
			end

			table.insert(ctf.teams[ctf.players[name].team].log,{msg=param})

			minetest.chat_send_player(name, "Posted: "..param)
		else
			minetest.chat_send_player(name, "Could not post message")
		end
	end,
})

minetest.register_chatcommand("all", {
	params = "msg",
	description = "Send a message on the global channel",
	func = function(name, param)
		if not ctf.setting("chat.global_channel") then
			minetest.chat_send_player(name, "The global channel is disabled")
			return
		end

		if ctf.player(name).team then
			local tosend = ctf.player(name).team ..
				" <" .. name .. "> " .. param
			minetest.chat_send_all(tosend)
			if minetest.global_exists("chatplus") then
				chatplus.log(tosend)
			end
		else
			minetest.chat_send_all("<"..name.."> "..param)
		end
	end
})
--[[
minetest.register_chatcommand("t", {
	params = "msg",
	description = "Send a message on the team channel",
	func = function(name, param)
		if not ctf.setting("chat.team_channel") then
			minetest.chat_send_player(name, "The team channel is disabled.")
			return
		end

		local tname = ctf.player(name).team
		local team = ctf.team(tname)
		if team then
			minetest.log("action", tname .. "<" .. name .. "> ** ".. param .. " **")
			if minetest.global_exists("chatplus") then
				chatplus.log(tname .. "<" .. name .. "> ** ".. param .. " **")
			end
			for username, to in pairs(team.players) do
				minetest.chat_send_player(username,
						tname .. "<" .. name .. "> ** " .. param .. " **")
			end
			if minetest.global_exists("irc") and irc.feature_mod_channel then
				irc:say(irc.config.channel, tname .. "<" .. name .. "> ** " .. param .. " **", true)
			end
		else
			minetest.chat_send_player(name,
					"You're not in a team, so you have no team to talk to.")
		end
	end
})--]]

-- Chat plus stuff
if minetest.global_exists("chatplus") then
	function chatplus.log_message(from, msg)
		local tname = ctf.player(from).team or ""
		chatplus.log(tname .. "<" .. from .. "> " .. msg)
	end

	chatplus.register_handler(function(from, to, msg)
		if not ctf.setting("chat.team_channel") then
			-- Send to global
			return nil
		end

		if ctf.setting("chat.default") ~= "team" then
			if ctf.player(from).team then
				minetest.chat_send_player(to, ctf.player(from).team ..
					"<" .. from .. "> " .. msg)
				return false
			else
				return nil
			end
		end

		-- Send to team
		local fromp = ctf.player(from)
		local top = ctf.player(to)

		if not fromp.team then
			if not ctf.setting("chat.global_channel") then
				-- Send to global
				return nil
			else
				-- Global channel is disabled
				minetest.chat_send_player(from,
						"You are not yet part of a team! Join one so you can chat to people.",
						false)
				return false
			end
		end

		if top.team == fromp.team then
			minetest.chat_send_player(to, "<" .. from .. "> ** " .. msg .. " **")
		end
		return false
	end)
end
minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player,"ctf", "ctf")
end)
minetest.register_on_player_receive_fields(function(player, formname, fields)
if fields.ctf then
		ctf.gui.show(player:get_player_name())
	end
end)
