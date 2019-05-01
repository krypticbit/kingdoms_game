local selected_article = {}
local link_pattern = "%{%w+%}"

-- Load
local storage = minetest.get_mod_storage()
local aStr = storage:get_string("articles")
local articles
if aStr == "" then
   articles = {}
   table.insert(articles, {
      title = "Main",
      text = "This is the main article. {1}"
   })
else
   articles = minetest.deserialize(aStr)
end

-- Functions
local function save()
   local saveStr = minetest.serialize(articles)
   storage:set_string("articles", saveStr)
end

local function show_guide(name, aIndex)
   local canEdit = minetest.check_player_privs(name, {server = true})
   -- Check if article exists
   if aIndex == nil or articles[aIndex] == nil then aIndex = selected_article[name] or 1 end
   -- Generate list of articles
   local fs
   if canEdit then
      fs = "size[8,9;]textlist[0,0;2,8;articles;"
   else
      fs = "size[8,9;]textlist[0,0;2,9;articles;"
   end
   local didAdd = false
   for lName in articles[aIndex].text:gmatch(link_pattern) do
      local idx = tonumber(lName:sub(2, -2))
      if articles[idx] then
         fs = fs .. articles[idx].title .. ","
         didAdd = true
      end
   end
   if didAdd then
      fs = fs:sub(1, -2) .. "]"
   else
      fs = fs .. "]"
   end
   -- Add selected article
   local sArticle = articles[aIndex]
   if canEdit then
      fs = fs .. "field[2.5,0.5;5.5,1;title;Title:;" .. sArticle.title .. "]" ..
         "textarea[2.5,1.6;5.5,7.5;content;Article " .. tostring(aIndex) .. ":;" ..
         sArticle.text .. "]" ..
         "button[0,8.4;2,1;save;Save]" ..
         "button[2,8.4;2,1;add;Add New Article]"
   else
      fs = fs .. "textarea[2.5,0.35;6,9;;" .. sArticle.title .. ":;" ..
         sArticle.text:gsub(link_pattern, "") .. "]"
   end
   -- Show
   minetest.show_formspec(name, "guide:guide", fs)
end

local function set_article(idx, title, text)
   articles[idx] = {
      title = title,
      text = text
   }
   save()
end

-- Handle article switching
minetest.register_on_player_receive_fields(function(player, formname, fields)
   if formname ~= "guide:guide" then return end
   local pname = player:get_player_name()
   -- Handle input
   if fields["articles"] then -- Article was changed
      local e = minetest.explode_textlist_event(fields["articles"])
      if e.type == "CHG" then
         show_guide(pname, e.index)
         selected_article[pname] = e.index
      end
   elseif fields["save"] then -- Save was pressed
      -- If an article is not selected, it's the default article
      local idx = selected_article[pname] or 1
      -- Set article
      set_article(idx, fields["title"], fields["content"])
      -- Show article
      show_guide(pname, idx)
   elseif fields["add"] then -- Add article
      local idx = #articles + 1
      selected_article[pname] = idx
      set_article(idx, "New Article", "Content {1}")
      show_guide(pname, idx)
   end
end)

-- Chat command
minetest.register_chatcommand("guide", {
   params = "[<article>]",
   description = "Show server guide",
   privs = {},
   func = function(name, article)
      show_guide(name, article)
   end
})
