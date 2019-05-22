# API Usage

Hunger NG provides an API so other mods can have interoperability functionality. The API is represented by the global table `hunger_ng`. To reliably use the API, modders need to depend or opt-depend their mod to Hunger NG (`hunger_ng`).

## Adding hunger data

Modders can easily add satiation and health information to their custom food by running the function `add_hunger_data` from the global `hunger_ng` table after they registered their food.

    hunger_ng.add_hunger_data('modname:itemname', {
        satiates = 2.5,
        heals = 0,
        returns = 'mymod:myitem',
        timeout = 4
    })

Floats are allowed for `satiates` only. Health points and the timeout are always integers. Using food to satiate only is preferred. The item defined in `returnes` will be returned when the food is eaten. If there is no space in the inventory the food can’t be eaten.

Values not to be set can be omitted in the table.

### On the timeout attribute …

Foods can have a timeout set. When set it prevents the food (and all other foods that have a similar or higher timeout or a timeout that’s within the current timeout time) to be eaten again while the timeout is active. The timeout also takes place when trying to eat the food after another food.

Foods without timeout can be eaten at any time if no default timeout is set. See the configuration readme for more details on setting a default timeout. To make sure the food can be eaten regardless of the default timeout set `timeout = 0` in the definition. Otherwise the default timeout is applied.

All foods reset the timeout period. Example: When eating food with timeout `10` right after eating something (food item and set timeout for that item do not matter) you need to wait 10 seconds. When eating an item with timeout `0` after 9 seconds it works but now you need to wait 10 more seconds to eat the other item with timeout `10`.

## Changing hunger

It is possible for modders to change hunger in their mods without having to care about the correct attributes. In the global table there is a function for that.

    hunger_ng.alter_hunger('Foobar', -5, 'optional reason')

This removes 5 hunger points from Foobar’s hunger value with the reason “optional reason”. Since the reason is optional it can be omitted. If given it should be as short as possible. If it is longer than 3 words reconsider it.

The function can be used in a globalstep that loops over all players, too.

```Lua
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then
        timer = 0
        for _,player in ipairs(minetest.get_connected_players()) do
            if player ~= nil then
                hunger_ng.alter_hunger(player:get_player_name(), 1, 'because I can')
            end
        end
    end
end)
```

This globalstep iterates over all players and gives them 1 hunger point every second with the reason “because I can”. The reason is shown in the log files if Hunger NG’s debug mode is enabled (you should not do that, it spams your logs with A LOT of lines).

Be careful with globalsteps because they can cause server lag.

### Enable/Disable hunger

An API function for enabling or disabling hunger on a per-player basis is available. The function can be used by other mods to disable and re-enable the hunger functionality.

    hunger_ng.configure_hunger('Foobar', 'disable')

The example disables all hunger functionality for the player “Foobar”. When passing `enable` to the function the hunger gets enabled.

While disabled the normal eating functionality is restored (eating directly heals the player) and the default hunger bar is removed.

## Getting hunger information

If modders want to get a player’s hunger information they can use `hunger_ng.get_hunger_information()` This returns a table with all relevant hunger-related information for the given player name.

```Lua
local info = hunger_ng.get_hunger_information('Foobar')
```

The information of the returned table can be used for further processing. Be aware that the value should not be stored for too long because the actual value will change over time and actions basing on the hunger value might not be exact anymore.

```Lua
{
    player_name = 'Foobar',
    hunger = {
        floored = 18,
        ceiled = 19
        exact = 18.928,
        disabled = false,
    },
    maximum = {
        hunger = 20,
        health = 20,
        breath = 11
    },
    effects = {
        starving = false,
        healing = true,
        current_breath = 11
    },
    timestamps = {
        last_eaten = 1549670580,
        request = 1549671198
    }
}
```

The `hunger` sub-table contains four values. `floored` is the next lower full number while `ceiled` is the next higher full number (this value is used to create the hunger bar from). The `exact` value represents the hunger value at the moment when the request was made and can be a floating point number.

The `disabled` value indicates if hunger is disabled for the player (either because the player has no interact permission or the player has the corresponding meta information set. This can be used by other mods to control hunger management.

The `maximum` sub-table is a convenient way to get the maximum values of the settings for this user.

In `effects` the current player effects are given. `starving` and `healing` indicate if the player is below the starving limit or above the healing limit (the respective values are `true` then). If both values are `false` then the user is within the frame between those two limits. `curren_breath` gives the current breath of the player.

The sub-table `timestamps` contains timestamps according to the server time. `last_eaten` is the value of when the player ate something for the last time or is `0` if the player never ate anything before. `request` is the value of when the request was made. It can be used to determine the age of the information.

If the given player name is not a name of a currently available player the returned table contains two entries.

```Lua
{
    invalid = true,
    player_name = 'Foobar'
}
```

The `player_name` is the name of the player that can’t be found and `invalid` can be used as check if the request was successful.

```Lua
local info = hunger_ng.get_hunger_information('Foobar')
if info.invalid then
    print(info.player_name..' can’t be found.')
else
    print('Hunger of '..info.player_name..' is at '..info.hunger.exact..'.')
end
```

This example prints either `Foobar can’t be found.` or `Hunger of Foobar is at 18.928.` depending on if the user is available or not.

## Mod compatibility

The hunger bar is in the same position as the breath bar (the bubbles that appear when a player is awash) and disappears if the breath bar becomes visible. Any mod changing the position of the breath bar needs to change the position of the hunger bar as well.

Mods that alter or replace food with own versions ignoring custom item attributes will render them unusable for *Hunger NG* resulting in not being processed by *Hunger NG* but handled regularly.

Mods using the `/hunger` or `/myhunger` chat commands will either break or be broken when used in combination with *Hunger NG*.

Mods deleting or overwriting the global table `hunger_ng` break any mods that use the functions that are stored in the table.
