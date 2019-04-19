kingdoms.helpers = {}

function kingdoms.helpers.copy_table(t)
   local n = {}
   for k,p in pairs(t) do
      n[k] = p
   end
   return n
end

function kingdoms.helpers.count_table(t)
   local c = 0
   local idxs = {}
   for k,_ in pairs(t) do
      table.insert(idxs, k)
      c = c + 1
   end
   return c, idxs
end

function kingdoms.helpers.keys_to_str(t)
   local str = ""
   for k,_ in pairs(t) do
      if str == "" then
         str = str .. k
      else
         str = str .. ", " .. k
      end
   end
   return str
end

function kingdoms.helpers.split_into_keys(str)
   local out = {}
   for k in string.gfind(str, "[%a_]+") do
      out[k] = true
   end
   return out
end

function kingdoms.helpers.save()
   local ktable = minetest.serialize(kingdoms.kingdoms)
   kingdoms.storage:set_string("kingdoms", ktable)
   local mtable = minetest.serialize(kingdoms.members)
   kingdoms.storage:set_string("members", mtable)
   local ptable = minetest.serialize(kingdoms.pending)
   kingdoms.storage:set_string("pending_requests", ptable)
end
