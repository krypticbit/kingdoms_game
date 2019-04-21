-- Init
local storage = minetest.get_mod_storage()
local mp = minetest.get_modpath(minetest.get_current_modname())
kingdoms = {}

kingdoms.storage = storage

-- Load helpers
dofile(mp .. "/helpers.lua")

-- Config
kingdoms.marker_radius = 100
kingdoms.marker_capture_time = 300 -- Seconds
kingdoms.marker_capture_range = 5

-- Generated based on config
kingdoms.marker_radius_sq = kingdoms.marker_radius ^ 2

-- Define privs
kingdoms.kingdom_privs = {
   recruiter = true, -- Accept / kick members
   make_base = true, -- Place flag
   interact = true, -- Interact with team areas
   diplomat = true, -- Make / end wars
   rank_master = true, -- Make / remove ranks
   admin = true, -- Change team settings
}

-- Define default ranks
kingdoms.default_ranks = {
   king = kingdoms.helpers.copy_table(kingdoms.kingdom_privs),
   high_lord = {make_base = true, interact = true, recruiter = true, admin = true, diplomat = true},
   lord = {make_base = true, interact = true, recruiter = true},
   soldier = {make_base = true, interact = true}
}

-- Define colors
kingdoms.colors = {
   White = "#FFFFFF",
   Black = "#000000",
   Red = "#800000",
   Yellow = "#FFFF00",
   Green = "#008000",
   Blue = "#000080",
   Purple = "#800080",
   Orange = "#FF8C00",
   Brown = "#8B4513"
}

-- Load news
local nStr = storage:get_string("news")
if nStr == "" then
   kingdoms.news = {uid = 1, news = {}}
else
   kingdoms.news = minetest.deserialize(nStr)
end

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

-- Load markers
local mStr = storage:get_string("markers")
if mStr == "" then
   kingdoms.markers = {}
else
   kingdoms.markers = minetest.deserialize(mStr)
end

-- Load external files
dofile(mp .. "/news.lua")
dofile(mp .. "/kingdoms.lua")
dofile(mp .. "/gui.lua")
dofile(mp .. "/markers.lua")
dofile(mp .. "/chat.lua")
