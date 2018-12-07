minetest.register_on_newplayer(function(player)
	--print("on_newplayer")
	if minetest.settings.get_bool("give_initial_stuff") then
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
            player:get_inventory():add_item('main', 'default:pick_stone')
			player:get_inventory():add_item('main', 'xdecor:crafting_guide')
            player:get_inventory():add_item('main', 'default:torch')
            player:get_inventory():add_item('main', 'default:papyrus 8')
			player:get_inventory():add_item('main', 'wiki:wiki')
	end
end)
