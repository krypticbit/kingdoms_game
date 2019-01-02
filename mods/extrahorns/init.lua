-- large horn
minetest.register_craftitem ("extrahorns:largehorn", {
    description     = "Large Horn"         ,
    inventory_image = "large.png" ,
    on_use          = function (itemstack, user)
        minetest.sound_play ("HornLarge", {
            pos               = user:getpos() ,
            max_hear_distance = 450           ,
            gain              = 1             ,
        })
    end,
    groups = {instrument=1}
})

minetest.register_craft ({
	type   = "shapeless",
    output = "extrahorns:largehorn",
    recipe = {"soundblocks:smallhorn", "default:steel_ingot"}

})

-- Warhorn

minetest.register_craftitem ("extrahorns:warhorn", {
    description     = "War Horn"         ,
    inventory_image = "warhorn.png" ,
    on_use          = function (itemstack, user)
        minetest.sound_play ("Warhorn", {
            pos               = user:getpos() ,
            max_hear_distance = 550           ,
            gain              = 1.2             ,
        })
    end,
    groups = {instrument=1}
})

minetest.register_craft ({
    output = "extrahorns:warhorn",
    recipe = {
{ "extrahorns:largehorn" , ""           , ""              } ,
{ ""           , "extrahorns:largehorn" , ""              } ,
{ ""           , ""           , "extrahorns:largehorn" } ,
    }
})


minetest.register_craftitem ("extrahorns:bagpipes", {
    description     = "Bagpipes"         ,
    inventory_image = "bagpipe.png" ,
    on_use          = function (itemstack, user)
        minetest.sound_play ("bagpipe", {
            pos               = user:getpos() ,
            max_hear_distance = 200          ,
            gain              = 1             ,
        })
    end,
    groups = {instrument=1}
})

minetest.register_craft ({
    output = "extrahorns:bagpipes",
    recipe = {
{ "default:stick" , "default:stick"           , "	default:gold_ingot"              } ,
{ "wool:white", "wool:white", ""              } ,
{ ""           , ""           , "default:stick" } ,
    }
})
