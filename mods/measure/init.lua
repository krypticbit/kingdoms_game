local function deltas_as_string(pos1, pos2)
	return("Deltas: X: "..math.abs(pos1.x-pos2.x).." | Y: "..math.abs(pos1.y-pos2.y).." | Z: "..math.abs(pos1.z-pos2.z))
	end

minetest.register_craftitem("measure:stick", {

	description = "Measuring Stick",
	inventory_image = "measure_stick.png",
	stack_max = 1,

	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing == nil then

			minetest.chat_send_player(user:get_player_name(), "Punch a valid node!")
			return -1
			end
						       
		local pos = minetest.get_pointed_thing_position(pointed_thing, above)
		local meta = itemstack:get_meta()
						       
		if meta:get_string("coord1") ~= "" then

			minetest.chat_send_player(user:get_player_name(), ("Got node 2 at " .. (pos.x .. "," .. pos.y .. "," .. pos.z) .. ". Calculating..."))
			local coord1 = minetest.deserialize(meta:get_string("coord1"))
			local coord2 = pos
			local distance = vector.distance(coord1, coord2)
			minetest.chat_send_player(user:get_player_name(), ("--\nDistance: " .. distance .. " nodes.\n"..deltas_as_string(coord1, coord2)))
			meta:set_string("coord1", "") -- Freeing it up for repeated use.
								 
		elseif meta:get_string("coord1") == "" then

			meta:set_string("coord1", minetest.serialize(pos))
			minetest.chat_send_player(user:get_player_name(), ("Got node 1 at "..(pos.x..","..pos.y..","..pos.z)))
			end
		
		return itemstack

		end
})