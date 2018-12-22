minetest.register_craftitem("xtraarmor:soap", {
	description = "Soap (For removing the color from dyed armor)",
	inventory_image = "xtraarmor_soap.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:soap 5",
	recipe = {"default:leaves", "dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:helmet_wool",
	recipe = {"group:wool_helmet", "xtraarmor:soap"},
})

minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:leggings_wool",
	recipe = {"group:wool_leggings", "xtraarmor:soap"},
})

minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:chestplate_wool",
	recipe = {"group:wool_chestplate", "xtraarmor:soap"},
})

minetest.register_craft({
	type = "shapeless",
	output = "xtraarmor:boots_wool",
	recipe = {"group:wool_boots", "xtraarmor:soap"},
})

-------------------------------------------------------

local colors = {
	["Green"] = "^[colorize:#00FF00:120",
	["Red"] = "^[colorize:#FF1900:120",
	["Yellow"] = "^[colorize:#FFF400:120",
	["White"] = "^[colorize:#FFFFFF:120",
	["Black"] = "^[colorize:#000000:120",
	["Grey"] = "^[colorize:#9E9E9E:120",
	["Orange"] = "^[colorize:#FFA400:120",
	["Dark Grey"] = "^[colorize:#5F5F5F:120",
	["Dark Green"] = "^[colorize:#297B27:120", 
	["Cyan"] = "^[colorize:#00FFE6:120",
	["Pink"] = "^[colorize:#FFA3E7:120",
	["Magenta"] = "^[colorize:#C31692:120",
	["Violet"] = "^[colorize:#7F00FF:120",
	["Brown"] = "^[colorize:#734021:120"
}

minetest.register_alias("xtraarmor:helmet_leather", "xtraarmor:helmet_wool")
minetest.register_alias("xtraarmor:chestplate_leather", "xtraarmor:chestplate_wool")
minetest.register_alias("xtraarmor:leggings_leather", "xtraarmor:leggings_wool")
minetest.register_alias("xtraarmor:boots_leather", "xtraarmor:boots_wool")

for colorname, color in pairs(colors) do
	local itemcolor = string.lower(colorname):gsub(' ', '_')

	minetest.register_tool("xtraarmor:helmet_wool_" .. itemcolor, {
		description = colorname .. " Cap",
		inventory_image = "xtraarmor_inv_helmet_wool.png" .. color,
		groups = {wool_helmet = 1, armor_head = 7,  armor_use = 1000},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:chestplate_wool_" .. itemcolor, {
		description = colorname .. " Tunic",
		inventory_image = "xtraarmor_inv_chestplate_wool.png" .. color,
		groups = {wool_chestplate = 1, armor_torso = 12,  armor_use = 1000},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:leggings_wool_"..itemcolor, {
		description = colorname .. " Trousers",
		inventory_image = "xtraarmor_inv_leggings_wool.png" .. color,
		groups = {wool_leggings = 1, armor_legs = 7,  armor_use = 150},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:boots_wool_"..itemcolor, {
		description = colorname .. " Boots",
		inventory_image = "xtraarmor_inv_boots_wool.png" .. color,
		groups = {wool_boots = 1, armor_feet = 7, physics_speed = 0.15, armor_use = 1000},
		wear = 0,
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:helmet_wool_" .. itemcolor,
		recipe = {"xtraarmor:helmet_wool", "dye:" .. itemcolor},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:chestplate_wool_" .. itemcolor,
		recipe = {"xtraarmor:chestplate_wool", "dye:" .. itemcolor},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:leggings_wool_" .. itemcolor,
		recipe = {"xtraarmor:leggings_wool", "dye:" .. itemcolor},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:boots_wool_" .. itemcolor,
		recipe = {"xtraarmor:boots_wool", "dye:" .. itemcolor},
	})

	minetest.register_alias("xtraarmor:helmet_leather_" .. itemcolor, "xtraarmor:helmet_wool_" .. itemcolor)
	minetest.register_alias("xtraarmor:chestplate_leather_" .. itemcolor, "xtraarmor:chestplate_wool_" .. itemcolor)
	minetest.register_alias("xtraarmor:leggings_leather_" .. itemcolor, "xtraarmor:chestplate_wool_" .. itemcolor)
	minetest.register_alias("xtraarmor:boots_leather_" .. itemcolor, "xtraarmor:boots_wool_" .. itemcolor)
end

minetest.register_tool("xtraarmor:helmet_wool", {
	description = "Wool Cap",
	inventory_image = "xtraarmor_inv_helmet_wool.png",
	groups = {armor_head = 5, armor_use = 1000},
	wear = 0,
})

