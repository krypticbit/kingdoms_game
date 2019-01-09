-- large horn
minetest.register_craftitem ("extrahorns:largehorn", {
	description = "Large Horn",
	inventory_image = "extrahorns_largehorn.png",
	groups = {instrument=1},	
	on_use = function (itemstack, user)
		minetest.sound_play ("extrahorns_largehorn", {
			pos = user:getpos(),
			max_hear_distance = 450,
			gain = 1,
		})
	end,
})

minetest.register_craft ({
	type   = "shapeless",
	output = "extrahorns:largehorn",
	recipe = {"soundblocks:smallhorn", "default:steel_ingot"}
})

-- Warhorn

minetest.register_craftitem ("extrahorns:warhorn", {
	description = "War Horn" ,
	inventory_image = "extrahorns_warhorn.png",
	groups = {instrument=1},	
	on_use = function (itemstack, user)
		minetest.sound_play ("extrahorns_warhorn", {
			pos= user:getpos() ,
			max_hear_distance = 550,
			gain = 1.2,
		})
	end,
})

minetest.register_craft ({
	output = "extrahorns:warhorn",
	recipe = {
		{"extrahorns:largehorn", "", ""},
		{"", "extrahorns:largehorn", ""},
		{"", "", "extrahorns:largehorn"},
    }
})

-- bagpipes
minetest.register_craftitem ("extrahorns:bagpipes", {
	description = "Bagpipes",
	inventory_image = "extrahorns_bagpipe.png" ,
	groups = {instrument=1},	
	on_use = function (itemstack, user)
		minetest.sound_play ("extrahorns_bagpipe", {
			pos = user:getpos(),
			max_hear_distance = 350,
			gain = 1,
		})
	end,
})

minetest.register_craft ({
	output = "extrahorns:bagpipes",
	recipe = {
		{ "default:stick","default:stick", "default:gold_ingot"} ,
		{ "group:wool","group:wool", ""} ,
		{ "group:wool", "group:wool", "default:stick" } ,
	}
})
