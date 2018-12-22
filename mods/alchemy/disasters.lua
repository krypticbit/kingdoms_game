alchemy.disasters.to_slime = function(pos, name)
   local cauldronLevel = name:sub(-1, -1)
   local slimeCauldron = "alchemy:cauldron_slime" .. cauldronLevel
   minetest.set_node(pos, {name = slimeCauldron})
end
