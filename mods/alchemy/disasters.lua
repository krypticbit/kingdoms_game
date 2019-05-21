alchemy.disasters.to_slime = function(pos, name)
   local cauldronLevel = name:sub(-1, -1)
   local slimeCauldron = "alchemy:cauldron_slime" .. cauldronLevel
   minetest.set_node(pos, {name = slimeCauldron})
end

alchemy.disasters.ice_block = function(pos)
   local p1 = {x = pos.x - 2, y = pos.y - 2, z = pos.z - 2}
   local p2 = {x = pos.x + 2, y = pos.y + 2, z = pos.z + 2}
   for _, p in pairs(minetest.find_nodes_in_area(p1, p2, "air")) do
      minetest.set_node(p, {name = "default:ice"})
   end
end

alchemy.disasters.explode_up = function(pos, height, particles)
   if particles then
      minetest.add_particlespawner({
         amount = 50,
         time = 0.1,
         minpos = {x = pos.x - 0.5, y = pos.y, z = pos.z - 0.5},
         maxpos = {x = pos.x + 0.5, y = pos.y, z = pos.z + 0.5},
         minvel = {x = -1, y = 20, z = -1},
         maxvel = {x = 1, y = 25, z = 1},
         minacc = {x = 0, y = 0, z = 0},
         maxacc = {x = 0, y = 0, z = 0},
         minexptime = 0.5,
         maxexptime = 1,
         minsize = 8,
         maxsize = 12,
         collissiondetection = false,
         vertiacal = false,
         texture = "alchemy_fire_particle.png"
      })
   end
   local miny = pos.y + 1
   local maxy = pos.y + height + 1
   for y = miny, maxy do
      local currPos = {x = pos.x, y = y, z = pos.z}
      local n = minetest.get_node(currPos)
      if n and n.name ~= "air" and minetest.registered_nodes[n.name].walkable then
         tnt.boom(currPos, {
            radius = 3,
            damage_radius = 4,
         })
      end
   end
end
