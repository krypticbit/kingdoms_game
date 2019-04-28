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
      -- Check for a gui entry
      local doadd = false
      if kingdoms_gui[pname].apls == nil then
         kingdoms_gui[pname].apls = {}
         kingdoms_gui[pname].apls.apls = {}
         kingdoms_gui[pname].apls.index = 0
         doadd = true
      end
      -- Get info
      local idx = kingdoms_gui[pname].apls.index
      -- Generate textlist
      fs = fs .. "textlist[0,1;7.8,7;aplslist;Kingdom Applicants:,"
      for n,k in pairs(kingdoms.pending) do
         if k == kingdom then
            fs = fs .. n .. ","
            -- Add applicant to table
            if doadd then
               table.insert(kingdoms_gui[pname].apls.apls, n)
            end
         end
      end
      fs = fs:sub(1, -2) .. ";" .. tostring(kingdoms_gui[pname].apls.index) .. ";false]"
      -- Add accept / reject buttons
      minetest.log(tostring(kingdoms_gui[pname].apls.index))
      minetest.log(minetest.serialize(kingdoms_gui[pname].apls.apls))
      if idx > 1 and kingdoms.player_has_priv(pname, "recruiter") then -- Idx 1 == "Kingdom Applications:"
         local victim = kingdoms_gui[pname].apls.apls[idx - 1]
         fs = fs .. "button[0,8.3;2,1;acpt;Accept]"
         fs = fs .. "button[2,8.3;2,1;rejc;Reject]"
      end
      -- Present
      minetest.show_formspec(pname, "kingdoms:gui_apls", fs)
   elseif tab == "diplo" then
      -- Check for a gui entry
      local doadd = false
      if kingdoms_gui[pname].diplo == nil then
         kingdoms_gui[pname].diplo = {}
         kingdoms_gui[pname].diplo.kds = {}
         kingdoms_gui[pname].diplo.index = 0
         doadd = true
      end
      -- Generate textlist
      fs = fs .. "textlist[0,1;7.8,7;klist;Kingdoms:,"
      local pkingdom = kingdoms.members[pname].kingdom
      for n,k in pairs(kingdoms.kingdoms) do
         if n ~= pkingdom then
            local r = kingdoms.get_relation(pkingdom, n)
            if r.id == kingdoms.relations.war then
               fs = fs .. "#FF0000" .. n .. ","
            elseif r.id == kingdoms.relations.peace then
               if r.pending then
                  fs = fs .. "#FFA500" .. n .. ","
               else
                  fs = fs .. "#FFFFFF" .. n .. ","
               end
            elseif r.id == kingdoms.relations.alliance then
               if r.pending then
                  fs = fs .. "#90EE90" .. n .. ","
               else
                  fs = fs .. "#00FF00" .. n .. ","
               end
            end
            if doadd then
               table.insert(kingdoms_gui[pname].diplo.kds, n)
            end
         end
      end
      fs = fs:sub(1, -2) .. ";" .. tostring(kingdoms_gui[pname].diplo.index) .. ";false]"
      -- Add elements for selected kingdom
      if kingdoms_gui[pname].diplo.index > 1 and kingdoms.player_has_priv(pname, "diplomat") then
         local kname = kingdoms_gui[pname].diplo.kds[kingdoms_gui[pname].diplo.index - 1]
         local r = kingdoms.get_relation(pkingdom, kname)
         if r.id == kingdoms.relations.war then
            fs = fs .. "button[0,8.3;3,1;reqp;Request Peace]"
         elseif r.id == kingdoms.relations.peace then
            if r.pending == pkingdom then
               fs = fs .. "button[0,8.3;3,1;acpp;Accept Peace Request]"
               fs = fs .. "button[3,8.3;3,1;dclp;Decline Peace Request]"
            elseif r.pending == kname then
               fs = fs .. "button[0,8.3;3,1;cnclpr;Cancel Peace Request]"
            else
               fs = fs .. "button[0,8.3;3,1;decw;Declare War]"
               fs = fs .. "button[3,8.3;3,1;reqa;Request Alliance]"
            end
         elseif r.id == kingdoms.relations.alliance then
            if r.pending == pkingdom then
               fs = fs .. "button[0,8.3;3,1;acpar;Accept Alliance Request]"
               fs = fs .. "button[3,8.3;3,1;dclar;Decline Alliance Request]"
            elseif r.pending == kname then
               fs = fs .. "button[0,8.3;3,1;cnclar;Cancel Alliance Request]"
            else
               fs = fs .. "button[0,8.3;3,1;cncla;Cancel Alliance]"
            end
         end
      end
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
   -- Get kingdom
   local pkingdom = kingdoms.members[pname].kingdom
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
         return
      end
      -- Buttons were pushed
      if selected == nil then return end
      if fields["acpt"] then -- Accepted
         kingdoms_gui[pname].apls = nil
         kingdoms.add_player_to_kingdom(kingdoms.members[pname].kingdom, selected)
         kingdoms.pending[selected] = nil
         kingdoms.helpers.save()
         kingdoms.set_gui(pname, "apls")
      elseif fields["rejc"] then -- Rejected
         kingdoms_gui[pname].apls = nil
         kingdoms.pending[selected] = nil
         kingdoms.helpers.save()
         kingdoms.set_gui(pname, "apls")
      end
   elseif formname == "kingdoms:gui_diplo" then
      -- If a kingdom is not selected, selected = nil
      local selected
      if kingdoms_gui[pname].diplo.index > 1 then
         selected = kingdoms_gui[pname].diplo.kds[kingdoms_gui[pname].diplo.index - 1]
      end
      -- Different kingdom was selected
      if fields["klist"] ~= nil then
         local e = minetest.explode_textlist_event(fields["klist"])
         if e.type == "CHG" then
            kingdoms_gui[pname].diplo.index = e.index
            kingdoms.set_gui(pname, "diplo")
         end
         return
      end
      -- Buttons were pushed
      if selected == nil then return end
      if fields["reqp"] then -- Peace requested
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.peace,
            pending = selected
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["acpp"] then -- Peace accepted
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.peace
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["dclp"] then -- Peace denied
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.war
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["cnclpr"] then -- Peace canceled
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.war
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["decw"] then -- Declare war
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.war
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["reqa"] then -- Request alliance
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.alliance,
            pending = selected
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["acpar"] then -- Accept alliance request
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.alliance
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["dclar"] then -- Decline alliance request
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.peace
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["cnclar"] then -- Cancel alliance request
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.peace
         })
         kingdoms.set_gui(pname, "diplo")
      elseif fields["cncla"] then -- Cancel alliance
         kingdoms.set_relation(pkingdom, selected, {
            id = kingdoms.relations.peace
         })
         kingdoms.set_gui(pname, "diplo")
      end
   end
end)

-- Reset gui on leave
minetest.register_on_leaveplayer(function (p)
   kingdoms_gui[p:get_player_name()] = nil
end)
