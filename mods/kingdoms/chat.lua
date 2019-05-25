-- Register "overlord" (kingdom-creater/modifier) priv
minetest.register_privilege("overlord", {
   description = "Can create / modifiy kingdoms",
   give_to_singleplayer = false
})

-- Admin kingdom commands
ChatCmdBuilder.new("kingdoms_admin", function(cmd)
   -- Add new kingdom
   cmd:sub("add :name:word", function(name, kingdom_name)
      return kingdoms.add_kingdom(kingdom_name, name)
   end)
   -- Add new kingdom with specified owner
   cmd:sub("add :name:word :king:word", function(_, kingdom_name, king)
      return kingdoms.add_kingdom(kingdom_name, king)
   end)
   -- Remove kingdom
   cmd:sub("remove :name:word", function(_, kingdom_name)
      return kingdoms.remove_kingdom(kingdom_name)
   end)
   -- Add player to kingdom
   cmd:sub("join :victim:word :kingdom:word", function(_, victim, kingdom)
      return kingdoms.add_player_to_kingdom(kingdom, victim)
   end)
   -- Remove player from kingdom
   cmd:sub("kick :victim:word", function(_, victim, _)
      return kingdoms.remove_player_from_kingdom(victim)
   end)
   -- Set player rank in kingdom
   cmd:sub("set_rank :victim:word :rank:word", function(_, victim, rank)
      return kingdoms.set_player_rank(victim, rank)
   end)
   -- Add rank to kingdom
   cmd:sub("add_rank :kingdom:word :rank:word", function(_, kingdom, rank)
      return kingdoms.add_rank(kingdom, rank)
   end)
   -- Add rank to kingdom with specified privs
   cmd:sub("add_rank :kingdom:word :rank:word :privs:text", function(_, kingdom, rank, privs)
      return kingdoms.add_rank(kingdom, rank, kingdoms.helpers.split_into_keys(privs))
   end)
   -- Change privs of rank
   cmd:sub("set_rank_privs :kingdom:word :rank:word :privs:text", function(_, kingdom, rank, privs)
      return kingdoms.set_rank_privs(kingdom, rank, kingdoms.helpers.split_into_keys(privs))
   end)
   -- Set rank as default rank (given to new recruits)
   cmd:sub("set_default_rank :kingdom:word :rank:word", function(_, kingdom, rank)
      return kingdoms.set_default_rank(kingdom, rank)
   end)
   -- Remove rank
   cmd:sub("remove_rank :kingdom:word :rank:word", function(_, kingdom, rank)
      return kingdoms.remove_rank(kingdom, rank)
   end)
   -- Toggle restriced setting (restricted = someone has to accept player request)
   cmd:sub("toggle_restricted :kingdom:word", function(_, kingdom)
      return kingdoms.toggle_restricted(kingdom)
   end)
   -- Set kingdom color
   cmd:sub("set_color :kingdom:word :color:word", function(_, kingdom, color)
      return kingdoms.set_color(kingdom, color)
   end)
end, {
   description = "Manage kingdoms (admins only)",
   privs = {overlord = true}
})