minetest.register_tool("xtraarmor:chestplate_wool", {
	description = "Wool Tunic",
	inventory_image = "xtraarmor_inv_chestplate_wool.png",
	groups = {armor_torso = 10, armor_use = 1000},
	wear = 0,
})

minetest.register_tool("xtraarmor:leggings_wool", {
	description = "Wool Trousers",
	inventory_image = "xtraarmor_inv_leggings_wool.png",
	groups = {armor_legs = 5, armor_use = 150},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_wool", {
	description = "Wool Boots",
	inventory_image = "xtraarmor_inv_boots_wool.png",
	groups = {armor_feet = 5, physics_speed = 0.15, armor_use = 1000},
	wear = 0,
})

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

minetest.register_tool("xtraarmor:helmet_chainmail", {
	description = "chainmail Helmet",
	inventory_image = "xtraarmor_inv_helmet_chainmail.png",
	groups = {armor_head = 7, armor_heal = 0, armor_use = 750, physics_speed = -0.02},
	wear = 0,
})

minetest.register_tool("xtraarmor:chestplate_chainmail", {
	description = "chainmail Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_chainmail.png",
	groups = {armor_torso = 10, armor_heal = 0, armor_use = 750, physics_speed = -0.05},
	wear = 0,
})

minetest.register_tool("xtraarmor:leggings_chainmail", {
	description = "chainmail Leggings",
	inventory_image = "xtraarmor_inv_leggings_chainmail.png",
	groups = {armor_legs = 10, armor_heal = 0, armor_use = 750, physics_speed = -0.05},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_chainmail", {
	description = "chainmail Boots",
	inventory_image = "xtraarmor_inv_boots_chainmail.png",
	groups = {armor_feet = 7, armor_heal = 0, armor_use = 750, physics_speed = -0.02},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_chainmail", {
	description = "chainmail shield",
	inventory_image = "xtraarmor_inv_shield_chainmail.png",
	groups = {armor_shield = 7, armor_heal = 0, armor_use = 750},
	wear = 0,
})

minetest.register_craft({
	output = 'xtraarmor:helmet_chainmail',
	recipe = {
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
		{'xpanes:bar', '', 'xpanes:bar'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'xtraarmor:chestplate_chainmail',
	recipe = {
		{'xpanes:bar', '', 'xpanes:bar'},
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:leggings_chainmail',
	recipe = {
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
		{'xpanes:bar', '', 'xpanes:bar'},
		{'xpanes:bar', '', 'xpanes:bar'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:boots_chainmail',
	recipe = {
		{'', '', ''},
		{'xpanes:bar', '', 'xpanes:bar'},
		{'xpanes:bar', '', 'xpanes:bar'},
	}
})

minetest.register_craft({
	output = 'xtraarmor:shield_chainmail',
	recipe = {
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
		{'xpanes:bar', 'xpanes:bar', 'xpanes:bar'},
		{'', 'xpanes:bar', ''},
	}
})

minetest.register_tool("xtraarmor:helmet_studded", {
	description = "studded Helmet",
	inventory_image = "xtraarmor_inv_helmet_studded.png",
	groups = {armor_head = 8, armor_heal = 0, armor_use = 400, physics_speed = -0.03},
	wear = 0,
})

minetest.register_tool("xtraarmor:chestplate_studded", {
	description = "studded Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_studded.png",
	groups = {armor_torso = 14, armor_heal = 0, armor_use = 400, physics_speed = -0.06},
	wear = 0,
})

minetest.register_tool("xtraarmor:leggings_studded", {
	description = "studded Leggings",
	inventory_image = "xtraarmor_inv_leggings_studded.png",
	groups = {armor_legs = 14, armor_heal = 0, armor_use = 400, physics_speed = -0.06},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_studded", {
	description = "studded Boots",
	inventory_image = "xtraarmor_inv_boots_studded.png",
	groups = {armor_feet = 8, armor_heal = 0, armor_use = 400, physics_speed = -0.03},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_studded", {
	description = "studded shield",
	inventory_image = "xtraarmor_inv_shield_studded.png",
	groups = {armor_shield = 8, armor_heal = 0, armor_use = 400},
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
	output = 'xtraarmor:shield_studded',
	recipe = {
		{'group:wool', 'group:wool', 'group:wool'},
		{'group:wool', 'xtraarmor:shield_chainmail', 'group:wool'},
		{'', 'group:wool', ''},
	}
})
