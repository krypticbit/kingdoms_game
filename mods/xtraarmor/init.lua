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
	"Green", "Red",
	"Yellow", "White",
	"Black", "Grey",
	"Orange", "Dark Grey",
	"Dark Green", "Cyan",
	"Pink", "Magenta",
	"Violet", "Brown",
	"Blue"
}

minetest.register_alias("xtraarmor:helmet_leather", "xtraarmor:helmet_wool")
minetest.register_alias("xtraarmor:chestplate_leather", "xtraarmor:chestplate_wool")
minetest.register_alias("xtraarmor:leggings_leather", "xtraarmor:leggings_wool")
minetest.register_alias("xtraarmor:boots_leather", "xtraarmor:boots_wool")

for _, colorname in ipairs(colors) do
	local color = string.gsub(string.lower(colorname), ' ', '_')

	minetest.register_tool("xtraarmor:helmet_wool_" .. color, {
		description = colorname .. " Cap",
		inventory_image = "xtraarmor_inv_helmet_wool_" .. color .. ".png",
		groups = {wool_helmet = 1, armor_head = 7,  armor_use = 1000},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:chestplate_wool_" .. color, {
		description = colorname .. " Tunic",
		inventory_image = "xtraarmor_inv_chestplate_wool_" .. color .. ".png",
		groups = {wool_chestplate = 1, armor_torso = 12,  armor_use = 1000},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:leggings_wool_"..color, {
		description = colorname .. " Trousers",
		inventory_image = "xtraarmor_inv_leggings_wool_" .. color .. ".png",
		groups = {wool_leggings = 1, armor_legs = 7,  armor_use = 150},
		wear = 0,
	})

	minetest.register_tool("xtraarmor:boots_wool_"..color, {
		description = colorname .. " Boots",
		inventory_image = "xtraarmor_inv_boots_wool_" .. color .. ".png",
		groups = {wool_boots = 1, armor_feet = 7, physics_speed = 0.15, armor_use = 1000},
		wear = 0,
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:helmet_wool_" .. color,
		recipe = {"xtraarmor:helmet_wool", "dye:" .. color},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:chestplate_wool_" .. color,
		recipe = {"xtraarmor:chestplate_wool", "dye:" .. color},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:leggings_wool_" .. color,
		recipe = {"xtraarmor:leggings_wool", "dye:" .. color},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "xtraarmor:boots_wool_" .. color,
		recipe = {"xtraarmor:boots_wool", "dye:" .. color},
	})

	minetest.register_alias("xtraarmor:helmet_leather_" .. color, "xtraarmor:helmet_wool_" .. color)
	minetest.register_alias("xtraarmor:chestplate_leather_" .. color, "xtraarmor:chestplate_wool_" .. color)
	minetest.register_alias("xtraarmor:leggings_leather_" .. color, "xtraarmor:chestplate_wool_" .. color)
	minetest.register_alias("xtraarmor:boots_leather_" .. color, "xtraarmor:boots_wool_" .. color)
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
	description = "Chainmail Helmet",
	inventory_image = "xtraarmor_inv_helmet_chainmail.png",
	groups = {armor_head = 7, armor_heal = 0, armor_use = 750, physics_speed = -0.02},
	wear = 0,
})

minetest.register_tool("xtraarmor:chestplate_chainmail", {
	description = "Chainmail Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_chainmail.png",
	groups = {armor_torso = 10, armor_heal = 0, armor_use = 750, physics_speed = -0.05},
	wear = 0,
})

minetest.register_tool("xtraarmor:leggings_chainmail", {
	description = "Chainmail Leggings",
	inventory_image = "xtraarmor_inv_leggings_chainmail.png",
	groups = {armor_legs = 10, armor_heal = 0, armor_use = 750, physics_speed = -0.05},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_chainmail", {
	description = "Chainmail Boots",
	inventory_image = "xtraarmor_inv_boots_chainmail.png",
	groups = {armor_feet = 7, armor_heal = 0, armor_use = 750, physics_speed = -0.02},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_chainmail", {
	description = "Chainmail Shield",
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
	description = "Studded Helmet",
	inventory_image = "xtraarmor_inv_helmet_studded.png",
	groups = {armor_head = 8, armor_heal = 0, armor_use = 400, physics_speed = -0.03},
	wear = 0,
})

minetest.register_tool("xtraarmor:chestplate_studded", {
	description = "Studded Chestplate",
	inventory_image = "xtraarmor_inv_chestplate_studded.png",
	groups = {armor_torso = 14, armor_heal = 0, armor_use = 400, physics_speed = -0.06},
	wear = 0,
})

minetest.register_tool("xtraarmor:leggings_studded", {
	description = "Studded Leggings",
	inventory_image = "xtraarmor_inv_leggings_studded.png",
	groups = {armor_legs = 14, armor_heal = 0, armor_use = 400, physics_speed = -0.06},
	wear = 0,
})

minetest.register_tool("xtraarmor:boots_studded", {
	description = "Studded Boots",
	inventory_image = "xtraarmor_inv_boots_studded.png",
	groups = {armor_feet = 8, armor_heal = 0, armor_use = 400, physics_speed = -0.03},
	wear = 0,
})

minetest.register_tool("xtraarmor:shield_studded", {
	description = "Studded Shield",
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
