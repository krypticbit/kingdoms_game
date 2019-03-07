-- Keep these for backwards compatibility
function hud.save_hunger(player)
	hud.set_hunger(player)
end
function hud.load_hunger(player)
	hud.get_hunger(player)
end

-- Poison player
local function poisenp(tick, time, time_left, player)
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	else
		--reset hud image
	end
	if player:get_hp()-1 > 0 then
		player:set_hp(player:get_hp()-1)
	end

end

function minetest.do_item_eat(hunger_change, replace_with_item, itemstack, user, pointed_thing)
	if itemstack:take_item() ~= nil and user ~= nil then
		local name = user:get_player_name()
		local h = tonumber(hud.hunger[name])
		local hp = user:get_hp()

		-- Saturation
		if h < 30 then
			h = h + hunger_change
			if h > 30 then h = 30 end
			hud.hunger[name] = h
			hud.set_hunger(user)
		end

		local player_inv = user:get_inventory()
		player_inv:add_item("main", replace_with_item)

		return itemstack
   end
end

-- player-action based hunger changes
function hud.handle_node_actions(pos, oldnode, player, ext)
	if not player or not player:is_player() then
		return
	end
	local name = player:get_player_name()
	local exhaus = hud.exhaustion[name]
	local new = HUD_HUNGER_EXHAUST_PLACE
	-- placenode event
	if not ext then
		new = HUD_HUNGER_EXHAUST_DIG
	end
	-- assume its send by main timer when movement detected
	if not pos and not oldnode then
		new = HUD_HUNGER_EXHAUST_MOVE
	end
	exhaus = exhaus + new
	if exhaus > HUD_HUNGER_EXHAUST_LVL then
		exhaus = 0
		local h = tonumber(hud.hunger[name])
		h = h - 1
		if h < 0 then h = 0 end
		hud.hunger[name] = h
		hud.set_hunger(player)
	end
	hud.exhaustion[name] = exhaus
end

minetest.register_on_placenode(hud.handle_node_actions)
minetest.register_on_dignode(hud.handle_node_actions)
