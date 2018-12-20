local box = {
   {-0.099, -0.483, -0.099, 0.099, -0.291, 0.099},
   {-0.053, -0.291, -0.053, 0.053, -0.206, 0.053},
   {-0.071, -0.206, -0.071, 0.071, -0.186, 0.071},
}

-- Empty beaker
minetest.register_node("alchemy:beaker_empty", {
   description = "Empty Beaker",
   drawtype = "mesh",
   groups = {}, -- Unbreakable but picked up on punch - no particles
   paramtype = "light",
   sunlight_propagates = true,

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

   minetest.register_node(bname, {
      description = "Beaker of " .. description,
      drawtype = "mesh",
      groups = {}, -- Unbreakable but picked up on punch - no particles
      paramtype = "light",
      stack_max = 1,
      sunlight_propagates = true,

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

      on_punch = function(pos, node, puncher)
         local pName = puncher:get_player_name()
         -- Check protection
         if minetest.is_protected(pos, pName) then
            minetest.record_protection_violation(pos, pName)
            return
         end
         -- Pick up node
         minetest.node_dig(pos, node, puncher)
      end,

      on_drop = function(itemstack, dropper, pos)
         local effect = alchemy.effects[itemstack:get_name()]
         if effect then
            effect(dropper, pos)
         end
         itemstack:take_item()
         return itemstack
      end
   })
end

alchemy.register_beaker = register_beaker
