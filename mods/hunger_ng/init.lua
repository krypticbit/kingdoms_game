-- Exit if damage is not enabled.
if not minetest.is_yes(minetest.settings:get('enable_damage')) then
    minetest.log('info', 'Hunger NG is disabled because damage is disabled.')
    return
end


-- Mod path for later use
local modpath = minetest.get_modpath('hunger_ng')..DIR_DELIM


-- Wrapper for getting configuration options
--
-- Will be automatically prefixed and returns either the setting value or if
-- not present the provided default value.
local get = function (setting, default)
    return minetest.settings:get('hunger_ng_'..setting) or default
end


-- Global hunger_ng table that will be used to pass around variables and use
-- them later in the game.
hunger_ng = {
    functions = {},
    attributes = {
        hunger_bar_id = 'hunger_ng:hunger_bar_id',
        hunger_value = 'hunger_ng:hunger_value',
        eating_timestamp = 'hunger_ng:eating_timestamp',
        hunger_disabled = 'hunger_ng:hunger_disabled'
    },
    configuration = {
        debug_mode = minetest.is_yes(get('debug_mode', false)),
        log_prefix = '[hunger_ng] ',
        translator = minetest.get_translator('hunger_ng')
    },
    settings = {
        hunger_bar = {
            image = get('hunger_bar_image', 'farming_bread.png'),
            use = minetest.is_yes(get('use_hunger_bar', true))
        },
        timers = {
            heal = tonumber(get('timer_heal', 5)),
            starve = tonumber(get('timer_starve', 10)),
            basal_metabolism = tonumber(get('timer_base', 60)),
            movement = tonumber(get('timer_movement', 0.5))
        },
        hunger = {
            timeout = tonumber(get('hunger_timeout', 0)),
            persistent = minetest.is_yes(get('hunger_persistent', true)),
            start_with = tonumber(get('hunger_start_with', 20)),
            maximum = tonumber(get('hunger_maximum', 20))
        }
    },
    effects = {
        heal = {
            above = tonumber(get('heal_above', 16)),
            amount = tonumber(get('heal_amount', 1))
        },
        starve = {
            below = tonumber(get('starve_below', 1)),
            amount = tonumber(get('starve_amount', 1)),
            die = minetest.is_yes(get('starve_die', false))
        },
        disabled_attribute = 'hunger_ng:hunger_disabled'
    },
    costs = {
        base = tonumber(get('cost_base', 0.1)),
        dig = tonumber(get('cost_dig', 0.005)),
        place = tonumber(get('cost_place', 0.01)),
        movement = tonumber(get('cost_walk', 0.008))
    }
}


-- Load mod parts
dofile(modpath..'system'..DIR_DELIM..'hunger_functions.lua')
dofile(modpath..'system'..DIR_DELIM..'chat_commands.lua')
dofile(modpath..'system'..DIR_DELIM..'timers.lua')
dofile(modpath..'system'..DIR_DELIM..'register_on.lua')
dofile(modpath..'system'..DIR_DELIM..'add_hunger_data.lua')
dofile(modpath..'system'..DIR_DELIM..'interoperability.lua')


-- Log debug mode warning
if hunger_ng.configuration.debug_mode then
    local log_prefix = hunger_ng.configuration.log_prefix
    minetest.log('warning', log_prefix..'Mod loaded with debug mode enabled!')
end


-- Replace the global table used for easy variable access within the mod with
-- an API-like global table for other mods to utilize.
local add_hunger_data = hunger_ng.functions.add_hunger_data
local alter_hunger = hunger_ng.functions.alter_hunger
local get_hunger_information = hunger_ng.functions.get_hunger_information
local configure_hunger = hunger_ng.functions.configure_hunger
hunger_ng = nil
hunger_ng = {
    add_hunger_data = add_hunger_data,
    alter_hunger = alter_hunger,
    configure_hunger = configure_hunger,
    get_hunger_information = get_hunger_information
}
