function kingdoms.get_gui(pname, tab)
   local fs = "size[8,9;]button[0,0;2,1;news;News]"
   -- Get news tabs
   if tab == nil or tab == "news" then
      fs = fs .. "textlist[0,1;7.8,8;news;"
      -- Get news and break it into lines
      local ntable = kingdoms.get_news(20)
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
   end
end
