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

function kingdoms.helpers.split_into_lengths(str, of)
   local res = {}
   local len = 0
   local wlen
   local line = ""
   local lidx = 1
   for w in str:gmatch("%S+") do
      wlen = w:len()
      if len + wlen > of then
         res[lidx] = line
         line = w
         lidx = lidx + 1
         len = wlen
      else
         line = line .. " " .. w
         len = len + wlen + 1 -- + 1 for the space
      end
   end
   res[lidx] = line
   return res
end

function kingdoms.helpers.save()
   local ktable = minetest.serialize(kingdoms.kingdoms)
   kingdoms.storage:set_string("kingdoms", ktable)
   local mtable = minetest.serialize(kingdoms.members)
   kingdoms.storage:set_string("members", mtable)
   local ptable = minetest.serialize(kingdoms.pending)
   kingdoms.storage:set_string("pending_requests", ptable)
   local markersTable = minetest.serialize(kingdoms.markers)
   kingdoms.storage:set_string("markers", markersTable)
   local newsTable = minetest.serialize(kingdoms.news)
   kingdoms.storage:set_string("news", newsTable)
end
