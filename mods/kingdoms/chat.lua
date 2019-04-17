-- Register "overlord" (kingdom-creater/modifier) priv
minetest.register_privilege("overlord", {
   description = "Can create / modifiy kingdoms",
   give_to_singleplayer = false
})

-- Admin kingdom commands
ChatCmdBuilder.new("kingdoms_admin", function(cmd)
   -- Add new kingdom
   cmd:sub("add :name:word", function(name, kingdom_name)
      return kingdoms.add_kingdom(kingdom_name, name)
   end)
   -- Add new kingdom with specified owner
   cmd:sub("add :name:word :king:word", function(name, kingdom_name, king)
      return kingdoms.add_kingdom(kingdom_name, king)
   end)
   -- Remove kingdom
   cmd:sub("remove :name:word", function(name, kingdom_name)
      return kingdoms.remove_kingdom(kingdom_name)
   end)
   -- Add player to kingdom
   cmd:sub("join :victim:word :kingdom:word", function(name, victim, kingdom)
      return kingdoms.add_player_to_kingdom(kingdom, victim)
   end)
   -- Remove player from kingdom
   cmd:sub("remove :victim:word :kingdom:word", function(name, victim, kingdom)
      return kingdoms.remove_player_from_kingdom(kingdom, victim)
   end)
   -- Set player rank in kingdom
   cmd:sub("set_rank :victim:word :rank:word", function(name, victim, rank)
      return kingdoms.set_player_rank(victim, rank)
   end)
   -- Add rank to kingdom
   cmd:sub("add_rank :kingdom:word :rank:word", function(name, kingdom, rank)
      return kingdoms.add_rank(kingdom, rank)
   end)
   -- Add rank to kingdom with specified privs
   cmd:sub("add_rank :kingdom:word :rank:word :privs:text", function(name, kingdom, rank, privs)
      return kingdoms.add_rank(kingdom, rank, kingdoms.helpers.split_into_keys(privs))
   end)
end, {
   description = "Manage kingdoms (See '/kingdoms_admin help' for more information)",
   privs = {overlord = true}
})

-- Player kingdoms comannds
ChatCmdBuilder.new("kingdoms", function(cmd)
   -- List kingdoms
   cmd:sub("list", function(name)
      return true, kingdoms.list_kingdoms()
   end)
end)
