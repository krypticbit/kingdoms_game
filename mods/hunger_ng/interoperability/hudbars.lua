-- Localize and Prepare
local a = hunger_ng.attributes
local f = hunger_ng.functions
local s = hunger_ng.settings
local bar_id = 'hungernghudbar'
local hudbar_image_filters = '^[noalpha^[colorize:#c17d11ff^[resize:2x16'
local hudbar_image = s.hunger_bar.image..hudbar_image_filters


-- register the hud bar
hb.register_hudbar(
    bar_id,
    '0xFFFFFF',
    'Hunger',
    {
        bar = hudbar_image,
        icon = s.hunger_bar.image
    },
    s.hunger.maximum,
    s.hunger.maximum,
    false
)


-- Remove normal hunger bar and add hudbar version of it
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    local hud_id = tonumber(f.get_data(player_name, a.hunger_bar_id))
    local current_hunger = f.get_data(player_name, a.hunger_value)
    local hunger_ceiled = math.ceil(current_hunger)

    if s.hunger_bar.use then
        -- Since we don’t have register_after_joinplayer() we need to delay
        -- the removal of the default hunger bar because without delay this
        -- results in a race condition with Hunger NG’s register_on_joinplayer
        -- callback that defines and sets the default hunger bar.
        minetest.after(0.5, function () player:hud_remove(hud_id) end)
    end

    hb.init_hudbar(player, bar_id, hunger_ceiled, s.hunger.maximum, false)
end)


-- Globalstep for updating the hundbar version of the hunger bar without
-- any additional code outside the interoperability system.
local hudbars_timer = 0
minetest.register_globalstep(function(dtime)
    hudbars_timer = hudbars_timer + dtime
    if hudbars_timer >= 1 then
        hudbars_timer = 0
        for _,player in ipairs(minetest.get_connected_players()) do
            if player ~= nil then
                local playername = player:get_player_name()
                local hunger = f.get_data(playername, a.hunger_value)
                local ceiled = math.ceil(hunger)
                hb.change_hudbar(player, bar_id, ceiled, s.hunger.maximum)
            end
        end
    end
end)
