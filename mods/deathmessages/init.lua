local murdered_reasons = {
   "{victim} was slapped to death by {killer}.",
   "{killer} removed {victim}'s head from his body.",
   "{killer} gave {victim} a free trip to heaven.",
   "{victim} was perforated by {killer}.  Oops.",
   "{killer} sliced'n'diced {victim}."
}

local fall_reasons = {
   "{victim} tripped over his own feet ... at the edge of a cliff",
   "{victim} went splat",
   "{victim} took a fast run off of a tall cliff",
   "{victim} thought he could fly.  He was wrong.",
   "{victim} kissed the groud a bit too enthusiastically."
}

local lava_reasons = {
   "{victim} discovered that lava was hot.",
   "{victim} went for a warm swim.  A very warm swim.",
   "{victim} burned to death.",
   "{victim} was eaten by a hungry lava node."
}

local drowned_reasons = {
   "{victim} took a long walk off of a short pier.",
   "{victim} forgot he couldn't breathe underwater",
   "{victim} got a lungful of good ol' H2O.",
   "{victim} found out that he wasn't a fish."
}

local other_reasons = {
   "{victim} probably shouldn't have done that.",
   "{victim} did something stupid.",
   "{victim} randomly died.",
   "{victim} kicked the bucket.",
   "{victim} was done with life.",
   "{victim} received a one-way ticket to heaven."
}

local function get_reason(l, v)
   return l[math.random(#l)]:gsub("{victim}", v)
end

local function broadcast(msg)
   msg = "[DeathMessage] " .. msg
   minetest.chat_send_all(msg)
   if irc then irc:say(msg) end
end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
   -- Check if the player was damaged or healed
   if hp_change > 0 then return end
   -- Check if the player is already dead
   local hp = player:get_hp()
   if hp <= 0 then return end
   -- Check if the player will die
   if hp + hp_change > 0 then return end
   -- Announce death message
   local victim = player:get_player_name()
   if reason.type == "set_hp" then
      -- Player was killed by mod (unknown reason)
      local msg = get_reason(other_reasons, victim)
      broadcast(msg)
   elseif reason.type == "punch" then
      if reason.object == nil then
         -- Player was killed by unknown object
         local msg = get_reason(other_reasons, victim)
         broadcast(msg)
      elseif reason.object:is_player() == false then
         -- Player was killed by non-player (monster?)
         local msg = get_reason(other_reasons, victim)
         broadcast(msg)
      else
         -- Player was killed by player
         local killer = reason.object:get_player_name()
         local msg = get_reason(murdered_reasons, victim):gsub("{killer}", killer)
         broadcast(msg)
      end
   elseif reason.type == "fall" then
      local msg = get_reason(fall_reasons, victim)
      broadcast(msg)
      -- Player was killed by fall damage
   elseif reason.type == "node_damage" then
      -- Player was killed by node damage
      local n = minetest.registered_nodes[minetest.get_node(player:get_pos()).name]
      if n ~= nil and n.groups ~= nil and n.groups.lava then
         -- Killed by lava
         local msg = get_reason(lava_reasons, victim)
         broadcast(msg)
      else
         -- Killed with something else
         local msg = get_reason(other_reasons, victim)
         broadcast(msg)
      end
   elseif reason.type == "drown" then
      -- Player drowned
      local msg = get_reason(drowned_reasons, victim)
      broadcast(msg)
   end
end)
