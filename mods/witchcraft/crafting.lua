-- Empty cauldron
minetest.register_craft({
   output = "witchcraft:cauldron_empty",
   recipe = {
      {"default:steelblock", "", "default:steelblock"},
      {"default:steelblock", "default:steelblock", "default:steelblock"},
      {"default:steel_ingot", "", "default:steel_ingot"}
   }
})

-- Empty beaker
minetest.register_craft({
   output = "witchcraft:beaker_empty",
   recipe = {
      {"default:glass", "group:wood", "default:glass"},
      {"default:glass", "", "default:glass"},
      {"default:glass", "default:glass", "default:glass"},
   }
})

-- Beaker of base solution
minetest.register_craft({
   type = "shapeless",
   output = "witchcraft:beaker_base",
   recipe = {
      "witchcraft:beaker_empty",
      "default:mese_crystal",
      "bucket:bucket_water"
   },
   replacements = {
      {"bucket:bucket_water", "bucket:bucket_empty"}
   }
})

-- Plant processor
minetest.register_craft({
   output = "witchcraft:plant_processor",
   recipe = {
      {"group:wood", "group:wood", "group:wood"},
      {"default:steelblock", "default:mese", "default:steelblock"},
      {"default:diamondblock", "default:diamondblock", "default:diamondblock"}
   }
})
