minetest.register_tool("whip:whip", {
   description = "Whip",
   inventory_image = "whip_whip.png",
   range = 10.0,
   tool_capabilities = {
      full_punch_interval = 1.5,
      damage_groups = {fleshy = 3}
   }
})

minetest.register_craft({
   output = "whip:whip",
   recipe = {
      {"", "xdecor:rope", ""},
      {"xdecor:rope", "", "xdecor:rope"},
      {"group:stick", "", ""}
   }
})

knockout.register_tool("whip:whip", 1, 5, 50)

minetest.register_tool("whip:cat_o_nine_tails", {
   description = "Cat o' nine tails",
   inventory_image = "cat_o_nine_tails.png",
   range = 7.5,
   tool_capabilities = {
      full_punch_interval = 1.8,
      damage_groups = {fleshy = 5}
   }
})

minetest.register_craft({
   output = "whip:cat_o_nine_tails",
   recipe = {
      {"default:glass", "",              ""},
      {"default:glass", "default:glass", ""},
      {"whip:whip",     "default:glass", "default:glass"}
   }
})
knockout.register_tool("whip:whip", 1, 6, 60)
