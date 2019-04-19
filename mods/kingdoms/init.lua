-- Init
local storage = minetest.get_mod_storage()
local mp = minetest.get_modpath(minetest.get_current_modname())
kingdoms = {}

kingdoms.storage = storage

-- Load helpers
dofile(mp .. "/helpers.lua")

-- Define privs
kingdoms.kingdom_privs = {
   recruiter = true, -- Accept / kick members
   make_base = true, -- Place flag
   interact = true, -- Interact with team areas
   diplomat = true, -- Make / end wars
   rank_master = true, -- Make / remove ranks
}

-- Define default ranks
kingdoms.default_ranks = {
   king = kingdoms.helpers.copy_table(kingdoms.kingdom_privs),
   lord = {make_base = true, interact = true, recruiter = true},
   soldier = {make_base = true, interact = true}
}

-- Load players
local pStr = storage:get_string("members")
if pStr == "" then
   kingdoms.members = {}
else
   kingdoms.members = minetest.deserialize(pStr)
end

-- Load kingdoms
local kStr = storage:get_string("kingdoms")
if kStr == "" then
   kingdoms.kingdoms = {}
else
   kingdoms.kingdoms = minetest.deserialize(kStr)
end

-- Load pending join requests
local pendingStr = storage:get_string("pending_requests")
if pendingStr == "" then
   kingdoms.pending = {}
else
   kingdoms.pending = minetest.deserialize(pendingStr)
end

-- Load external files
dofile(mp .. "/kingdoms.lua")
dofile(mp .. "/chat.lua")
