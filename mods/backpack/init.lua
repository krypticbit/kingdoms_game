--- Minetest backpack mod

-- Textures and models by prestidigitator
-- Licensed under WTFPL

backpack = {}
backpack.wearing = {}
backpack._backpack_curr_num = 0

-- inventory_plus button
minetest.register_on_joinplayer(function(p)
   inventory_plus.register_button(p, "backpack")
end)

-- Backpack entity
minetest.register_entity("backpack:backpack", {
   -- Initial properties
   hp_max = 10,
   physical = false,
   collisionbox = {-0.2, -0.3, -0.2, 0.2, 0.3, 0.2},
   visual = "mesh",
   visual_size = {x = 1, y = 1},
   mesh = "backpack.x",
   textures = {"backpack.png"},
   is_visible = true,
   -- Runs when the entity is spawned
   on_activate = function(e, sData)
      -- Set up armor groups
      e.object:set_armor_groups({punch_operable = 1})
      -- Create detached inventory
      e.invID = "backpackinv" .. backpack._backpack_curr_num
      backpack._backpack_curr_num = backpack._backpack_curr_num + 1
      local inv = minetest.create_detached_inventory(e.invID)
      inv:set_size("main", 12)
      -- Fill inventory from staticdata
      if sData ~= "" then
         minetest.chat_send_all("set")
         inv:set_list("main", minetest.deserialize(sData))
      end
   end,
   -- Pick up on punch
   on_punch = function(e, puncher)
      local n = puncher:get_player_name()
      if puncher == nil or puncher:is_player() == false then return end
      if puncher:get_player_control().sneak then
         local inv = minetest.get_inventory({type = "detached", name = e.invID})
         if inv:is_empty("main") then
            local playerInv = puncher:get_inventory()
            local bpIStack = ItemStack("backpack:backpack_empty")
            if playerInv:room_for_item("main", bpIStack) then
               e.object:remove()
               playerInv:add_item("main", bpIStack)
            end
         end
      elseif backpack.wearing[n] == nil then
         e.object:set_attach(puncher, "", {x = 0, y = 0, z = -2}, {x = 0, y = 180, z = 0})
         backpack.wearing[n] = e
      end
   end,
   -- Show inventoy on right-click
   on_rightclick = function(e, clicker)
      minetest.show_formspec(clicker:get_player_name(), "backpack:backpack_inv",
      "size[8,9;]" ..
      "list[detached:" .. e.invID .. ";main;2,1;4,3;]" ..
      "list[current_player;main;0,5;8,4]"
      )
   end,
   -- Static data
   get_staticdata = function(e)
      local inv = minetest.get_inventory({type = "detached", name = e.invID})
      local invTable = {}
      for _, itemstack in pairs(inv:get_list("main")) do
         table.insert(invTable, itemstack:to_string())
      end
      return minetest.serialize(invTable)
   end
})

local function place_backpack(pos, old)
   local contents = ""
   if old ~= nil then
      contents = old:get_staticdata()
   end
   minetest.add_entity(pos, "backpack:backpack", contents)
end

-- Drop backpack
local function drop_backpack(p)
   local pName = p:get_player_name()
   local bp = backpack.wearing[pName]
   if bp then
      -- If we just detach the old backpack, there is a wierd sliding animation
      local pos = p:get_pos()
      pos.y = pos.y + 0.3
      place_backpack(pos, bp)
      bp.object:remove()
   end
   backpack.wearing[pName] = nil
end

-- Backpack craftitem
minetest.register_craftitem("backpack:backpack_empty", {
   description = "Empty Backpack",
   inventory_image = "inventory_plus_backpack.png",
   stack_max = 20,
   liquids_pointable = false,
   on_place = function(itemstack, placer, pointed_thing)
      local pos = minetest.get_pointed_thing_position(pointed_thing, true)
      local node = minetest.get_node(pos)
      pos.y = pos.y - 0.2
      if node.name == "air" then
         place_backpack(pos)
         itemstack:take_item()
         return itemstack
      else
         local nodeDef = minetest.registered_nodes[node.name]
         if nodeDef and not nodeDef.walkable then
            place_backpack(pos)
            itemstack:take_item()
            return itemstack
         end
      end
   end
})

-- Craft recipe
minetest.register_craft({
   output = "backpack:backpack_empty",
   recipe = {
      {"", "group:wool", ""},
      {"group:wool", "", "group:wool"},
      {"group:wool", "group:wool", "group:wool"},
   }
})

-- Drop backpack when inv button is pushed
minetest.register_on_player_receive_fields(function(player, formname, fields)
   if fields.backpack then
      drop_backpack(player)
   end
end)

-- Drop backpack when player leaves
minetest.register_on_leaveplayer(function(p)
   drop_backpack(p)
end)
