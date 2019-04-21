-- Get info about members
function kingdoms.player_in_any_kingdoms(name)
   if kingdoms.members[name] ~= nil then
      return true, kingdoms.members[name].kingdom
   else
      return false
   end
end

function kingdoms.player_has_priv(name, priv)
   if kingdoms.members[name] == nil then
      return false
   end
   local rank = kingdoms.members[name].rank
   local kingdom = kingdoms.kingdoms[kingdoms.members[name].kingdom]
   return kingdom.ranks[rank][priv] ~= nil
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
      rank = kingdoms.kingdoms[kingdom_name].default_rank
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

function kingdoms.remove_player_from_kingdom(name)
   -- Check if player is in kingdom
   if kingdoms.members[name] == nil then
      return false, "Player " .. name .. " is not in a kingdom"
   end
   -- Remove
   local kingdom_name = kingdoms.members[name].kingdom
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
      ranks = kingdoms.helpers.copy_table(kingdoms.default_ranks),
      default_rank = "soldier",
      restricted = false,
      color = "White"
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
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Remove members
   for n,_ in pairs(kingdoms.kingdoms[name].members) do
      kingdoms.members[n] = nil
   end
   -- Remove applications
   for k, p in pairs(kingdoms.pending) do
      if p == name then
         kingdoms.pending[k] = nil
      end
   end
   -- Remove kingdom
   kingdoms.kingdoms[name] = nil
   -- Save
   kingdoms.helpers.save()
   return true, "Removed kingdom " .. name
end

-- Add / remove / modify ranks
function kingdoms.add_rank(name, rank, privs)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom " .. name .. " does not exist"
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
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Check if rank exists
   if kingdoms.kingdoms[name].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist in kingdom " .. name
   end
   -- Remove rank
   kingdoms.kingdoms[name].ranks[rank] = nil
   -- Demote all members with that rank
   for n,_ in pairs(kingdoms.kingdoms[name].members) do
      if kingdoms.members[n].rank == rank then
         kingdoms.members[n].rank = kingdoms.kingdoms[name].default_rank
      end
   end
   -- Save
   kingdoms.helpers.save()
   return true, "Removed rank " .. rank .. " from kingdom " .. name
end

function kingdoms.set_rank_privs(name, rank, privs)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Check if rank exists
   if kingdoms.kingdoms[name].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist"
   end
   -- Check if privs are valid
   for priv, _ in pairs(privs) do
      if kingdoms.kingdom_privs[priv] == nil then
         return false, "Invalid priv " .. priv
      end
   end
   -- Set privs
   kingdoms.kingdoms[name].ranks[rank] = privs
   -- Save
   kingdoms.helpers.save()
   return true, "Set privs of rank " .. rank .. " to " .. kingdoms.helpers.keys_to_str(privs)
end

function kingdoms.set_default_rank(name, rank)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Check if rank exists
   if kingdoms.kingdoms[name].ranks[rank] == nil then
      return false, "Rank " .. rank .. " does not exist"
   end
   -- Set as default
   kingdoms.kingdoms[name].default_rank = rank
   -- Save
   kingdoms.helpers.save()
   return true, "Set default rank of kingdom " .. name .. " to " .. rank
end

function kingdoms.toggle_restricted(name)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Toggle
   kingdoms.kingdoms[name].restricted = not kingdoms.kingdoms[name].restricted
   -- Save
   kingdoms.helpers.save()
   return true, kingdoms.kingdoms[name].restricted and "Kingdom " .. name .. " restriction enabled" or
   "Kingdom " .. name .. " restriction disabled"
end

function kingdoms.set_color(name, color)
   -- Check if kingdom exists
   if kingdoms.kingdoms[name] == nil then
      return false, "Kingdom " .. name .. " does not exist"
   end
   -- Check if color exists
   if kingdoms.colors[color] == nil then
      return false, "Invaild color" .. color
   end
   -- Set color
   kingdoms.kingdoms[name].color = color
   -- Update all loaded markers
   local n
   local new_itemstr = "kingdoms:marker_" .. string.lower(color)
   for _,m in pairs(kingdoms.markers) do
      if m.kingdom == name then
         n = minetest.get_node_or_nil(m.pos)
         if n ~= nil then
            minetest.swap_node(m.pos, {name = new_itemstr})
         end
      end
   end
   -- Save
   kingdoms.helpers.save()
   return true, "Changed color of kingdom " .. name .. " to " .. color
end
