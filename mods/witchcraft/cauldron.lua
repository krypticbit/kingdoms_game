local function register_cauldron(itemname, def)

   -- Given params
   local cauldron_inv_size = 10

   -- Get params from def
   local texture = def.texture
   local mesh = def.mesh
   local breakable = def.breakable or false

   -- Full name
   local fullname = "witchcraft:cauldron_" .. itemname

   -- Collision / selection / node box
   local box = {
      {-0.5, -0.5, -0.5, 0.5, 0.205, 0.5},
   }

   -- Raise or lower the cauldron level
   local function edit_cauldron_level(pos, puncher)
      local wielded = puncher:get_wielded_item()
      -- Get reaction
      local n = wielded:get_name()
      local id = fullname .. " " .. n
      local reaction = witchcraft.reactions[id]
      -- If there is a reaction, run it
      if reaction then
         local swap_to = reaction(pos, 1)
         if swap_to then
            -- Clear inv
            minetest.get_meta(pos):get_inventory():set_list("main", {})
            -- Swap node
            minetest.swap_node(pos, {name = swap_to})
            -- Modify player inv
            wielded:take_item()
            puncher:set_wielded_item(wielded)
            if n == "witchcraft:beaker_empty" then
               return "witchcraft:beaker_" .. itemname:sub(0, -2)
            else
               return "witchcraft:beaker_empty"
            end
         end
      end
      return nil
   end

   -- Return an item after emptying / filling the cauldron
   local function return_item(puncher, return_item)
      local inv = puncher:get_inventory()
      if inv:room_for_item("main", return_item) then
         inv:add_item("main", return_item)
      end
   end

   -- Called when the cauldron is punched
   local function on_cauldron_punch(pos, node, puncher)
      -- Check protection
      local pName = puncher:get_player_name()
      if minetest.is_protected(pos, pName) then
         minetest.record_protection_violation(pos, pName)
         return
      end
      -- Get wielded item
      local w = puncher:get_wielded_item()
      -- Only allow dumping beakers this way
      if w:get_name():find("witchcraft:beaker_") == nil then return end
      local fill_return = edit_cauldron_level(pos, puncher)
      if fill_return then
         return_item(puncher, fill_return)
      end
   end

   minetest.register_node(fullname, {
      description = "Empty Cauldron",
      drawtype = "mesh",
      groups = breakable and {oddly_breakable_by_hand = 3, cauldron = 1} or {not_in_creative_inventory = 1, cauldron = 1},
      diggable = breakable,
      paramtype = "light",
      sunlight_propagates = true,

      tiles = {
         "cauldron.png",
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

      mesh = mesh,

      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:get_inventory():set_size("main", cauldron_inv_size)
      end,

      on_punch = on_cauldron_punch

   })
end



-- ABM for asorbing items thrown into the cauldron
minetest.register_abm({
   label = "Cauldron ABM",
   nodenames = {"group:cauldron"},
   interval = 1,
   chance = 1,
   catch_up = false,
   action = function(pos, node, obj_count)
      -- Check if there are any active items
      if obj_count == 0 then
         return
      end
      -- Get items (if any)
      local searchPos = {x = pos.x, y = pos.y + 0.5, z = pos.z}
      local objs = minetest.get_objects_inside_radius(searchPos, 0.5)
      if next(objs) == nil then return end
      -- Loops through items
      for _, obj in pairs(objs) do
         if not obj:is_player() then
            local le = obj:get_luaentity()
            if le.itemstring then
               -- Add to cauldron inventory
               local cInv = minetest.get_meta(pos):get_inventory()
               cInv:add_item("main", le.itemstring)
               -- Caluculate reaction
               local itemName = le.itemstring:gsub("%s%d*", "")
               -- If it's an empty beaker, ignore
               if itemName == "witchcraft:beaker_empty" then return end
               local reaction = witchcraft.reactions[node.name .. " " .. itemName]
               if reaction then
                  local itemCountStr = le.itemstring:gsub("[%w_:]*%s", "")
                  local itemCount = tonumber(itemCountStr) or 1
                  swap_to = reaction(pos, itemCount, cInv)
                  if swap_to then
                     minetest.swap_node(pos, {name = swap_to})
                  elseif swap_to == nil then
                     witchcraft.disasters.to_slime(pos, node.name)
                  end
                  obj:remove()
               elseif node.name ~= "witchcraft:cauldron_empty" then
                  witchcraft.disasters.to_slime(pos, node.name)
                  obj:remove()
               end
            end
         end
      end
   end
})

-- Empty cauldron
register_cauldron("empty", {
   texture = nil,
   mesh = "cauldron_empty.x",
   breakable = true
})

witchcraft.register_cauldron = register_cauldron
