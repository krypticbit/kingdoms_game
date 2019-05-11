minetest.register_tool("whip:whip", {
   description = "Whip",
   inventory_image = "whip_whip.png",
   range = 10.0,
   tool_capabilities = {
      full_punch_interval = 1.5,
      damage_groups = {fleshy = 1}
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
