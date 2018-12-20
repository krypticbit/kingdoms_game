local function check_move_protection(pos, player, stack)
   local pName = player:get_player_name()
   if minetest.is_protected(pos, pName) then
      minetest.record_protection_violation(pos, pName)
      return 0
   end
   return stack:get_count()
end

minetest.register_node("alchemy:plant_processor", {
   description = "Plant Processor",
   tiles = {"plant_processor_top.png", "plant_processor_top.png", "plant_processor_side.png", "plant_processor_side.png", "plant_processor_side.png", "plant_processor_side.png"},
   groups = {oddly_breakable_by_hand = 2},
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size("src", 1)
      inv:set_size("dst", 9)
      meta:set_string("formspec", "size[8,9]" ..
      "label[1,0.5;Leaves / Grass]" ..
      "list[context;src;1,1;1,1;]" ..
      "label[4,0.5;Herbs]" ..
      "list[context;dst;4,1;3,3;]" ..
      "list[current_player;main;0,5;8,4;]")
      meta:set_string("infotext", "Idle")
   end,
   on_timer = function(pos, elapsed)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      if inv:is_empty("src") then
         meta:set_string("infotext", "Idle")
         return nil
      end

      local to_process = inv:get_stack("src", 1)
      local name = to_process:get_name()

      -- Process leaves / grass
      if alchemy.herbs[name] then
         -- Decide what to output (if anything)
         local output
         for herb, chance in pairs(alchemy.herbs[name]) do
            local num = math.random()
            if num < 1.0 / chance then
               output = herb
               break
            end
         end
         -- Is there room to output it?
         if inv:room_for_item("dst", output) then
            -- Take item from src
            to_process:take_item()
            inv:set_stack("src", 1, to_process)
            -- Deposit output
            inv:add_item("dst", output)
            -- Re-run
            return true
         end
      end
      -- There wasn't a vaild input or there was no room to output - stop running
      meta:set_string("infotext", "Idle")
      return nil
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      return check_move_protection(pos, player, stack)
   end,
   allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
      return check_move_protection(pos, player, stack)
   end,
   allow_metadata_inventory_take = function(pos, listname, index, stack, player)
      return check_move_protection(pos, player, stack)
   end,
   on_metadata_inventory_move = function(pos)
      local meta = minetest.get_meta(pos)
      minetest.get_node_timer(pos):start(1.0)
      meta:set_string("infotext", "Sorting leaves / grass ...")
   end,
   on_metadata_inventory_put = function(pos)
      local meta = minetest.get_meta(pos)
      minetest.get_node_timer(pos):start(1.0)
      meta:set_string("infotext", "Sorting leaves / grass ...")
   end
})
