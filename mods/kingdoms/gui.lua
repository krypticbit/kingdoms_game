local kingdoms_gui = {}

function kingdoms.set_gui(pname, tab)
   -- Check if a gui table exists
   if kingdoms_gui[pname] == nil then
      kingdoms_gui[pname] = {}
   end
   local fs = "size[8,9;]button[0,0;2,1;news;News]" ..
      "button[2,0;2,1;apls;Applications]" ..
      "button[4,0;2,1;diplo;Diplomacy]"
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
      minetest.show_formspec(pname, "kingdoms:gui_news", fs)
   elseif tab == "apls" then
      -- Check if a gui entry exists
      if kingdoms_gui[pname].apls == nil then
         kingdoms_gui[pname].apls = {}
         kingdoms_gui[pname].apls.apls = {}
         kingdoms_gui[pname].apls.index = 0
      end
      -- Get info
      local idx = kingdoms_gui[pname].apls.index
      -- Generate fs
      fs = fs .. "textlist[0,1;7.8,7;aplslist;Kingdom Applications:,"
      for n,k in pairs(kingdoms.pending) do
         if k == kingdom then
            fs = fs .. n .. ","
            -- Add applicant to table
            table.insert(kingdoms_gui[pname].apls.apls, n)
         end
      end
      fs = fs:sub(1, -2) .. ";" .. tostring(kingdoms_gui[pname].apls.index) .. ";false]"
      -- Add accept / reject buttons
      minetest.log(tostring(kingdoms_gui[pname].apls.index))
      minetest.log(minetest.serialize(kingdoms_gui[pname].apls.apls))
      if idx > 1 then -- Idx 1 == "Kingdom Applications:"
         local victim = kingdoms_gui[pname].apls.apls[idx - 1]
         fs = fs .. "button[0,8.3;2,1;acpt_" .. victim .. ";Accept]"
         fs = fs .. "button[2,8.3;2,1;rejc_" .. victim .. ";Reject]"
      end
      -- Present
      minetest.show_formspec(pname, "kingdoms:gui_apls", fs)
   elseif tab == "diplo" then
      fs = fs .. "label[0,1;Diplomacy]"
      -- Present
      minetest.show_formspec(pname, "kingdoms:gui_diplo",  fs)
   end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
   -- Check if this is one of the correct forms
   if formname:find("^kingdoms:gui") == nil then return end
   local pname = player:get_player_name()
   -- Check if we are moving to a different tab
   if fields["news"] then
      kingdoms.set_gui(pname, "news")
      return
   elseif fields["apls"] then
      kingdoms.set_gui(pname, "apls")
      return
   elseif fields["diplo"] then
      kingdoms.set_gui(pname, "diplo")
      return
   end
   -- Check if selection changed / button pushed
   if formname == "kingdoms:gui_apls" then
      -- If a player is not selected, selected = nil
      local selected
      if kingdoms_gui[pname].apls.index > 1 then
         selected = kingdoms_gui[pname].apls.apls[kingdoms_gui[pname].apls.index - 1]
      end
      -- Different player was selected
      if fields["aplslist"] ~= nil then
         local e = minetest.explode_textlist_event(fields["aplslist"])
         if e.type == "CHG" then
            kingdoms_gui[pname].apls.index = e.index
            kingdoms.set_gui(pname, "apls")
         end
      -- Accept button was pushed
   elseif selected and fields["acpt_" .. selected] then
         kingdoms_gui[pname].apls = nil
         kingdoms.add_player_to_kingdom(kingdoms.members[pname].kingdom, selected)
         kingdoms.pending[selected] = nil
         kingdoms.helpers.save()
         kingdoms.set_gui(pname, "apls")
      -- Reject button was pushed
   elseif selected and fields["rejc_" .. selected] then
         kingdoms_gui[pname].apls = nil
         kingdoms.pending[selected] = nil
         kingdoms.helpers.save()
         kingdoms.set_gui(pname, "apls")
      end
   end
end)

-- Reset gui on leave
minetest.register_on_leaveplayer(function (p)
   kingdoms_gui[p:get_player_name()] = nil
end)
