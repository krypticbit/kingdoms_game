protected_damage = {}
local attacks = {}
local attack_cooldown = 60 * 20 -- Seconds

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

-- Get node strength as a string
local function get_node_strength_str(hp, max_hp)
   -- Unbreakable
   if max_hp == false then
      return "This node is unbreakable"
   end
   -- If undamged, set hp to max
   if hp == 0 then
      hp = max_hp
   end
   -- Return node strength
   return ("Node strength: %d/%d"):format(hp, max_hp)
end

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

-- Check if protected damage can happen
function protected_damage.can_damage(pos, by)
   if by == nil then return false end
   -- Damager must be a member of a kingdom
   local m = kingdoms.members[by]
   if m == nil then
      minetest.chat_send_player(by, "You must be a member of a kingdom to damage protected areas")
      return false
   end
   -- Damager can't attack their own kingdom
   local protected_by = kingdoms.helpers.get_owning_kingdom(pos)
   if protected_by == m.kingdom then
      minetest.chat_send_player(by, "You cannot attack your own kingdom")
      return false
   elseif protected_by == nil then
      minetest.chat_send_player(by, "You cannot attack an unprotected area")
      return false
   end
   -- Damager must be at war
   if kingdoms.get_relation(m.kingdom, protected_by).id ~= kingdoms.relations.war then
      minetest.chat_send_player(by, "You are not at war with this kingdom")
      return false
   end
   return true
end

-- Core damage function (used by tnt mod)
function protected_damage.do_damage(pos, name, amt, by)
   -- Check kingdoms / members
   if not protected_damage.can_damage(pos, by) then return end
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
      return true
   else
      meta:set_int("node_hp", s)
      return false
   end
end

-- Main damage function (gets node)
function protected_damage.damage(pos, amt, by)
   -- Check for unloaded node
   local node = minetest.get_node_or_nil(pos)
   if node == nil then
      return
   end
   -- Do damage
   if protected_damage.do_damage(pos, node.name, amt, by) then
      minetest.set_node(pos, {name = "air"})
   end
end

-- Register tool to get node strength
minetest.register_tool("protected_damage:checker", {
   description = "Damage Checker",
   inventory_image = "protected_damage_checker.png",
   on_use = function(itemstack, user, pointed_thing)
      if pointed_thing.type ~= "node" then return end
      local pname = user:get_player_name()
      -- Get hp
      local pos = minetest.get_pointed_thing_position(pointed_thing)
      local meta = minetest.get_meta(pos)
      local hp = meta:get_int("node_hp")
      local max_hp = protected_damage.get_node_strength(minetest.get_node(pos).name)
      -- Tell player
      minetest.chat_send_player(pname, get_node_strength_str(hp, max_hp))
      -- Add wear
      itemstack:add_wear(100)

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

-- Register tool to repair node
minetest.register_tool("protected_damage:repair_tool", {
   description = "Node Repair Tool",
   inventory_image = "protected_damage_repair_tool.png",
   on_use = function(itemstack, user, pointed_thing)
      -- Check pointed_thing
      if pointed_thing.type ~= "node" then return end
      -- Check protection
      local pname = user:get_player_name()
      local pos = minetest.get_pointed_thing_position(pointed_thing)
      if minetest.is_protected(pos, pname) then return end
      -- Check node hp
      local meta = minetest.get_meta(pos)
      local hp = meta:get_int("node_hp")
      local max_hp = protected_damage.get_node_strength(minetest.get_node(pos).name)
      if hp >= max_hp then return end
      -- Repair
      hp = hp + 50
      if hp > max_hp then hp = max_hp end
      meta:set_int("node_hp", hp)
      itemstack:add_wear(500)
      -- Tell player
      minetest.chat_send_player(pname, get_node_strength_str(hp, max_hp))
      return itemstack
   end
})
minetest.register_craft({
   output = "protected_damage:repair_tool",
   recipe = {
      {"", "", "default:steelblock"},
      {"", "default:steel_ingot", ""},
      {"default:steel_ingot", "", ""}
   }
})

-- Register siege hammer
minetest.register_tool("protected_damage:siege_hammer", {
   description = "Siege Hammer (Damages protected blocks during war)",
   inventory_image = "protected_damage_siege_hammer.png",
   tool_capabilities = {
		full_punch_interval = 5,
		max_drop_level = 0,
		range = 1,
		groupcaps={
			cracky = {times={[1]=8.0, [2]=4.0, [3]=2.0}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=5},
   },
   on_use = function(itemstack, user, pointed_thing)
      -- Check pointed_thing
      if pointed_thing.type ~= "node" then return end
      -- Check protection
      local pname = user:get_player_name()
      local pos = minetest.get_pointed_thing_position(pointed_thing)
      if minetest.is_protected(pos, pname) ~= true then
         minetest.chat_send_player(pname, "The siege hammer can only be used on areas protected by other kingdoms")
         return
      end
      -- Damage
      protected_damage.damage(pos, 1, pname)
      itemstack:add_wear(50)
      return itemstack
   end
})

minetest.register_craft({
   output = "protected_damage:siege_hammer",
   recipe = {
      {"default:obsidian", "default:obsidian", "default:obsidian"},
      {"default:obsidian", "default:steelblock", "default:obsidian"},
      {"", "group:wood", ""}
   }
})
