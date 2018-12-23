local function register_herb(name, description, texture, from)
   local hname = "alchemy:herb_" .. name
   minetest.register_craftitem(hname, {
      description = description,
      inventory_image = texture,
      stack_max = 200,
      liquids_pointable = false
   })

   for f, chance in pairs(from) do
      -- Create table if empty
      if alchemy.herbs[f] == nil then
         alchemy.herbs[f] = {}
      end
      -- Add herb to table
      alchemy.herbs[f][hname] = chance
   end
end

-- Rarity values are a bit screwy here
register_herb("glycon", "Glycon Herb", "herb_glycon.png", {["default:leaves"] = 2})
register_herb("celros", "Celros Herb", "herb_celros.png", {["default:leaves"] = 20})
register_herb("firus", "Firus Herb", "herb_firus.png", {["default:leaves"] = 100})
register_herb("parleaf", "Parleaf Herb", "herb_parleaf.png", {["default:leaves"] = 400})

register_herb("shal_stalk", "Shal Stalk", "herb_shal_stalk.png", {["default:grass_1"] = 5})
register_herb("iceweed", "Iceweed Herb", "herb_iceweed.png", {["default:grass_1"] = 50})

register_herb("emen", "Emen Herb", "herb_emen.png", {["default:pine_needles"] = 40})
