minetest.register_on_prejoinplayer(function(name, ip)
        if string.match(name, "[A-Z]%D+%d%d%d") ~= nil then
           return "Please use the official Minetest client."
           end
end)
