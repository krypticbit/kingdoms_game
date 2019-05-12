-- Chainmail
minetest.register_tool("xtraarmor:helmet_chainmail", {
	description = "chainmail Helmet",
	inventory_image = "xtraarmor_inv_helmet_chainmail.png",
	groups = {armor_head=8, armor_heal=0, armor_use=750},
	wear = 0,
})
minetest.register_tool("xtraarmor:chestplate_chainmail", {
	description = "chainmail Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_chainmail.png",
	groups = {armor_torso=13, armor_heal=0, armor_use=750},
	wear = 0,
})
minetest.register_tool("xtraarmor:leggings_chainmail", {
	description = "chainmail Leggings",
	inventory_image = "xtraarmor_inv_leggings_chainmail.png",
	groups = {armor_legs=13, armor_heal=0, armor_use=750},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_chainmail", {
	description = "chainmail Boots",
inventory_image = "xtraarmor_inv_boots_chainmail.png",
	groups = {armor_feet=8, armor_heal=0, armor_use=750},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_chainmail", {
	description = "chainmail shield",
	inventory_image = "xtraarmor_inv_shield_chainmail.png",
	groups = {armor_shield=8, armor_heal=0, armor_use=750},
	wear = 0,
})

minetest.register_craft({
	output = 'xtraarmor:helmet_chainmail',
	recipe = {
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'xtraarmor:chestplate_chainmail',
	recipe = {
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:leggings_chainmail',
	recipe = {
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:boots_chainmail',
	recipe = {
		{'', '', ''},
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', '', 'xpanes:bar_flat'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:shield_chainmail',
	recipe = {
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
		{'xpanes:bar_flat', 'xpanes:bar_flat', 'xpanes:bar_flat'},
		{'', 'xpanes:bar_flat', ''},
	}
})

-- Normal (grey) wool armor
minetest.register_alias("xtraarmor:helmet_wool", "xtraarmor:helmet_wool_grey")
minetest.register_alias("xtraarmor:chestplate_wool", "xtraarmor:chestplate_wool_grey")
minetest.register_alias("xtraarmor:leggings_wool", "xtraarmor:leggings_wool_grey")
minetest.register_alias("xtraarmor:boots_wool", "xtraarmor:helmet_boots_grey")

minetest.register_craft({
	output = 'xtraarmor:helmet_wool',
	recipe = {
		{'group:wool', 'group:wool', 'group:wool'},
		{'group:wool', '', 'group:wool'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'xtraarmor:chestplate_wool',
	recipe = {
		{'group:wool', '', 'group:wool'},
		{'group:wool', 'group:wool', 'group:wool'},
		{'group:wool', 'group:wool', 'group:wool'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:leggings_wool',
	recipe = {
		{'group:wool', 'group:wool', 'group:wool'},
		{'group:wool', '', 'group:wool'},
		{'group:wool', '', 'group:wool'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:boots_wool',
	recipe = {
		{'', '', ''},
		{'group:wool', '', 'group:wool'},
		{'group:wool', '', 'group:wool'},
	}
})


-- Studded armor
minetest.register_tool("xtraarmor:helmet_studded", {
   description = "studded Helmet",
	inventory_image = "xtraarmor_inv_helmet_studded.png",
	groups = {armor_head=12.4, armor_heal=2, armor_use=400},
	wear = 0,
})
minetest.register_tool("xtraarmor:chestplate_studded", {
	description = "studded Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_studded.png",
	groups = {armor_torso=16.4, armor_heal=2, armor_use=400},
	wear = 0,
})
minetest.register_tool("xtraarmor:leggings_studded", {
	description = "studded Leggings",
	inventory_image = "xtraarmor_inv_leggings_studded.png",
	groups = {armor_legs=16.4, armor_heal=2, armor_use=400},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_studded", {
	description = "studded Boots",
	inventory_image = "xtraarmor_inv_boots_studded.png",
	groups = {armor_feet=12.4, armor_heal=2, armor_use=400},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_studded", {
	description = "studded shield",
	inventory_image = "xtraarmor_inv_shield_studded.png",
	groups = {armor_shield=12.4, armor_heal=2, armor_use=400},
	wear = 0,
})


minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:helmet_studded",
	recipe = {"xtraarmor:helmet_chainmail", "xtraarmor:helmet_wool"},
})
minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:chestplate_studded",
	recipe = {"xtraarmor:chestplate_chainmail", "xtraarmor:chestplate_wool"},
})
minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:leggings_studded",
	recipe = {"xtraarmor:leggings_chainmail", "xtraarmor:leggings_wool"},
})
minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:boots_studded",
	recipe = {"xtraarmor:boots_chainmail", "xtraarmor:boots_wool"},
})
minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:shield_studded",
	recipe = {"xtraarmor:shield_chainmail", "xtraarmor:shield_wool"},
})

-- Colored wool armor
local colors = {
	{"white",      "White"},
	{"grey",       "Grey"},
	{"black",      "Black"},
	{"red",        "Red"},
	{"yellow",     "Yellow"},
	{"green",      "Green"},
	{"cyan",       "Cyan"},
	{"blue",       "Blue"},
	{"magenta",    "Magenta"},
	{"orange",     "Orange"},
	{"violet",     "Violet"},
	{"brown",      "Brown"},
	{"pink",       "Pink"},
	{"dark_grey",  "Dark Grey"},
	{"dark_green", "Dark Green"},
}

for cNum = 1, #colors do
   local cName, cDesc = unpack(colors[cNum])
   -- Armor
   minetest.register_tool("xtraarmor:helmet_wool_" .. cName, {
      description = cDesc .. " wool cap",
      inventory_image = "xtraarmor_inv_helmet_wool_" .. cName .. ".png",
      groups = {wool_helmet=1, armor_head=7, armor_heal=2, armor_use=1000},
      wear = 0,
   })
   minetest.register_tool("xtraarmor:chestplate_wool_" .. cName, {
      description = cDesc .. " wool tunic",
      inventory_image = "xtraarmor_inv_chestplate_wool_" .. cName .. ".png",
      groups = {wool_chestplate=1, armor_torso=12, armor_heal=2, armor_use=1000},
      wear = 0,
   })
   minetest.register_tool("xtraarmor:leggings_wool_" .. cName, {
      description = cDesc .. " wool trousers",
      inventory_image = "xtraarmor_inv_leggings_wool_" .. cName .. ".png",
      groups = {wool_leggings=1, armor_legs=7, armor_heal=2, armor_use=150},
      wear = 0,
   })
   minetest.register_tool("xtraarmor:boots_wool_" .. cName, {
      description = cDesc .. " wool boots",
      inventory_image = "xtraarmor_inv_boots_wool_" .. cName .. ".png",
      groups = {wool_boots=1, armor_feet=7, armor_heal=2,physics_speed=0.15, armor_use=1000},
      wear = 0,
   })
   -- Crafts
   minetest.register_craft({
      type = "shapeless",
      output = "xtraarmor:helmet_wool_" .. cName,
      recipe = {"group:wool_helmet", "dye:" .. cName},
   })
   minetest.register_craft({
      type = "shapeless",
      output = "xtraarmor:chestplate_wool_" .. cName,
      recipe = {"group:wool_chestplate", "dye:" .. cName},
   })
   minetest.register_craft({
      type = "shapeless",
      output = "xtraarmor:leggings_wool_" .. cName,
      recipe = {"group:wool_leggings", "dye:" .. cName},
   })
   minetest.register_craft({
      type = "shapeless",
      output = "xtraarmor:boots_wool_" .. cName,
      recipe = {"group:wool_boots", "dye:" .. cName},
   })
end
