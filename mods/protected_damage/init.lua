protected_damage = {}

local function div(a, b)
   if a == nil or b == nil then return 0 end
   return a / b
end

local function mult(a, b)
   if a == nil or b == nil then return 0 end
   return a * b
end

function protected_damage.get_node_strength(groups)
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

protected_damage.blacklist = {
   ["kingdoms:marker"] = true,
   ["air"] = true
}

-- Core damage function (used by tnt mod)
function protected_damage.do_damage(pos, groups, amt)
   -- Get node strength
   local meta = minetest.get_meta(pos)
   local s = meta:get_int("node_hp")
   if s == 0 then
      s = protected_damage.get_node_strength(groups)
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
   -- Check for undefined / unbreakable node
   local ndef = minetest.registered_nodes[node.name]
   if ndef == nil or ndef.groups == nil or ndef.groups.unbreakable ~= nil or ndefs.groups.liquid ~= nil then
      return
   end
   -- Do damage
   protected_damage.do_damage(pos, ndef.groups, amt)
end
