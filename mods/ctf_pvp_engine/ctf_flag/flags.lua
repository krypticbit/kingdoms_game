local r = ctf.setting("flag.nobuild_radius")
local c_air = minetest.get_content_id("air")

local function elementsInTable(t)
   local n = 0
   for _ in pairs(t) do n = n + 1 end
   return n
end

local function recalc_team_maxpower(team)
   team.power.max_power = ctf.get_team_maxpower(team)
end

local function can_place_flag(pos)
	local lpos = pos
	local pos1 = {x=lpos.x-r+1,y=lpos.y,z=lpos.z-r+1}
	local pos2 = {x=lpos.x+r-1,y=lpos.y+r-1,z=lpos.z+r-1}

	local vm = minetest.get_voxel_manip()

	local emin, emax = vm:read_from_map(pos1, pos2)
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}

	local nx = lpos.x
	local ny = lpos.y
	local nz = lpos.z

	local n1x = pos1.x
	local n1y = pos1.y
	local n1z = pos1.z

	local n2x = pos2.x
	local n2y = pos2.y
	local n2z = pos2.z

	local data = vm:get_data()

	local m_vi = a:index(nx, ny, nz)
	local myname = minetest.get_name_from_content_id(data[m_vi])

	for z = n1z, n2z do
		for y = n1y, n2y do
			for x = n1x, n2x do
				if x ~= nx or y ~= ny or z ~= nz then
					local vi = a:index(x, y, z)
					local id = data[vi]
					if id ~= c_air then
						return false
					end
				end
			end
		end
    end
	return true
end

-- The flag
function register_flag(def)
	minetest.register_node(def.name, {
		description = def.description,
		drawtype = "nodebox",
		paramtype = "light",
		walkable = false,
		inventory_image = def.image,
		wield_image = def.image,
		tiles = {
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
			}
		},
		depth_max = def.depth_max,
		groups = {immortal=1,is_flag=1,flag_bottom=1},
		on_punch = ctf_flag.on_punch,
		on_rightclick = ctf_flag.on_rightclick,
		on_construct = ctf_flag.on_construct,
		on_place = function(itemstack, placer, pointed_thing)
			if not placer then
				return itemstack
			end

			local name = placer:get_player_name()
			local node = minetest.get_node(pointed_thing.under)
			local nodedef = minetest.registered_nodes[node.name]

			if nodedef and nodedef.on_rightclick and
					not placer:get_player_control().sneak then
				return nodedef.on_rightclick(pointed_thing.under,
						node, placer, itemstack, pointed_thing)
			end

			local pos
			if nodedef and nodedef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				nodedef = minetest.registered_nodes[node.name]
				if not nodedef or not nodedef.buildable_to then
					return itemstack
				end
			end

			local meta = minetest.get_meta(pos)
			if not meta then
				return itemstack
			end

			local depth_max = def.depth_max
			
			if pos.y < depth_max then
				minetest.chat_send_player(name, "The max depth for this type of flag is " .. depth_max .. " blocks.")
				return itemstack
			end

			if not can_place_flag(pos) then
				minetest.chat_send_player(name, "Too close to the flag to build!"
							.. " Leave at least " .. r .. " blocks around the flag.")
				return itemstack
			end
			
			local team, index = ctf.get_territory_owner(pos)
			if team ~= nil then
				minetest.chat_send_player(name, "You cannot place a flag in a protected area!")
				return itemstack
			end

			local tplayer = ctf.player_or_nil(name)
			if tplayer and ctf.team(tplayer.team) then
				if ctf.player(name).auth == false then
					minetest.chat_send_player(name, "You're not allowed to place flags!")
					return itemstack
				end

				local tname = tplayer.team
				local team = ctf.team(tplayer.team)

				if elementsInTable(team.players) <= elementsInTable(team.flags) then
					minetest.chat_send_player(name, "You need more members to be able to place more flags.")
					return itemstack
				end

				meta:set_string("infotext", tname .. "'s flag")

				-- add flag
				ctf_flag.add(tname, pos)

				-- TODO: fix this hackiness
				if team.spawn and not ctf.setting("flag.allow_multiple") and
						minetest.get_node(team.spawn).name == "ctf_flag:flag" then
					-- send message
					minetest.chat_send_all(tname .. "'s flag has been moved")
					minetest.set_node(team.spawn, {name="air"})
					minetest.set_node({
						x = team.spawn.x,
						y = team.spawn.y + 1,
						z = team.spawn.z
					}, {name = "air"})
					team.spawn = pos
				end

				ctf.needs_save = true

				local pos2 = {
					x = pos.x,
					y = pos.y + 1,
					z = pos.z
				}

				if not team.data.color then
					team.data.color = "red"
					ctf.needs_save = true
				end

			 -- Recalc team max power
			 recalc_team_maxpower(team)

				minetest.set_node(pos, {name = "ctf_flag:flag"})
				minetest.set_node(pos2, {name = "ctf_flag:flag_top_" .. team.data.color})

				local meta = minetest.get_meta(pos)
				meta:set_string("node_name", def.name)
				
				local meta2 = minetest.get_meta(pos2)
				meta2:set_string("infotext", tname.."'s flag")

				itemstack:take_item()
				return itemstack
			else
				minetest.chat_send_player(name, "You are not part of a team!")
				return itemstack
			end
		end,
		on_timer = ctf_flag.flag_tick,
	})
end

register_flag({name = "ctf_flag:flag", description = "Flag - 1", depth_max = -10, image = "flag_graphic1.png"})
register_flag({name = "ctf_flag:flag1", description = "Flag - 2", depth_max = -40, image = "flag_graphic2.png"})

minetest.register_craft({
	output = "ctf_flag:flag",
	recipe = {
		{"default:diamondblock", "group:wool"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})

minetest.register_craft({
	output = "ctf_flag:flag1",
	recipe = {
		{"default:diamondblock", "default:goldblock 2", "group:wool"},
		{"default:stick", "default:mese 2", ""},
		{"default:stick", "", ""}
	}
})

for color, _ in pairs(ctf.flag_colors) do
	minetest.register_node("ctf_flag:flag_top_"..color,{
		description = "You are not meant to have this! - flag top",
		drawtype="nodebox",
		paramtype = "light",
		walkable = true,
		tiles = {
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"flag_"..color.."2.png",
			"flag_"..color..".png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500},
				{-0.5,0,0.000000,0.250000,0.500000,0.062500}
			}
		},
		groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
		on_punch = ctf_flag.on_punch_top,
		on_rightclick = ctf_flag.on_rightclick_top
	})
end

minetest.register_node("ctf_flag:flag_captured_top",{
	description = "You are not meant to have this! - flag captured",
	drawtype = "nodebox",
	paramtype = "light",
	walkable = true,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
		}
	},
	groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
	on_punch = ctf_flag.on_punch_top,
	on_rightclick = ctf_flag.on_rightclick_top
})

--[[
minetest.register_abm({
	nodenames = {"group:flag_bottom"},
	inteval = 5,
	chance = 1,
	action = ctf_flag.update
})
--]]
