--[[
	Ingots - allows the placemant of ingots in the world
	Copyright (C) 2018  Skamiz Kazzarch

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
	
	Modified by BillyS on Jan 2 2019
	Changes:
		- Added protection checking
]]--

ingots = {}

local conf = dofile(minetest.get_modpath("ingots").."/conf.lua")

-- takes an item name and a texture name and a boolean whether the ingots are big
function ingots.register_ingots(ingot_item, texture, is_big)
	
	--checks, whether the item name is a valid item (thanks 'puzzlecube')
	if not minetest.registered_items[ingot_item] then
		minetest.log("warning", ingot_item.." is not registered. Skipping ingot registration")
		return
	end
	
	local stack_size = 64
	local texture_prefix = "ingot_"
	--gets item name witout mod part, to be used in the deffinition of the new nodes
	local ingot_name = string.sub(ingot_item, string.find(ingot_item, ":", 1, true) +1, -1)
	
	if is_big then
		ingot_name = ingot_name .. "_big"
		stack_size = 8
		texture_prefix = "ingot_big_"
	end
	
	--this way there is no need for a separate on_punch function for a stack of 1 ingot
	minetest.register_alias("ingots:".. ingot_name .."_0", "air")
	
	--gives the ingot_item the ability to be placed and increase already placed stacks of ingots
	minetest.override_item(ingot_item, {
		on_place = function (itemstack, placer, pointed_thing)
			local pName = placer:get_player_name()
			if pointed_thing["type"] == "node" then
				local name = minetest.get_node(pointed_thing.under).name
				if string.find(name, "ingots:".. ingot_name) then
					local count = string.gsub(name, "%D*", "")
					if stack_size > tonumber(count) then
						if minetest.is_protected(pointed_thing.under, pName) then
							minetest.record_protection_violation(pointed_thing.under, pName)
							return
						end
						minetest.set_node(pointed_thing.under, {name = "ingots:".. ingot_name .."_" .. count + 1, param2 = minetest.get_node(pointed_thing.under).param2})
						if not (creative and creative.is_enabled_for and creative.is_enabled_for(placer:get_player_name())) then
							itemstack:take_item()
						end
					elseif minetest.get_node(pointed_thing.above).name == "air" then
						if minetest.is_protected(pointed_thing.above, pName) then
							minetest.record_protection_violation(pointed_thing.above, pName)
							return
						end
						minetest.set_node(pointed_thing.above, {name = "ingots:".. ingot_name .."_1"})
						if not (creative and creative.is_enabled_for and creative.is_enabled_for(placer:get_player_name())) then
							itemstack:take_item()
						end
					end
					
				elseif minetest.get_node(pointed_thing.above).name == "air" then
					if minetest.is_protected(pointed_thing.above, pName) then
						minetest.record_protection_violation(pointed_thing.above, pName)
						return
					end
					minetest.set_node(pointed_thing.above, {name = "ingots:".. ingot_name .."_1"})
					if not (creative and creative.is_enabled_for and creative.is_enabled_for(placer:get_player_name())) then
						itemstack:take_item()
					end
				end

				return itemstack
			end
		end
	})
	
	--registers 'stack_size' number of nodes, each has one more ingot in it than the last
	for i = 1, stack_size do 
		local box = {
					type = "fixed",
					fixed = {
						--rectangular box which encompases all placed ingots
						ingots.get_box(is_big, i),
					},
				}
		minetest.register_node("ingots:".. ingot_name .. "_" .. i,{
			description = "ingots",
			drawtype = "mesh",
			tiles = {texture},
			mesh = texture_prefix .. i .. ".obj",
			selection_box = box,
			collision_box = box,
			paramtype = 'light',
			paramtype2 = "facedir",
			groups = {cracky = 3, level = 2, not_in_creative_inventory = 1},
			drop = ingot_item .. " " .. i,
			on_punch = function (pos, node, puncher, pointed_thing)
				if puncher then
					local wield = puncher:get_wielded_item()
					--checks, so that a stack can be taken appart only by hand or relevant ingot_item
					if wield:get_name() == ingot_item or
						wield:get_count() == 0 then
						minetest.set_node(pos, {name = "ingots:".. ingot_name .."_" .. i - 1, param2 = node.param2})
						if not (creative and creative.is_enabled_for and creative.is_enabled_for(puncher:get_player_name())) then
							local stack = ItemStack(ingot_item)
							puncher:get_inventory():add_item("main", stack)
						end
					end
				end
			end
		})
	end
end

function ingots.get_box(is_big, i)
	if is_big then return {-0.5, -0.5, -0.5, 0.5, (((i + 1 - ((i +1 )%2)) / 8) - 0.5), 0.5}
	else return {-0.5, -0.5, -0.5, 0.5, (((i - 1 - ((i-1)%8)) / 8) - 3) / 8, 0.5}
	end
end

if minetest.get_modpath("default") then
		ingots.register_ingots("default:copper_ingot", "ingot_copper.png", conf.is_big)
		ingots.register_ingots("default:tin_ingot", "ingot_tin.png", conf.is_big)
		ingots.register_ingots("default:bronze_ingot", "ingot_bronze.png", conf.is_big)
		ingots.register_ingots("default:steel_ingot", "ingot_steel.png", conf.is_big)
		ingots.register_ingots("default:gold_ingot", "ingot_gold.png", conf.is_big)
end

if minetest.get_modpath("moreores") then
		ingots.register_ingots("moreores:silver_ingot", "ingot_silver.png", conf.is_big)
		ingots.register_ingots("moreores:mithril_ingot", "ingot_mithril.png", conf.is_big)
		if not minetest.registered_items["default:tin_ingot"] then
			ingots.register_ingots("moreores:tin_ingot", "ingot_tin.png", conf.is_big)
		end
end

if minetest.get_modpath("technic") then
		ingots.register_ingots("technic:stainless_steel_ingot", "ingot_stainless_steel.png", conf.is_big)
		ingots.register_ingots("technic:mixed_metal_ingot", "ingot_mixed_metal.png", conf.is_big)
end 
