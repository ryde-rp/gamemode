function vRP.addRaport(user_id, raport_type, many)
    exports.oxmysql:execute("SELECT userRaport FROM users WHERE id = @id", {
        ['@id'] = user_id
    }, function(results)
        if results[1] and results[1].userRaport then
            local raport = json.decode(results[1].userRaport)
            raport[raport_type] = (raport[raport_type] or 0) + (many or 1)

            exports.oxmysql:execute("UPDATE users SET userRaport = @raport WHERE id = @id", {
                ['@raport'] = json.encode(raport),
                ['@id'] = user_id
            })
        end
    end)
end