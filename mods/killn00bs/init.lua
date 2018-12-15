minetest.register_on_prejoinplayer(function(name, ip)
        if string.match(name, "[A-Z]%D+%d%d%d") ~= nil and name ~= "Ashton9191" then
           return "The format of your username is disallowed - please rejoin with a different username if your client supports it."
           end
end)
