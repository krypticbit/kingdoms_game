local function register_fakeblock(name, node_copy_name)
   local node = minetest.registered_nodes[node_copy_name]
   -- Register node
   minetest.register_node(name, {
      description = "Fake " .. node.description,
      drawtype = "liquid",
      tiles = node.tiles,
      groups = node.groups,
      liquid_viscosity = 2,
      liquidtype = "source",
      liquid_alternative_flowing = name,
      liquid_alternative_source = name,
      liquid_renewable = false,
      liquid_range = 0,
      waving = 0,
      walkable = false
   })
   -- Register craft
   minetest.register_craft({
      output = name,
      recipe = {
         {"group:sand", "group:sand", "group:sand"},
         {"group:sand", node_copy_name, "group:sand"},
         {"group:sand", "group:sand", "group:sand"}
      }
   })
end

register_fakeblock("fake_blocks:stone", "default:stone")
register_fakeblock("fake_blocks:cobble", "default:cobble")
register_fakeblock("fake_blocks:wood", "default:wood")
register_fakeblock("fake_blocks:pine_wood", "default:pine_wood")
register_fakeblock("fake_blocks:jungle_wood", "default:junglewood")
register_fakeblock("fake_blocks:acacia_wood", "default:acacia_wood")
register_fakeblock("fake_blocks:aspen_wood", "default:aspen_wood")
