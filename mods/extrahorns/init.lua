-- large horn
minetest.register_craftitem ("extrahorns:largehorn", {
    description = "Large Horn",
    inventory_image = "large.png",
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
    description     = "War Horn" ,
    inventory_image = "warhorn.png",
    groups = {instrument=1},	
    on_use = function (itemstack, user)
        minetest.sound_play ("extrahorns_warhorn", {
            pos               = user:getpos() ,
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
    description     = "Bagpipes",
    inventory_image = "bagpipe.png" ,
    groups = {instrument=1},	
    on_use = function (itemstack, user)
        minetest.sound_play ("extrahorns_bagpipe", {
            pos               = user:getpos(),
            max_hear_distance = 200,
            gain              = 1,
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
