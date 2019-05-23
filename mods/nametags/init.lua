local nametag_scale = 0.2

minetest.register_entity("nametags:nametag", {
   hp_max = 1,
   physical = false,
   weight = 0,
   visual = "sprite",
   selectionbox = {0, 0, 0, 0, 0, 0},
   collisionbox = {0, 0, 0, 0, 0, 0},
   on_activate = function(e, sdata)
      -- Check if valid sdata was given
      if sdata == nil or sdata == "" then
         e.object:remove()
         return
      end
      -- Check if player is online
      local pobj = minetest.get_player_by_name(sdata)
      if pobj == nil then
         e.object:remove()
      end
      -- Make entity immortal
      e.object:set_armor_groups({immortal = 1})
      -- Finalize nametag
      local tex, xsize = signs_lib.make_line_texture({sdata})
      e._pname = sdata
      e.object:set_properties({
         textures = {tex},
         visual_size = {x = xsize * nametag_scale, y = nametag_scale},
      })
      e.object:set_attach(pobj, "", {x = 0, y = 20, z = 0}, {x = 0, y = 0, z = 0})
   end,
   on_step = function(e)
      local p = minetest.get_player_by_name(e._pname)
      if p == nil then
         e.object:remove()
      else
         e.object:set_attach(p, "", {x = 0, y = 20, z = 0}, {x = 0, y = 0, z = 0})
      end
   end
})

minetest.register_on_joinplayer(function(pobj)
   minetest.after(2, function ()
      minetest.add_entity(pobj:get_pos(), "nametags:nametag", pobj:get_player_name())
   end)
   pobj:set_nametag_attributes({text = " "})
end)
