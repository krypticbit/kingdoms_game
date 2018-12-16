-- 0 is the lowest priority
-- inf is the highest priority

local player_physics_table = {}

local function check_for_entry(pName)
	if player_physics_table[pName] == nil then
		local p = minetest.get_player_by_name(pName)
		if p then
			local pTable = p:get_physics_override()
		else
			local pTable = {speed = 1, jump = 1, gravity = 1, sneak = true, sneak_glitch = true, new_move = false}
		end
		player_physics_table[pName] = {default = {priority = 0, physics = pTable}}
	end
end

local function update_physics(player)
	local n = player:get_player_name()
	local requests = player_physics_table[n].physics
	local highestPriority = -1
	local highest = nil
	for id, pTable in pairs(requests) do
		if pTable.priority > highestPriority then
			highestPriority = pTable.priority
			highest = pTable.physics
		end
	end
	player:set_physics_override(highest)
end

function set_player_physics(player, phys, priority, id)
	local pName = player:get_player_name()
	check_for_entry(pName)
	player_physics_table[pName][id] = {priority = priority, physics = phys}
	update_physics(player)
end

function reset_player_physics(player, id)
	local pName = player:get_player_name()
	check_for_entry(pName)
	player_physics_table[pName][id] = nil
	update_physics(player)
end
