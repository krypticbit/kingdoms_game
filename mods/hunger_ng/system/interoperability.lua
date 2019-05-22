-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Minetest
local get_modpath = minetest.get_modpath


-- Load needed data
local path = minetest.get_modpath('hunger_ng')
local inter_path = path..DIR_DELIM..'interoperability'..DIR_DELIM
local config = Settings(path..DIR_DELIM..'mod.conf')
local depends = config:get('depends')..', '..config:get('optional_depends')


-- Check if interoperability file exists and load it
for modname in depends:gmatch('[0-9a-z_-]+') do
    if get_modpath(modname) then
        local inter_file = inter_path..modname..'.lua'

        if file_exists(inter_file) then
            dofile(inter_file)
            local message = 'Loaded built-in '..modname..' support'
            minetest.log('action', c.log_prefix..message)
        end
    end
end
