-- Get info about members
function kingdoms.player_in_any_kingdoms(name)
   return kingdoms.members[name] ~= nil
end

-- Get info about kingdom(s)
function kingdoms.list_kingdoms()
   local l = ""
   for n,k in pairs(kingdoms.kingdoms) do
      local mNum = kingdoms.helpers.count_table(k.members)
      l = l .. n .. ": " .. tostring(mNum) .. " member(s)\n"
   end
   return l
end

-- Add / remove / modify members
function kingdoms.add_player_to_kingdom(kingdom_name, name, rank)
   -- Check if player exists
   if minetest.player_exists(name) ~= true then
      return false, "Player " .. name .. " has not joined yet"
   end
   -- Check if kingdom exists
   local k = kingdoms.kingdoms[kingdom_name]
   if k == nil then
      return false, "Kingdom " .. kingdom_name .. " does not exist"
   end
   -- Check if player is in kingdom
   local isIn, kIn = kingdoms.player_in_any_kingdoms(name)
   if isIn then
      return false, "Player " .. name .. " is already in kingdom " .. kIn
   end
   -- Check rank
   if rank == nil then
      rank = "soldier"
   elseif kingdoms.kingdoms[kingdom_name].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist"
   end
   -- Add player to kingdom
   kingdoms.kingdoms[kingdom_name].members[name] = true
   kingdoms.members[name] = {rank = rank, kingdom = kingdom_name}
   -- Save
   kingdoms.helpers.save()
   return true, "Added " .. name .. " to kingdom " .. kingdom_name
end

function kingdoms.remove_player_from_kingdom(kingdom_name, name)
   -- Check if kingdom exists
   local k = kingdoms.kingdoms[kingdom_name]
   if k == nil then
      return false, "Kingdom " .. kingdom_name .. " does not exist"
   end
   -- Check if player is in kingdom
   if kingdoms.kingdoms[kingdom_name].members[name] == nil then
      return false, "Player " .. name .. " is not in kingdom " .. kingdom_name
   end
   -- Remove
   kingdoms.kingdoms[kingdom_name].members[name] = nil
   kingdoms.members[name] = nil
   -- Save
   kingdoms.helpers.save()
   return true, "Removed " .. name .. " from kingdom " .. kingdom_name
end

function kingdoms.set_player_rank(name, rank)
   -- Check if player is in a kingdom
   if kingdoms.player_in_any_kingdoms(name) ~= true then
      return false, "Player " .. name .. " is not in a kingdom"
   end
   -- Check if rank exists
   local k = kingdoms.members[name].kingdom
   if kingdoms.kingdoms[k].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist in kingdom " .. k
   end
   -- Set rank
   kingdoms.members[name].rank = rank
   return true, "Set player " .. name .. "'s rank to " .. rank
end

-- Add / remove / modify kingdoms
function kingdoms.add_kingdom(name, king)
   -- Check if kingdom already exists
   if kingdoms.kingdoms[name] ~= nil then
      return false, "Kingdom already exists"
   end
   -- Create new entry
   kingdoms.kingdoms[name] = {
      name = name,
      members = {},
      ranks = kingdoms.helpers.copy_table(kingdoms.default_ranks)
   }
   -- Add owner
   kingdoms.add_player_to_kingdom(name, king, "king")
   -- Save
   kingdoms.helpers.save()
   return true, "Added kingdom " .. name
end

function kingdoms.remove_kingdom(name)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom does not exist"
   end
   -- Remove
   kingdoms.kingdoms[name] = nil
   -- Save
   kingdoms.helpers.save()
   return true, "Removed kingdom " .. name
end

-- Add / remove / modify ranks
function kingdoms.add_rank(name, rank, privs)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom does not exist"
   end
   -- Check if rank exists
   if kingdoms.kingdoms[name].ranks[rank] ~= nil then
      return false, "Rank " .. rank .. " already exists"
   end
   -- Validate privs
   if privs == nil then
      privs = kingdoms.helpers.copy_table(kingdoms.default_ranks.soldier)
   else
      for priv, _ in pairs(privs) do
         if kingdoms.kingdom_privs[priv] == nil then
            return false, "Invalid priv " .. priv
         end
      end
   end
   -- Add rank
   kingdoms.kingdoms[name].ranks[rank] = privs
   -- Save
   kingdoms.helpers.save()
   return true, "Added rank " .. rank .. " to kingdom " .. name .. " with privs " .. kingdoms.helpers.keys_to_str(privs)
end

function kingdoms.remove_rank(name, rank)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom does not exist"
   end
   -- Check if rank exists
   if kingdoms.kingdoms[name].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist"
   end
   -- Remove rank
   kingdoms.kingdoms[name].ranks[rank] = nil
   -- Save
   kingdoms.helpers.save()
   return true, "Removed rank " .. rank " from kingdom " .. name
end