-- Player kingdoms comannds
ChatCmdBuilder.new("kingdoms", function(cmd)
   -- List kingdoms
   cmd:sub("list", function(_)
      local l = ""
      for n,k in pairs(kingdoms.kingdoms) do
         local mNum = kingdoms.helpers.count_table(k.members)
         l = l .. n .. ": " .. tostring(mNum) .. " member(s)\n"
      end
      return true, l
   end)
   -- Get info on kingdom
   cmd:sub("info kingdom :name:word", function(_, kingdom)
      local k = kingdoms.kingdoms[kingdom]
      -- Check if kingdom is valid
      if k == nil then
         return false, "Invalid kingdom " .. kingdom
      end
      -- Get info
      local info = "-- Kingdom " .. kingdom .. " --\n"
      -- Get members
      local numMembers = kingdoms.helpers.count_table(k.members)
      info = info .. tostring(numMembers) .. " Members: " .. kingdoms.helpers.keys_to_str(k.members) .. "\n"
      -- Get markers
      local numMarkers = 0
      for _,m in pairs(kingdoms.markers) do
         if m.kingdom == kingdom then numMarkers = numMarkers + 1 end
      end
      info = info .. tostring(numMarkers) .. " Markers\n"
      -- Get ranks
      local numRanks = kingdoms.helpers.count_table(k.ranks)
      info = info .. tostring(numRanks) .. " Ranks: " .. kingdoms.helpers.keys_to_str(k.ranks) .. "\n"
      info = info .. "Default Rank: " .. k.default_rank .. "\n"
      -- Get other info
      info = info .. "Restricted: " .. (k.restricted and "Yes" or "No") .. "\n"
      info = info .. "Color: " .. k.color
      return true, info
   end)
   -- Get info on players
   cmd:sub("info player :name:word", function(_, pname)
      local m = kingdoms.members[pname]
      -- Check if player is in a kingdom
      if m == nil then
         return false, "Player " .. pname .. " is not in a kingdom"
      end
      -- Get info
      local info = "-- Player " .. pname .. " --\n"
      info = info .. "Kingdom: " .. m.kingdom .. "\n"
      info = info .. "Rank: " .. m.rank .. "\n"
      return true, info
   end)
   -- Accept member into kingdom
   cmd:sub("accept :player:word", function(name, victim)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      local k = kingdoms.members[name].kingdom
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "recruiter") == false then
         return false, "You are not a recruiter"
      end
      -- Check if victim sent a request
      if kingdoms.pending[victim] ~= k then
         return false, "Player " .. victim .. " did not send a join request"
      end
      -- Join
      kingdoms.pending[victim] = nil
      kingdoms.helpers.save()
      return kingdoms.add_player_to_kingdom(k, victim)
   end)
   -- Apply to / join kingdom
   cmd:sub("join :kingdom:word", function(name, kingdom)
      -- Check if player is already in a kingdom
      if kingdoms.members[name] ~= nil then
         return false, "You are already in a kingdom"
      end
      -- Check if kingdom exists
      if kingdoms.kingdoms[kingdom] == nil then
         return false, "The kingdom " .. kingdom .. " does not exist"
      end
      -- Join or send request
      if kingdoms.kingdoms[kingdom].restricted then
         kingdoms.pending[name] = kingdom
         kingdoms.helpers.save()
         return true, "Your request has been sent to the kingdom " .. kingdom
      else
         return kingdoms.add_player_to_kingdom(kingdom, name)
      end
   end)
   -- Leave kingdom
   cmd:sub("leave", function(name)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Leave
      return kingdoms.remove_player_from_kingdom(name)
   end)
   -- Kick member
   cmd:sub("kick :player:word", function(name, victim)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if victim is in a kingdom
      if kingdoms.members[victim] == nil then
         return false, victim .. " is not in a kingdom"
      end
      -- Check if victim is in player's kingdom
      if kingdoms.members[victim].kingdom ~= kingdoms.members[name].kingdom then
         return false, victim .. " is not in your kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "recruiter") == false then
         return false, "You are not a recruiter"
      end
      -- Kick
      return kingdoms.remove_player_from_kingdom(victim)
   end)
   -- Set player rank in kingdom
   cmd:sub("set_rank :victim:word :rank:word", function(name, victim, rank)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if victim is in a kingdom
      if kingdoms.members[victim] == nil then
         return false, victim .. " is not in a kingdom"
      end
      -- Check if victim is in player's kingdom
      if kingdoms.members[victim].kingdom ~= kingdoms.members[name].kingdom then
         return false, victim .. " is not in your kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Set player's rank
      return kingdoms.set_player_rank(victim, rank)
   end)
   -- Add rank to kingdom
   cmd:sub("add_rank :rank:word", function(name, rank)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Add rank
      return kingdoms.add_rank(kingdoms.members[name].kingdom, rank)
   end)
   -- Add rank to kingdom with specified privs
   cmd:sub("add_rank :rank:word :privs:text", function(name, rank, privs)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Add rank
      return kingdoms.add_rank(kingdoms.members[name].kingdom, rank, kingdoms.helpers.split_into_keys(privs))
   end)
   -- Change privs of rank
   cmd:sub("set_rank_privs :rank:word :privs:text", function(name, rank, privs)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Change privs
      return kingdoms.set_rank_privs(kingdoms.members[name].kingdom, rank, kingdoms.helpers.split_into_keys(privs))
   end)
   -- Get privs of rank
   cmd:sub("get_rank_privs :rank:word", function(name, rank)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if rank is valid
      local rtable = kingdoms.kingdoms[kingdoms.members[name].kingdom].ranks
      if rtable[rank] == nil then
         return false, "Invalid rank " .. rank
      end
      -- Get privs
      return true, "Privs of rank " .. rank .. ": " .. kingdoms.helpers.keys_to_str(rtable[rank])
   end)
   -- Set rank as default rank (given to new recruits)
   cmd:sub("set_default_rank :rank:word", function(name, rank)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Set rank as default
      return kingdoms.set_default_rank(kingdoms.members[name].kingdom, rank)
   end)
   -- Remove rank
   cmd:sub("remove_rank :rank:word", function(name, rank)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "rank_master") == false then
         return false, "You are not a rank master"
      end
      -- Remove rank
      return kingdoms.remove_rank(kingdoms.members[name].kingdom, rank)
   end)
   -- Toggle restriced setting (restricted = someone has to accept player request)
   cmd:sub("toggle_restricted", function(name)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "recruiter") == false then
         return false, "You are not a recruiter"
      end
      -- Toggle
      return kingdoms.toggle_restricted(kingdoms.members[name].kingdom)
   end)
   -- Set team color
   cmd:sub("set_color :color:word", function(name, color)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player has necessary privs
      if kingdoms.player_has_priv(name, "admin") == false then
         return false, "You are not a kingdom administrator"
      end
      -- Check if color is valid
      if kingdoms.colors[color] == nil then
         return false, "Invalid color.  Valid colors are: " .. kingdoms.helpers.keys_to_str(kingdoms.colors)
      end
      -- Set color
      return kingdoms.set_color(kingdoms.members[name].kingdom, color)
   end)
   -- Help menu
   cmd:sub("help", function(name)
      return true, "Usage: \"/kingdoms <command>\" Commands:\n" ..
         "info player|kingdom <name>: Gets info about player or kingdom\n" ..
         "accept <name>: Accept player into kingdom (The player must have applied previously)\n" ..
         "join <kingdom>: Join a kingdom or send a join request\n" ..
         "leave: Leave a kingdom\n" ..
         "kick <name>: Kick a player from your kingdom\n" ..
         "set_rank <name> <rank>: Set the rank of a player\n" ..
         "add_rank <rank> [<rank privs>]: Add rank with default privs or <rank privs> if specified\n" ..
         "set_rank_privs <rank> <privs>: Set the privs of a rank\n" ..
         "get_rank_privs <rank>: Get the privs of a rank\n" ..
         "set_default_rank <rank>: Set a rank as default (given to new teammates)\n" ..
         "remove_rank <rank>: Remove a rank\n" ..
         "toggle_restricted: Toggle restricted status (restricted = player has to request to join)\n" ..
         "set_color <color>: Set kingdom color (Leave <color> blank for a list of all colors)"
   end)
   -- Bring up kingdoms gui
   cmd:sub("", function(name)
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      kingdoms.set_gui(name, "news")
   end)
