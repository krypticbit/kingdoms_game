alchemy.helpers.item_in_table = function(t, i)
   for _, n in pairs(t) do
      if n == i then
         return true
      end
   end
   return false
end

alchemy.helpers.inventory_contains_anything_else = function(inv, list, items)
   local l = inv:get_list(list)
   for _, item in pairs(l) do
      if not alchemy.helpers.item_in_table(items, item) then
         return true
      end
   end
   return false
end

alchemy.helpers.get_number_of_items_in_inv = function(inv, list, itemname)
   local l = inv:get_list(list)
   local i
   for _, item in pairs(l) do
      if item:get_name() == itemname then
         return item:get_count()
      end
   end
   return 0
end

alchemy.helpers.table_length = function(t)
   local num = 0
   for _ in pairs(t) do
      num = num + 1
   end
   return num
end

alchemy.helpers.is_full_beaker = function (iString)
   if iString == "alchemy:beaker_empty" then
      return false
   else
      local n = minetest.registered_items[iString]
      if n then
         if n.groups.beaker then
            return true
         end
         return false
      else
         return false
      end
   end
end

alchemy.helpers.set_beaker_descripton = function(iStack)
   local name = iStack:get_name()
   local m = iStack:get_meta()
   local node = minetest.registered_nodes[name]
   if node == nil then return end
   local baseDes = node.description
   local cLevel = m:get_int("concentration")
   if cLevel == 0 then cLevel = 1 end
   m:set_string("description", baseDes .. "\nConcentration: " .. cLevel)
end
