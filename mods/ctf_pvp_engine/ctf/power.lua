local maxpowerPerFlag = 2
local powerIncreasePerActivePlayer = 0.1
local powerDecreaseWhenInactivePerFlag = 0.001

local function elementsInTable(t)
   local n = 0
   for _ in pairs(t) do n = n + 1 end
   return n
end

function ctf.get_team_maxpower(team)
   return elementsInTable(team.flags) * maxpowerPerFlag
end

function ctf.team_has_online_players(tName)
   for _, p in pairs(minetest.get_connected_players()) do
      local n = p:get_player_name()
      if ctf.players[n] and ctf.players[n].team == tName then
         return true
      end
   end
   return false
end

function ctf.on_power_tick()
   -- Modify team's power
   local active = {}
   local players = minetest.get_connected_players()
   for _, player in pairs(players) do
      local name = player:get_player_name()
      if ctf.players[name] and ctf.players[name].team then
         local tName = ctf.players[name].team
         if active[tName] == nil then
            active[tName] = 1
         else
            active[tName] = active[tName] + 1
         end
      end
   end
   for tName, t in pairs(ctf.teams) do
      if active[tName] == nil then
         t.power.power = t.power.power - powerDecreaseWhenInactivePerFlag * elementsInTable(t.flags)
         if t.power.power < 0 then
            t.power.power = 0
         end
      else
         t.power.power = t.power.power + active[tName] * powerIncreasePerActivePlayer
         if t.power.power > t.power.max_power then
            t.power.power = t.power.max_power
         end
      end
   end
   -- Save
   ctf.needs_save = true
   -- Update huds
   ctf.hud.updateAll()
end

-- Hud for power
ctf.hud.register_part(function(player, name, _)
   local pTeam = ctf.team(ctf.players[name].team)
   if pTeam then
      local powerStr = "Power: " .. pTeam.power.power .. "\nMax Power: " .. pTeam.power.max_power
      if ctf.hud:exists(player, "ctf:hud_power") then
         ctf.hud:change(player, "ctf:hud_power", "text", powerStr)
      else
         ctf.hud:add(player, "ctf:hud_power", {
				hud_elem_type = "text",
				position      = {x = 0, y = 1},
				scale         = {x = 1, y = 1},
				text          = powerStr,
            number        = 0xFFFFFF,
				offset        = {x = 5, y = -5},
				alignment     = {x = 1, y = -1}
			})
      end
   end
end)