end)

-- Alias /k to /kingdoms
minetest.register_chatcommand("k", {
   params = "<arguments>",
   description = "Alias for /kingdoms",
   privs = {},
   func = function(name, arg)
      return minetest.registered_chatcommands["kingdoms"].func(name, arg)
   end
})

-- Team chat
minetest.register_chatcommand("tc", {
   params = "<msg>",
   description = "Chat with teammates only",
   privs = {shout = true},
   func = function(name, msg)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player had a message
      if msg == nil or msg == "" then
         return false
      end
      -- Get kingdom
      local k = kingdoms.members[name].kingdom
      msg = "[Team Chat] <" .. name .. "> " .. msg
      -- Send to teammates
      for _,pname in pairs(kingdoms.helpers.get_online_members(k)) do
         minetest.chat_send_player(pname, msg)
      end
      -- Log
      minetest.log("action", k .. " " .. msg)
   end
})

-- Alliance chat
minetest.register_chatcommand("ac", {
   params = "<msg>",
   description = "Chat with teammates of allied teams only",
   privs = {shout = true},
   func = function(name, msg)
      -- Check if player is in a kingdom
      if kingdoms.members[name] == nil then
         return false, "You are not in a kingdom"
      end
      -- Check if player had a message
      if msg == nil or msg == "" then
         return false
      end
      -- Get kingdom
      local k = kingdoms.members[name].kingdom
      msg = "[Alliance Chat] <" .. name .. "> " .. msg
      -- Send to teammates
      for _,p in pairs(minetest.get_connected_players()) do
         local pname = p:get_player_name()
         if kingdoms.members[pname] then
            local r = kingdoms.get_relation(kingdoms.members[pname].kingdom, k)
            if (kingdoms.members[pname].kingdom == k
            or (r.id == kingdoms.relations.alliance and r.pending == nil)) then
               minetest.chat_send_player(pname, msg)
            end
         end
      end
      -- Log
      minetest.log("action", k .. " " .. msg)
   end
})

