skins = {}
skins.skins = {}
skins.skin_path = minetest.get_modpath("simple_skins").."/textures/"
skins.pages = {}

local storage = minetest.get_mod_storage()
local playersStr = storage:get_string("players")
if playersStr == "" then
   skins.players = {}
else
   skins.players = minetest.deserialize(playersStr)
end

skins.save = function()
   local pStr = minetest.serialize(skins.players)
   storage:set_string("players", pStr)
end

skins.add = function(skinNum)
   skins.skins[skinNum] = {
      texture = "texture_" .. skinNum .. ".png",
      preview = "preview_" .. skinNum .. ".png"
   }
end

skins.show_page = function(player, pagenum)
   minetest.show_formspec(player:get_player_name(), "skins_page" .. pagenum, skins.pages[pagenum])
end

skins.set_player_skin = function(player)
   local n = player:get_player_name()
   local skinNum = skins.players[n]
   if skinNum == nil then return end
   local skinTex = skins.skins[skinNum].texture
   minetest.chat_send_all(skinTex)
   -- Use functions from 3d_armor to prevent conflicts
   armor.textures[n].skin = skinTex
   armor:update_player_visuals(player)
end

-- Load skins
local num = 1
while true do
   local skinName = "texture_" .. num .. ".png"
   local skinF = io.open(skins.skin_path .. skinName)
   if skinF then
      skinF:close()
      skins.add(num)
      num = num + 1
   else
      break
   end
end

-- Generate pages
local offset = 0.2
local itemWidth = 1
local itemHeight = itemWidth * 2
local itemsPerRow = 7
local itemsPerColumn = 2
local itemsPerPage = itemsPerRow * itemsPerColumn
local numPages = math.ceil(#skins.skins / (itemsPerPage))
local texNum = 1
local pageFs
local p
local c
local r
local x
local y

for p = 1, numPages do
   pageFs = "size[8.6,5.4]" ..
   "button[0.2,4.6;1,1;back;<]" ..
   "button[7.4,4.6;1,1;forward;>]"
   for c = 0, itemsPerColumn - 1 do
      for r = 0, itemsPerRow - 1 do
         if skins.skins[texNum] == nil then
            break
         end
         x = r * (itemWidth + offset) + offset
         y = c * (itemHeight + offset) + offset
         pageFs = pageFs .. "image_button[" .. x .. "," .. y .. ";" .. itemWidth .. "," .. itemHeight .. ";" .. skins.skins[texNum].preview .. ";skin" .. texNum .. ";]"
         texNum = texNum + 1
      end
   end
   skins.pages[p] = pageFs
end

minetest.register_on_joinplayer(function(p)
   inventory_plus.register_button(p, "skins")
   skins.set_player_skin(p)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
   if fields.skins then
      skins.show_page(player, 1)
   elseif formname:find("^skins_page%d+$") then
      local pageNum = tonumber(formname:sub(11, -1))
      if fields.back then
         if pageNum > 1 then
            pageNum = pageNum - 1
            skins.show_page(player, pageNum)
         end
      elseif fields.forward then
         if pageNum < #skins.pages then
            pageNum = pageNum + 1
            skins.show_page(player, pageNum)
         end
      else
         local firstItem = itemsPerPage * (pageNum - 1)
         local lastItem = firstItem + itemsPerPage
         for i = firstItem, lastItem do
            if fields["skin" .. i] then
               skins.players[player:get_player_name()] = i
               skins.set_player_skin(player)
               skins.save()
               break
            end
         end
      end
   end
end)
