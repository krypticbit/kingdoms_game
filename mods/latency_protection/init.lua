players_glitching = {}

local timeout = tonumber(minetest.settings:get("protection_timeout")) or 2.0

local function step()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local info = minetest.get_player_information(name)
		if name ~= nil and info ~= nil then
			if info.avg_jitter > timeout and not players_glitching[name] then
				players_glitching[name] = player:get_pos()
			elseif info.avg_jitter < timeout and players_glitching[name] then
				minetest.after(0.5, function() players_glitching[name] = nil end)
			end
		elseif name ~= nil then
			if not players_glitching[name] then
				players_glitching[name] = player:get_pos()
			end
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
	local g_pos = players_glitching[name]
	if g_pos then
		minetest.get_player_by_name(name):set_pos(g_pos)
		return true
	end
	return old_is_protected(pos, name)
end