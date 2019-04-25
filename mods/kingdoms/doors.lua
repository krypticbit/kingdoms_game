doors.register("door_protected", {
		tiles = {{name = "doors_door_steel.png", backface_culling = true}},
		description = "Protected Door",
		inventory_image = "doors_item_steel.png",
		obeys_protection = true,
		groups = {cracky = 1, level = 2},
		sounds = default.node_sound_metal_defaults(),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "default:copper_ingot"},
			{"default:steel_ingot", "default:steel_ingot"},
		}
})

minetest.register_craft({
   output = "doors:door_protected",
   type = "shapeless",
   recipe = {"doors:door_steel", "default:copper_ingot"}
})
