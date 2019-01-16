local function deltas_as_string(pos1, pos2)
	return("Deltas: X: "..math.abs(pos1.x-pos2.x).." | Y: "..math.abs(pos1.y-pos2.y).." | Z: "..math.abs(pos1.z-pos2.z))
end

minetest.register_craftitem("measure:stick", {
	description = "Measuring Stick",
	inventory_image = "measure_stick.png",
	stack_max = 1,

	on_use = function(itemstack, user, pointed_thing)

		if not user then
			return
		end

		local pos = minetest.get_pointed_thing_position(pointed_thing, above)	

		if not pointed_thing or not pos or not pointed_thing.ref == nil then
			minetest.chat_send_player(user:get_player_name(), "Invalid position! Please try again.")
			return itemstack
		end
				       
		local meta = itemstack:get_meta()
		local name = user:get_player_name()
		local coord1 = meta:get_string("coord1")
						       
		if coord1 and coord1 ~= "" then
			coord1 = minetest.deserialize(coord1)
			minetest.chat_send_player(name, ("Got node 2 at " .. (pos.x .. "," .. pos.y .. "," .. pos.z) .. ". Calculating..."))
			local coord1 = minetest.deserialize(meta:get_string("coord1"))
			local coord2 = pos
			local distance = vector.distance(coord1, coord2)
			minetest.chat_send_player(name, ("--\nDistance: " .. distance .. " nodes.\n"..deltas_as_string(coord1, coord2)))
			meta:set_string("coord1", "") -- Freeing it up for repeated use.
								 
		else
			meta:set_string("coord1", minetest.serialize(pos))
			minetest.chat_send_player(name, ("Got node 1 at "..(pos.x..","..pos.y..","..pos.z)))
		end
		
		return itemstack

	end
})

minetest.register_craft({
	type = "shaped",
	output = "measure:stick",
	recipe = {
		{"", "", "group:stick"},
		{"", "farming:cotton", ""},
		{"group:stick", "", ""}
	}
})
