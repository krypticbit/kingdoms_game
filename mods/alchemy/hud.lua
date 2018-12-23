local function find_first_gap(t)
   local num = 0
   while true do
      if t[num] == nil then
         return num
      end
      num = num + 1
   end
end

local function get_effect_hud_text(effect)
   return effect.name .. ": " .. tostring(effect.time)
end

local function generate_effect_hud(player, num, text)
   local ids = {}
   ids["main"] = player:hud_add({
      hud_elem_type = "text",
      position = {x = 1, y = 0.3},
      offset = {x = -100, y = num * 15},
      text = text
   })
   return ids
end

local function add_effect(player, e)
   local text = get_effect_hud_text(e)
   local num = find_first_gap(alchemy.effect_hud)
   alchemy.effect_hud[num] = generate_effect_hud(player, num, text)
   return num
end

local function update_effect(player, num, e)
   local ids = alchemy.effect_hud[num]
   local text = get_effect_hud_text(e)
   player:hud_change(ids["main"], "text", text)
end

local function remove_effect(player, num, e)
   local ids = alchemy.effect_hud[num]
   for _, hNum in pairs(ids) do
      player:hud_remove(hNum)
   end
   alchemy.effect_hud[num] = nil
end

alchemy.hud.add_effect = add_effect
alchemy.hud.update_effect = update_effect
alchemy.hud.remove_effect = remove_effect
