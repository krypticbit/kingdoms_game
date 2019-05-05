--
-- Normal beakers
--

local box = {
   {-0.099, -0.483, -0.099, 0.099, -0.291, 0.099},
   {-0.053, -0.291, -0.053, 0.053, -0.206, 0.053},
   {-0.071, -0.206, -0.071, 0.071, -0.186, 0.071},
}

-- Empty beaker
minetest.register_node("alchemy:beaker_empty", {
   description = "Empty Beaker",
   drawtype = "mesh",
   groups = {vessel = 1, beaker = 1}, -- Unbreakable but picked up on punch - no particles
   paramtype = "light",
   sunlight_propagates = true,
   inventory_image = "beaker_empty.png",

   tiles = {
      "beaker.png"
   },

   node_box = {
      type = "fixed",
      fixed = box,
   },

   selection_box = {
      type = "fixed",
      fixed = box,
   },

   mesh = "beaker_empty.x",

   on_punch = function(pos, node, puncher)
      local pName = puncher:get_player_name()
      -- Check protection
      if minetest.is_protected(pos, pName) then
         minetest.record_protection_violation(pos, pName)
         return
      end
      -- Pick up node
      minetest.node_dig(pos, node, puncher)
   end
})

-- Full beaker(s)
local function register_beaker(name, description, texture)

   local bname = "alchemy:beaker_" .. name
   local desc = "Beaker of " .. description

   minetest.register_node(bname, {
      description = desc,
      drawtype = "mesh",
      groups = {vessel = 1, beaker = 1}, -- Unbreakable but picked up on punch - no particles
      paramtype = "light",
      stack_max = 1,
      sunlight_propagates = true,
      inventory_image = texture .. "^beaker_mask.png^[makealpha:0,0,0^beaker_empty.png",

      tiles = {
         "beaker.png",
         texture
      },

      node_box = {
         type = "fixed",
         fixed = box,
      },

      selection_box = {
         type = "fixed",
         fixed = box,
      },

      mesh = "beaker.x",

      after_place_node = function(pos, placer, itemstack, pointed_thing)
         local sMeta = itemstack:get_meta()
         local meta = minetest.get_meta(pos)
         local concentration = sMeta:get_int("concentration")
         if concentration == 0 then
            concentration = 1
         end
         meta:set_int("concentration", concentration)
         meta:set_string("infotext", desc .. "\nConcentration: " .. concentration)
      end,


      on_punch = function(pos, node, puncher)
         local pName = puncher:get_player_name()
         -- Check protection
         if minetest.is_protected(pos, pName) then
            minetest.record_protection_violation(pos, pName)
            return
         end
         -- Dig node
         local playerInv = puncher:get_inventory()
         local oldmeta = minetest.get_meta(pos)
         local stack = ItemStack(node.name)
         local stackMeta = stack:get_meta()
         local concentration = oldmeta:get_int("concentration")
         if concentration == 0 then
            concentration = 1
         end
         stackMeta:set_int("concentration", concentration)
         alchemy.helpers.set_beaker_descripton(stack)
         minetest.remove_node(pos)
         if playerInv:room_for_item("main", stack) then
            playerInv:add_item("main", stack)
         else
            minetest.add_entity(pos, "__builtin:item", stack:to_string())
         end
      end,

      on_drop = function(itemstack, dropper, pos)
         -- Get effect function
         local effect = alchemy.effects[name]
         -- Get concentration level
         local cLevel = itemstack:get_meta():get_int("concentration")
         if cLevel == 0 then cLevel = 1 end
         -- Run effect
         if effect then
            effect(dropper, pos, cLevel)
         end
         itemstack:take_item()
         return itemstack
      end
   })
end

--
-- Splash beakers
--

local splash_radius = 2
local splash_box = {
   {-0.1, -0.5, -0.1, 0.1, -0.1, 0.1}
}

