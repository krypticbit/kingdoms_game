-- Mostly written by tenplus1, tweaked by BillyS

minetest.register_node("kingdoms:protected_chest", {
	description = "Protected Chest",
	tiles = {
		"default_chest_top.png", "default_chest_top.png",
		"default_chest_side.png", "default_chest_side.png",
		"default_chest_side.png", "kingdoms_chest_protected_front.png"
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, unbreakable = 1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		meta:set_string("infotext", "Protected Chest")
		meta:set_string("name", "")
		inv:set_size("main", 8 * 4)
	end,

	can_dig = function(pos,player)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:is_empty("main") then

			if not minetest.is_protected(pos, player:get_player_name()) then
				return true
			end
		end
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		minetest.log("action", player:get_player_name() .. " moves stuff to protected chest at " ..
         minetest.pos_to_string(pos))
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		minetest.log("action", player:get_player_name() .. " takes stuff from protected chest at " ..
         minetest.pos_to_string(pos))
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)

		minetest.log("action", player:get_player_name() .. " moves stuff inside protected chest at " ..
         minetest.pos_to_string(pos))
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)

		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return count
	end,

	on_rightclick = function(pos, node, clicker)

		if minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then
			return
		end

		local spos = pos.x .. "," .. pos.y .. "," ..pos.z
		local formspec = "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "list[nodemeta:".. spos .. ";main;0,0.3;8,4;]"
			.. "button[0,4.5;2,0.25;toup;To Chest]"
			.. "field[2.3,4.8;4,0.25;chestname;;"
			.. meta:get_string("name") .. "]"
			.. "button[6,4.5;2,0.25;todn;To Inventory]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.08;8,3;8]"
			.. "listring[nodemeta:" .. spos .. ";main]"
			.. "listring[current_player;main]"

			minetest.show_formspec(
				clicker:get_player_name(),
				"kingdoms:protected_chest_" .. minetest.pos_to_string(pos),
				formspec)
	end,

	on_blast = function() end,
})

-- Protected Chest formspec buttons

minetest.register_on_player_receive_fields(function(player, formname, fields)

	if string.sub(formname, 0, string.len("kingdoms:protected_chest_")) ~= "kingdoms:protected_chest_" then
		return
	end

	local pos_s = string.sub(formname,string.len("kingdoms:protected_chest_") + 1)
	local pos = minetest.string_to_pos(pos_s)

	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = minetest.get_meta(pos) ; if not meta then return end
	local chest_inv = meta:get_inventory() ; if not chest_inv then return end
	local player_inv = player:get_inventory()
	local leftover

	if fields.toup then

		-- copy contents of players inventory to chest
		for i, v in ipairs(player_inv:get_list("main") or {}) do

			if chest_inv:room_for_item("main", v) then

				leftover = chest_inv:add_item("main", v)

				player_inv:remove_item("main", v)

				if leftover
				and not leftover:is_empty() then
					player_inv:add_item("main", v)
				end
			end
		end

	elseif fields.todn then

		-- copy contents of chest to players inventory
		for i, v in ipairs(chest_inv:get_list("main") or {}) do

			if player_inv:room_for_item("main", v) then

				leftover = player_inv:add_item("main", v)

				chest_inv:remove_item("main", v)

				if leftover
				and not leftover:is_empty() then
					chest_inv:add_item("main", v)
				end
			end
		end

	elseif fields.chestname then

		-- change chest infotext to display name
		if fields.chestname ~= "" then

			meta:set_string("name", fields.chestname)
			meta:set_string("infotext",
				"Protected Chest (" .. fields.chestname .. ")")
		else
			meta:set_string("infotext", "Protected Chest")
		end

	end
end)

-- Craft recipes
minetest.register_craft({
   output = "kingdoms:protected_chest",
   recipe = {
      {"group:wood", "group:wood", "group:wood"},
      {"group:wood", "default:copper_ingot", "group:wood"},
      {"group:wood", "group:wood", "group:wood"}
   }
})

minetest.register_craft({
   output = "kingdoms:protected_chest",
   type = "shapeless",
   recipe = {"default:chest_locked", "default:copper_ingot"}
})
