-- 0 is the lowest priority
-- inf is the highest priority

player_physics_table = {}
player_physics_multipliers = {}

local function check_for_entry(pName)
	if player_physics_table[pName] == nil then
		local pTable = {speed = 1, jump = 1, gravity = 1, sneak = true, sneak_glitch = true, new_move = false}
		player_physics_table[pName] = {default = {priority = 0, physics = pTable}}
	end
end

local function check_for_multiplier(pName)
	if player_physics_multipliers[pName] == nil then
		player_physics_multipliers[pName] = {}
	end
end

local function get_highest_priority(t, element)
	local highestPriority = -1
	local highest = nil
	for id, pTable in pairs(t) do
		if pTable.physics[element] ~= nil then
			if pTable.priority > highestPriority then
				highestPriority = pTable.priority
				highest = pTable.physics[element]
			end
		end
	end
	return highest, highestPriority
end

local function apply_physics_override(t, element, to)
	for id, pTable in pairs(t) do
		if pTable[element] ~= nil then
			to = pTable[element] * to
		end
	end
	return to
end

local function update_physics(player)
	-- Get player name
	local n = player:get_player_name()
	-- Get table of physics overrides
	local requests = player_physics_table[n]
   if requests == nil then return end
	-- Get active physics overrides
	local speed, speedP = get_highest_priority(requests, "speed")
	local jump, jumpP = get_highest_priority(requests, "jump")
	local gravity, gravityP = get_highest_priority(requests, "gravity")
	local sneak, _ = get_highest_priority(requests, "sneak")
	local sneak_glitch, _ = get_highest_priority(requests, "sneak_glitch")
	local new_move, _ = get_highest_priority(requests, "new_move")
	-- Apply multipliers
	local mults = player_physics_multipliers[n]
	if mults then
		speed = apply_physics_override(mults, "speed", speed)
		jump = apply_physics_override(mults, "jump", jump)
		gravity = apply_physics_override(mults, "gravity", gravity)
	end
	-- Condense final player physics
	local highest = {
	speed = speed,
	jump = jump,
	gravity = gravity,
	sneak = sneak,
	sneak_glitch = sneak_glitch,
	new_move = new_move,
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

function set_player_physics_multiplier(player, mults, id)
	local pName = player:get_player_name()
	check_for_entry(pName)
	check_for_multiplier(pName)
	player_physics_multipliers[pName][id] = mults
	update_physics(player)
end

function remove_player_physics_multiplier(player, id)
	local pName = player:get_player_name()
	check_for_entry(pName)
   check_for_multiplier(pName)
	player_physics_multipliers[pName][id] = nil
	update_physics(player)
end

-- Reset player physics when the player leaves
minetest.register_on_leaveplayer(function(player)
   local pName = player:get_player_name()
   player_physics_multipliers[pName] = nil
   player_physics_table[pName] = nil
end)
