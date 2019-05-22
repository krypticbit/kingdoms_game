-- vim: set sw=2:
-- Set Vim’s shiftwidth to 2 instead of 4 because the functions in this file
-- are deeply nested and there are some long lines. 2 instead of 4 gives a tiny
-- bit more space for each indentation level.


-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator
local costs = hunger_ng.costs

-- Localize Minetest
local chat_send = minetest.chat_send_player
local minetest_log = minetest.log


-- When a player digs or places a node the corresponding hunger alteration
-- will be applied
minetest.register_on_dignode(function(p, on, digger)
  if digger then
    f.alter_hunger(digger:get_player_name(), -costs.dig, 'digging')
  end
end)
minetest.register_on_placenode(function(p, nn, placer, on, is, pt)
  if placer then
    f.alter_hunger(placer:get_player_name(), -costs.place, 'placing')
  end
end)


-- If a player dies and respawns the hunger value will be properly deleted and
-- after respawn it will be set again. This avoids the player healing even if
-- the player died.
minetest.register_on_dieplayer(function(player)
  f.alter_hunger(player:get_player_name(), -s.hunger.maximum, 'death')
  return true
end)
minetest.register_on_respawnplayer(function(player)
  f.alter_hunger(player:get_player_name(), s.hunger.maximum, 'respawn')
end)


-- Custom eating function
--
-- When the player eaths an item it is checked if the item has the custom
-- _hunger_ng attribute set. If no, the eating won’t be intercepted by the
-- function and the item will be eat regularly.
--
-- If the item has the attribute set then it will be processed and the heal
-- and hunger values will be applied according to the item’s settings.
--
-- If the item has a timeout and the timeout is still active the user gets an
-- information about this mentioning the timeout and how long the user has to
-- wait before being able to eat again.
minetest.register_on_item_eat(function(hpc, rwi, itemstack, user, pt)
  local definition = itemstack:get_definition()._hunger_ng
  if user:is_player() ~= true or definition == nil then return end
  local player_name = user:get_player_name()

  local current_hunger = f.get_data(player_name, a.hunger_value)
  local hunger_disabled = f.get_data(player_name, a.hunger_disabled)

  if minetest.is_yes(hunger_disabled) then
    chat_send(player_name, S('Hunger is disabled for you! Eating normally.'))
    return
  end

  if current_hunger == s.hunger.maximum then
    chat_send(player_name, S('You’re fully satiated already!'))
    return itemstack
  end

  if definition.returns then
    local inventory = user:get_inventory()
    if not inventory:room_for_item('main', definition.returns..' 1') then
      local message = S('You have no inventory space to keep the leftovers.')
      chat_send(player_name, message)
      return itemstack
    end
  end

  local timeout = definition.timeout or s.hunger.timeout
  local current_timestamp = os.time()
  local player_timestamp = f.get_data(player_name, a.eating_timestamp)

  if current_timestamp < player_timestamp + timeout then
    local wait = player_timestamp + timeout - current_timestamp
    local message = S('You’re eating too fast!')
    local info = S('Wait for eating timeout to end: @1s', wait)
    chat_send(player_name, message..' '..info)
    return itemstack
  else
    f.set_data(player_name, a.eating_timestamp, current_timestamp)
  end

  local heals = definition.heals or 0
  local satiates = definition.satiates or 0

  minetest.sound_play('hunger_ng_eat', { to_player = player_name })
  f.alter_hunger(player_name, satiates, 'eating')
  f.alter_health(player_name, heals, 'eating')
  itemstack:take_item(1)

  if definition.returns then
    local inventory = user:get_inventory()
    inventory:add_item('main', definition.returns..' 1')
  end

  return itemstack
end)


-- Initial hunger and hunger bar configuration
--
-- When a player joins it is checked if the custom attribute for hunger is set.
-- If hunger persistence is used then the value gets read and applied to the
-- hunger bar.
--
-- If the value is not set or hunger persistence is not used then the hunger
-- value to start with will be used. This can be different from the maximum
-- hunger value.
minetest.register_on_joinplayer(function(player)
  local player_name = player:get_player_name()
  local unset = not f.get_data(player_name, a.hunger_value)
  local reset = f.get_data(player_name, a.hunger_value) and not s.hunger.persistent

  if unset or reset then
    if c.debug_mode then
      local message = 'Set initial hunger values for '..player_name
      minetest_log('action', c.log_prefix..message)
    end
    f.set_data(player_name, a.hunger_value, s.hunger.start_with)
    f.set_data(player_name, a.eating_timestamp, 0)
    f.set_data(player_name, a.hunger_disabled, 0)
  end

  if s.hunger_bar.use then
    f.set_data(player_name, a.hunger_bar_id, player:hud_add({
      hud_elem_type = 'statbar',
      position = { x=0.5, y=1 },
      text = s.hunger_bar.image,
      direction = 0,
      number = f.get_data(player_name, a.hunger_value),
      size = { x=24, y=24 },
      offset = {x=25,y=-(48+24+16)},
    }))
  end
end)