minetest.register_entity("alchemy:splash_entity", {
   initial_properties = {
      visual = "mesh",
      mesh = "beaker_splash.x",
      weight = 5,
      physical = true,
      collide_with_objects = false,
      selectionbox = {
         type = "fixed",
         fixed = {0, 0, 0, 0, 0, 0}
      },
      collisionbox = {
         type = "fixed",
         fixed = splash_box
      }
   },
   on_activate = function(e, sdata)
      -- Check if sdata exists
      if sdata == nil then
         e.object:remove()
         return
      end
      sdata = minetest.deserialize(sdata)
      if sdata == nil then
         e.object:remove()
         return
      end
      -- Set texture
      e.object:set_properties({textures = {"beaker.png", sdata.tex}})
      -- Set params
      e.cLevel = sdata.cLevel
      e.name = sdata.name
      e.texpart = sdata.texpart
      e.orig_vel = sdata.orig_vel
   end,
   on_step = function(e)
      -- Check if upward velocity is 0 or velocity changed directions
      local v = e.object:get_velocity()
      if v.y == 0 or math.abs(v.x - e.orig_vel.x) > 0.1 or math.abs(v.z - e.orig_vel.z) > 0.1 then
         local pos = e.object:get_pos()
         -- Get effect function
         local effect = alchemy.effects[e.name]
         -- Run effect for nearby players
         for _, p in pairs(minetest.get_objects_inside_radius(pos, splash_radius)) do
            if p:is_player() then
               effect(p, pos, e.cLevel)
            end
         end
         -- Add particles
         minetest.add_particlespawner({
            amount = 30,
            time = 0.5,
            minpos = pos,
            maxpos = pos,
            minvel = {x = -1, y = 0, z = -1},
            maxvel = {x = 1, y = 3, z = 1},
            minacc = {x = 0, y = 0, z = 0},
            maxacc = {x = 0, y = 0, z = 0},
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            texture = e.texpart
         })
         -- Remove entity
         e.object:remove()
         return
      end
      -- Move down
   end
})

local function register_splash_beaker(name, description, texture)

   local bname = "alchemy:splash_beaker_" .. name
   local desc = "Splash Beaker of " .. description
   local tex = texture .. "^splash_beaker_mask.png^[makealpha:0,0,0^splash_beaker_empty.png"

   minetest.register_node(bname, {
      description = desc,
      drawtype = "mesh",
      mesh = "beaker_splash.x",
      tiles = {"beaker.png", texture},
      stack_max = 1,
      inventory_image = tex,
      on_drop = function(itemstack, dropper, pos)
         -- Get concentration level
         local cLevel = itemstack:get_meta():get_int("concentration")
         if cLevel == 0 then cLevel = 1 end
         -- Get random section of texture
         local texpart = ("[combine:3x3:%d,%d=" .. texture):format(math.random(-29, 0), math.random(-29, 0))
         -- Spawn entity
         local pos = dropper:get_pos()
         local vel = vector.multiply(dropper:get_look_dir(), 20)
         pos.y = pos.y + dropper:get_properties().eye_height + 0.1
         local e = minetest.add_entity(pos, "alchemy:splash_entity", minetest.serialize({
            tex = texture,
            texpart = texpart,
            cLevel = cLevel,
            name = name,
            orig_vel = vel
         }))
         e:set_rotation({
            x = math.random() * 2 - 1,
            y = math.random() * 2 - 1,
            z = math.random() * 2 - 1,
         })
         e:set_velocity(vel)
         e:set_acceleration({x = 0, y = -20, z = 0})
         -- Remove item
         itemstack:take_item()
         return itemstack
      end
   })

   minetest.register_craft({
      output = bname,
      type = "shapeless",
      recipe = {
         "default:diamond", "alchemy:beaker_" .. name
      }
   })

end

alchemy.register_beaker = register_beaker
alchemy.register_splash_beaker = register_splash_beaker
