minetest.register_alias("magma:magma", "xdecor:magma")

minetest.register_node("magma:magma", {
	description = "Magma",
	drawtype = "normal",
	tiles = {
		{
			name = "magma.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	walkable = true,
	pointable = true,
	sunlight_propagates = false,
	light_source = 13,
	groups = {snappy=2,cracky=3,},

})

minetest.register_craft({
        output = 'xdecor:magma 2',
        recipe = {
                {'bucket:bucket_lava'},
                {'default:stone'},
        },
        replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},

})
minetest.register_craft({
	type = "shapeless",
	output = "bucket:bucket_lava",
	recipe = {"xdecor:magma", "xdecor:magma", "bucket:bucket_empty"},
	replacements = {
		{"xdecor:magma", "default:cobble"}
	}
})
