witchcraft.helpers.item_in_table = function(t, i)
   for _, n in pairs(t) do
      if n == i then
         return true
      end
   end
   return false
end

witchcraft.helpers.inventory_contains_anything_else = function(inv, list, items)
   local l = inv:get_list(list)
   for _, item in pairs(l) do
      if not witchcraft.helpers.item_in_table(items, item) then
         return true
      end
   end
   return false
end

witchcraft.helpers.get_number_of_items_in_inv = function(inv, list, itemname)
   local l = inv:get_list(list)
   local i
   for _, item in pairs(l) do
      if item:get_name() == itemname then
         return item:get_count()
      end
   end
   return 0
end
