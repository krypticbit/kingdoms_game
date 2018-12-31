local box = {
   {-0.099, -0.483, -0.099, 0.099, -0.291, 0.099},
   {-0.053, -0.291, -0.053, 0.053, -0.206, 0.053},
   {-0.071, -0.206, -0.071, 0.071, -0.186, 0.071},
}

-- Empty beaker
minetest.register_node("alchemy:beaker_empty", {
   description = "Empty Beaker",
   drawtype = "mesh",
   groups = {vessel = 1, beaker = 1}, -- Unbreakable but picked up on punch - no particles
   paramtype = "light",
   sunlight_propagates = true,
   inventory_image = "beaker_empty.png",

   tiles = {
      "beaker.png"
   },

   node_box = {
      type = "fixed",
      fixed = box,
   },

   selection_box = {
      type = "fixed",
      fixed = box,
   },

   mesh = "beaker_empty.x",

   on_punch = function(pos, node, puncher)
      local pName = puncher:get_player_name()
      -- Check protection
      if minetest.is_protected(pos, pName) then
         minetest.record_protection_violation(pos, pName)
         return
      end
      -- Pick up node
      minetest.node_dig(pos, node, puncher)
   end
})

-- Full beaker(s)
local function register_beaker(name, description, texture)

   local bname = "alchemy:beaker_" .. name
   local desc = "Beaker of " .. description

   minetest.register_node(bname, {
      description = desc,
      drawtype = "mesh",
      groups = {vessel = 1, beaker = 1}, -- Unbreakable but picked up on punch - no particles
      paramtype = "light",
      stack_max = 1,
      sunlight_propagates = true,
      inventory_image = texture .. "^beaker_mask.png^[makealpha:0,0,0^beaker_empty.png",

      tiles = {
         "beaker.png",
         texture
      },

      node_box = {
         type = "fixed",
         fixed = box,
      },

      selection_box = {
         type = "fixed",
         fixed = box,
      },

      mesh = "beaker.x",

      after_place_node = function(pos, placer, itemstack, pointed_thing)
         local sMeta = itemstack:get_meta()
         local meta = minetest.get_meta(pos)
         local concentration = sMeta:get_int("concentration")
         if concentration == 0 then
            concentration = 1
         end
         meta:set_int("concentration", concentration)
         meta:set_string("infotext", desc .. "\nConcentration: " .. concentration)
      end,


      on_punch = function(pos, node, puncher)
         local pName = puncher:get_player_name()
         -- Check protection
         if minetest.is_protected(pos, pName) then
            minetest.record_protection_violation(pos, pName)
            return
         end
         -- Dig node
         local playerInv = puncher:get_inventory()
         local oldmeta = minetest.get_meta(pos)
         local stack = ItemStack(node.name)
         local stackMeta = stack:get_meta()
         local concentration = oldmeta:get_int("concentration")
         if concentration == 0 then
            concentration = 1
         end
         stackMeta:set_int("concentration", concentration)
         stackMeta:set_string("description", desc .. "\nConcentration: " .. concentration)
         minetest.remove_node(pos)
         if playerInv:room_for_item("main", stack) then
            playerInv:add_item("main", stack)
         else
            minetest.add_entity(pos, "__builtin:item", stack:to_string())
         end
      end,

      on_drop = function(itemstack, dropper, pos)
         -- Get effect function
         local effect = alchemy.effects[itemstack:get_name()]
         -- Get concentration level
         local cLevel = itemstack:get_meta():get_int("concentration")
         if cLevel == 0 then cLevel = 1 end
         -- Run effect
         if effect then
            effect(dropper, pos, cLevel)
         end
         itemstack:take_item()
         return itemstack
      end
   })
end

alchemy.register_beaker = register_beaker
