-- 0 is the lowest priority
-- inf is the highest priority

player_physics_table = {}

local function check_for_entry(pName)
	if player_physics_table[pName] == nil then
		local pTable = {speed = 1, jump = 1, gravity = 1, sneak = true, sneak_glitch = true, new_move = false}
		player_physics_table[pName] = {default = {priority = 0, physics = pTable}}
	end
end

local function get_highest_priority(t, element)
	local highestPriority = -1
	local highest = nil
	for id, pTable in pairs(t) do
		if pTable.physics[element] then
			if pTable.priority > highestPriority then
				highestPriority = pTable.priority
				highest = pTable.physics[element]
			end
		end
	end
	return highest
end

local function update_physics(player)
	local n = player:get_player_name()
	local requests = player_physics_table[n]
	local speed = get_highest_priority(requests, "speed")
	local jump = get_highest_priority(requests, "jump")
	local gravity = get_highest_priority(requests, "gravity")
	local sneak = get_highest_priority(requests, "sneak")
	local sneak_glitch = get_highest_priority(requests, "sneak_glitch")
	local new_move = get_highest_priority(requests, "new_move")
	local highest = {
	speed = speed,
	jump = jump,
	gravity = gravity,
	sneak = sneak,
	sneak_glitch = sneak_glitch,
	new_move = new_move
	}
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
