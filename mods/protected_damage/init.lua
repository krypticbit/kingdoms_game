protected_damage = {}

local function div(a, b)
   if a == nil or b == nil then return 0 end
   return a / b
end

local function mult(a, b)
   if a == nil or b == nil then return 0 end
   return a * b
end

protected_damage.blacklist = {
   ["kingdoms:marker"] = true,
   ["air"] = true
}

-- Get node strength
function protected_damage.get_node_strength(name)
   -- Return false if blacklisted
   if protected_damage.blacklist[name] ~= nil then return false end
   -- Return false if unbreakable
   local ndef = minetest.registered_nodes[name]
   if ndef == nil or ndef.groups == nil or ndef.groups.unbreakable ~= nil or ndef.groups.liquid ~= nil then
      return false
   end
   -- Calculate strength
   local groups = ndef.groups
   local s = div(100, groups.cracky)
      + div(140, groups.stone)
      + mult(300, groups.level)
      + div(50, groups.crumbly)
      - mult(20, groups.oddly_breakable_by_hand)
      + div(60, groups.snappy)
      + div(80, groups.choppy)
      - mult(20, groups.dig_immediate)
   s = math.floor(s + 0.5)
   if s < 0 then s = 1 end
   return s
end

-- Core damage function (used by tnt mod)
function protected_damage.do_damage(pos, name, amt)
   -- Get node strength
   local meta = minetest.get_meta(pos)
   local s = meta:get_int("node_hp")
   if s == 0 then
      s = protected_damage.get_node_strength(name)
      if s == false then return end
   end
   -- Damage node
   s = s - amt
   s = math.floor(s + 0.5)
   if s <= 0 then
      minetest.set_node(pos, {name = "air"})
      return
   else
      meta:set_int("node_hp", s)
   end
end

-- Main damage function (involves checks)
function protected_damage.damage(pos, amt)
   -- Check for unloaded node
   local node = minetest.get_node_or_nil(pos)
   if node == nil then
      return
   end
   -- Check for blacklisted node
   if protected_damage.blacklist[node.name] ~= nil then
      return
   end
   -- Do damage
   protected_damage.do_damage(pos, node.name, amt)
end

-- Register tool to get node strength
minetest.register_tool("protected_damage:checker", {
   description = "Damage Checker",
   inventory_image = "protected_damage_checker.png",
   on_use = function(itemstack, user, pointed_thing)
      if pointed_thing.type ~= "node" then return end
      local pos = minetest.get_pointed_thing_position(pointed_thing)
      local meta = minetest.get_meta(pos)
      local hp = meta:get_int("node_hp")
      local pname = user:get_player_name()
      if hp == 0 then
         local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
         local strength = protected_damage.get_node_strength(ndef)
         if strength == false then
            minetest.chat_send_player(pname, "This node is unbreakable")
         else
            minetest.chat_send_player(pname, "Node strength: " .. tostring(strength))
         end
      else
         minetest.chat_send_player(pname, "Node strength: " .. tostring(hp))
      end
   end
})
minetest.register_craft({
   output = "protected_damage:checker",
   recipe = {
      {"", "", "group:wood"},
      {"", "default:steel_ingot", ""},
      {"group:stick", "", ""}
   }
})