-- Grief check
minetest.register_chatcommand("grief_check", {
	params = "[<range>] [<hours>] [<limit>]",
	description = "Check who last touched a node or a node near it"
			.. " within the time specified by <hours>. Default: range = 0,"
			.. " hours = 24 = 1d, limit = 5",
	privs = {interact=true},
	func = function(name, param)
		if not minetest.setting_getbool("enable_rollback_recording") then
			return false, "Rollback functions are disabled."
		end
		local range, hours, limit =
			param:match("(%d+) *(%d*) *(%d*)")
		range = tonumber(range) or 0
		hours = tonumber(hours) or 24
		limit = tonumber(limit) or 5
		if range > 10 then
			return false, "That range is too high! (max 10)"
		end
		if hours > 168 then
			return false, "That time limit is too high! (max 168: 7 days)"
		end
		if limit > 100 then
			return false, "That limit is too high! (max 100)"
		end
		local seconds = (hours*60)*60
		minetest.rollback_punch_callbacks[name] = function(pos, node, puncher)
			local name = puncher:get_player_name()
			minetest.chat_send_player(name, "Checking " .. minetest.pos_to_string(pos) .. "...")
			local actions = minetest.rollback_get_node_actions(pos, range, seconds, limit)
			if not actions then
				minetest.chat_send_player(name, "Rollback functions are disabled")
				return
			end
			local num_actions = #actions
			if num_actions == 0 then
				minetest.chat_send_player(name, "Nobody has touched"
						.. " the specified location in " .. hours .. " hour(s)")
				return
			end
			local time = os.time()
			for i = num_actions, 1, -1 do
				local action = actions[i]
				minetest.chat_send_player(name,
					("%s %s %s -> %s %d seconds ago.")
						:format(
							minetest.pos_to_string(action.pos),
							action.actor,
							action.oldnode.name,
							action.newnode.name,
							time - action.time))
			end
		end

		return true, "Punch a node (range=" .. range .. ", hours="
				.. hours .. "s, limit=" .. limit .. ")"
	end,
})
