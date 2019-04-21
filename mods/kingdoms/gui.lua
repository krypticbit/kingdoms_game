function kingdoms.get_gui(pname, tab)
   local fs = "size[8,9;]button[0,0;2,1;news;News]button[2,0;2,1;apls;Applications]"
   local kingdom = kingdoms.members[pname].kingdom
   -- Get news tabs
   if tab == nil or tab == "news" then
      fs = fs .. "textlist[0,1;7.8,8;newslist;Server News:,"
      -- Get news and break it into lines
      local ntable = kingdoms.get_news(30)
      local nidx = 1
      local lidx
      local lines
      while true do
         if ntable[nidx] == nil then break end
         lines = kingdoms.helpers.split_into_lengths(ntable[nidx], 70)
         lidx = 1
         while true do
            if lines[lidx] == nil then break end
            fs = fs .. minetest.formspec_escape(lines[lidx]) .. ","
            lidx = lidx + 1
         end
         nidx = nidx + 1
      end
      fs = fs:sub(1, -2) .. "]"
      return fs
   elseif tab == "apls" then
      fs = fs .. "textlist[0,1;7.8,8;aplslist;Kingdom Applications:,"
      for n,k in pairs(kingdoms.pending) do
         if k == kingdom then
            fs = fs .. n .. ","
         end
      end
      fs = fs:sub(1, -2) .. "]"
      return fs
   end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
   -- Check if this is one of the correct forms
   if formname:find("^kingdoms:gui") == nil then return end
   local pname = player:get_player_name()
   -- Check if we are moving to a different tab
   if fields["news"] then
      minetest.show_formspec(pname, "kingdoms:gui_news", kingdoms.get_gui(pname, "news"))
      return
   elseif fields["apls"] then
      minetest.show_formspec(pname, "kingdoms:gui_apls", kingdoms.get_gui(pname, "apls"))
      return
   end
end)
