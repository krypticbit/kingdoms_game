doors.register("door_protected", {
		tiles = {{name = "kingdoms_door_protected.png", backface_culling = true}},
		description = "Protected Door",
		inventory_image = "kingdoms_door_protected_item.png",
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

doors.register_trapdoor("kingdoms:trapdoor_protected", {
	description = "Protected Trapdoor",
	inventory_image = "kingdoms_trapdoor_protected.png",
	wield_image = "kingdoms_trapdoor_protected.png",
	tile_front = "kingdoms_trapdoor_protected.png",
	tile_side = "doors_trapdoor_steel_side.png",
	obeys_protection = true,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	groups = {cracky = 1, level = 2, door = 1},
})

minetest.register_craft({
   output = "kingdoms:trapdoor_protected",
   recipe = {
      {"default:steel_ingot", "default:copper_ingot"},
      {"default:steel_ingot", "default:steel_ingot"}
   }
})

minetest.register_craft({
   output = "kingdoms:trapdoor_protected",
   type = "shapeless",
   recipe = {"doors:trapdoor_steel", "default:copper_ingot"}
})
