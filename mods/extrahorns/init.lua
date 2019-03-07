-- large horn
minetest.register_craftitem("extrahorns:largehorn", {
	description = "Large Horn",
	inventory_image = "extrahorns_largehorn.png",
	groups = {instrument = 1},	
	on_use = function (itemstack, user)
		minetest.sound_play("extrahorns_largehorn", {
			pos = user:get_pos(),
			max_hear_distance = 450,
			gain = 1,
		})
	end,
})

minetest.register_craft({
	type   = "shapeless",
	output = "extrahorns:largehorn",
	recipe = {"soundblocks:smallhorn", "default:steel_ingot"}
})

-- Warhorn

minetest.register_craftitem("extrahorns:warhorn", {
	description = "War Horn" ,
	inventory_image = "extrahorns_warhorn.png",
	groups = {instrument = 1},	
	on_use = function(itemstack, user)
		minetest.sound_play("extrahorns_warhorn", {
			pos = user:get_pos(),
			max_hear_distance = 550,
			gain = 1.2,
		})
	end,
})

minetest.register_craft({
	output = "extrahorns:warhorn",
	recipe = {
		{"extrahorns:largehorn", "", ""},
		{"", "extrahorns:largehorn", ""},
		{"", "", "extrahorns:largehorn"},
	}
})

-- bagpipes
minetest.register_craftitem("extrahorns:bagpipes", {
	description = "Bagpipes",
	inventory_image = "extrahorns_bagpipe.png" ,
	groups = {instrument = 1},	
	on_use = function (itemstack, user)
		minetest.sound_play("extrahorns_bagpipe", {
			pos = user:get_pos(),
			max_hear_distance = 350,
			gain = 1,
		})
	end,
})

minetest.register_craft({
	output = "extrahorns:bagpipes",
	recipe = {
		{"default:stick", "default:stick", "default:gold_ingot"},
		{"group:wool", "group:wool", ""},
		{"group:wool", "group:wool", "default:stick" },
	}
})

-- flute
minetest.register_craftitem("extrahorns:flute", {
	description = "flute",
	inventory_image = "extrahorns_flute.png",
	groups = {instrument = 1},
	on_use = function(itemstack, user)
		minetest.sound_play("extrahorns_flute", {
			pos = user:get_pos(),
			max_hear_distance = 100,
			gain = 1,
		})
	end,
})	

minetest.register_craft({
	output = "extrahorns:flute",
	recipe = {
		{ "default:stick", "", ""},
		{ "", "default:stick", ""},
		{ "", "", "default:stick"},
	}
})	

-- steelflute
minetest.register_craftitem("extrahorns:steelflute", {
	description = "steelflute",
	inventory_image = "extrahorns_steelflute.png",
	groups = {instrument = 1},
	on_use = function(itemstack, user)
		minetest.sound_play("extrahorns_flute", {
			pos = user:get_pos(),
			max_hear_distance = 350,
			gain = 1,
		})
	end,
})	

minetest.register_craft({
	output = "extrahorns:steelflute",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "default:steel_ingot", ""},
		{"", "", "default:steel_ingot"},
	}
})	

--drumstick
minetest.register_craftitem("extrahorns:drumstick", {
	description = "drumstick",
	inventory_image = "extrahorns_drumstick.png",
})	

minetest.register_craft({
	output = "extrahorns:drumstick",
	recipe = {
		{"group:wool", "", ""},
		{"", "default:stick", ""},
		{"", "", "default:stick"},
	}
})	

-- drum
minetest.register_node("extrahorns:wardrum", {
    description = "War Drum",
    tiles = {
        "extrahorns_drum_top.png", -- Top
        "extrahorns_drum_bottom.png", -- Bottom
        "extrahorns_drum_side.png",
        "extrahorns_drum_side.png",
        "extrahorns_drum_side.png",
        "extrahorns_drum_side.png",
    },   
    on_punch = function(pos, node, player, pointed_thing) -- if its punched
        if player then -- if the entity that punched it is a player
            if player:get_wielded_item():get_name() == "extrahorns:drumstick" then -- if holding drumstick
                minetest.sound_play("extrahorns_wardrum", { -- play drum sound
                    pos = player:get_pos(),
                    max_hear_distance = 500,
                    gain =  2,
                })
            end    
        end
        end,
    groups = {instrument = 1, choppy = 3} -- need axe to break it
})

minetest.register_craft({
	output = "extrahorns:wardrum",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"group:wood", "", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})	

-- triangle

minetest.register_craftitem("extrahorns:triangle", {
	description = "Triangle",
	inventory_image = "extrahorns_triangle.png",
	groups = {instrument = 1},	
	on_use = function(itemstack, user)
		minetest.sound_play("extrahorns_triangle", {
			pos = user:get_pos(),
			max_hear_distance = 100,
			gain = 1,
		})
	end,
})

minetest.register_craft({
	output = "extrahorns:triangle",
	recipe = {
		{"", "", ""},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})	
