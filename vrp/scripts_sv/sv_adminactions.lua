RegisterCommand("banplayer", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local admin = parseInt(args[2])
        local time = args[3]
        local canPay = args[4]
        local theReason = table.concat(args, " ", 5)
        local drept = true;

        if tostring(canPay) == "1" then
            drept = false
        else
            drept = true
        end

        if not target then return end 
        if not admin then return end
        if not time then return end
        if not theReason then theReason = "Nu a fost mentionat" end;

        vRP.banPlayer(admin, tonumber(target), -1, theReason, canPay)
    end
end)

RegisterCommand("kickplayer", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local admin = parseInt(args[2])
        local target_src = vRP.getUserId({target})

        if not target_src then return end;
        if not target then return end 
        if not admin then return end;

        local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = admin})
        local adminName = " "..(username.username or "Necunoscut").." ["..admin.."]"

        print("PANEL ACTIONS: Adminul"..adminName.." ia dat kick jucatorului "..(GetPlayerName(target_src) or "Necunoscut"))
        vRP.kickPlayer(tonumber(target), "Ai primit KICK din Panel de la Adminul "..adminName)
    end
end)

RegisterCommand("givecoins", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local coins = parseInt(args[2])
    
        local player = vRP.getUserSource(target)
        if player then
            vRP.giveCoins(target, coins, true)
            vRPclient.msg(player, {"^3VIP: ^7Donatia ta tocmai a fost procesata, multumim pentru incredere!"})
        else
            exports.oxmysql:execute("UPDATE users SET premiumCoins = @premiumCoins WHERE id = @id",{['@id'] = target, ['@premiumCoins'] = coins})
        end
    end
end)

RegisterCommand("removeitemfromplayer", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local item = tostring(args[2])
        local amount = parseInt(args[3])

        print(target, item, amount)

        local player = vRP.getUserSource(target)
        if player then
            vRP.tryGetInventoryItem(target, item, amount, true)
        else
            exports.oxmysql:query("SELECT dvalue FROM uData WHERE user_id = @user_id AND dkey = @dkey",{['@user_id'] = target, ['@dkey'] = "vRP:datatable"}, function(result)
                if result[1] then
                    local val = json.decode(result[1].dvalue)
                    if val.inventory[item] then
                        if val.inventory[item].amount > amount then
                            val.inventory[item].amount = tonumber(val.inventory[item].amount) - amount
                        elseif val.inventory[item].amount == amount then
                            val.inventory[item] = nil
                        elseif val.inventory[item].amount < amount then
                            val.inventory[item] = nil
                        end
                    end
                    exports.oxmysql:execute("UPDATE uData SET dvalue = @dvalue WHERE user_id = @user_id AND dkey = @dkey",{
                        ['@user_id'] = target,
                        ['@dkey'] = "vRP:datatable",
                        ['@dvalue'] = json.encode(val)
                    })
                end
            end)
        end
    end
end)

RegisterCommand("removeitemfromveh", function(player, args)
    if player == 0 then
        local item = tostring(args[1])
        local amount = parseInt(args[2])
        local chestName = tostring(args[3])

        print(item, amount, chestName)
		vRP.getSData(chestName, function(cdata)
			local chestDecoded = json.decode(cdata) or {}

            if chestDecoded[item] then
                if chestDecoded[item].amount > amount then
                    chestDecoded[item].amount = tonumber(chestDecoded[item].amount) - amount
                elseif chestDecoded[item].amount == amount then
                    chestDecoded[item] = nil
                elseif chestDecoded[item].amount < amount then
                    chestDecoded[item] = nil
                end
            end
            vRP.setSData(chestName, json.encode(chestDecoded))
        end)
    end
end)


RegisterCommand("givemoney", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local money = parseInt(args[2])

        local player = vRP.getUserSource(target)
        if player then
            vRP.giveMoney(target, money, "Admin")
            vRPclient.msg(player, {"^3Ryde: ^7Ai primit "..money.."$ de la un admin!"})
        else
            exports.oxmysql:execute("UPDATE users SET walletMoney = @walletMoney WHERE id = @id",{
                ['@id'] = target,
                ['@walletMoney'] = money
            })
        end
    else
        local user_id = vRP.getUserId(player)
        local target_id = parseInt(args[1])
        local amount = parseInt(args[2])

        if vRP.isUserDeveloper(user_id) then
            if target_id then
                local target = vRP.getUserSource(target_id)

                if target then
                    vRP.giveMoney(target_id, amount)
                    vRPclient.notify(player, {"Ai dat " .. amount .. "$ jucatorului cu id-ul " .. target_id.." [ONLINE]", "info"})
                    vRPclient.notify(target, {"Ai primit " .. amount .. "$ de la " .. (GetPlayerName(player) or ("ID "..target_id)), "info"})
                else   
                    exports.oxmysql:execute("UPDATE users SET walletMoney = @walletMoney WHERE id = @id",{
                        ['@id'] = target,
                        ['@walletMoney'] = amount
                    })
                    vRPclient.notify(player, {"Ai dat " .. amount .. "$ jucatorului cu id-ul " .. target_id.." [OFFLINE]", "info"})
                end
            end
        else
            vRPclient.notify(player, {"Nu ai acces la aceasta comanda.", "error"})
        end
    end
end)

RegisterCommand("unbanplayer", function(player, args)
    if player == 0 then
        local target = parseInt(args[1])
        local admin = parseInt(args[2])

        vRP.isUserBanned(target, function(banned)
            if banned then
                local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = admin})
        
                print("PANEL ACTIONS: Adminul "..(username.username or "Necunoscut").." ["..admin.."] ia dat unban jucatorului "..target)
                vRP.unbanPlayer(admin, target)
            end
        end)
    end
end)

--[[RegisterCommand("resetrapoarte", function(player)
    if player == 0 then
        exports.mongodb:update({collection = "users", query = {}, update = {
            ["$set"] = {["userRaport.tickets"] = 0, ["userRaport.mute"] = 0, ["userRaport.bans"] = 0, ["userRaport.jail"] = 0}
        }})

        print("PANEL ACTIONS: Rapoartele au fost resetate!")
        vRP.doStaffFunction(1, function(src)
            vRPclient.notify(src, {"Rapoartele tocmai ce au fost resetate! Spor la tickete!", "info"})
        end)
    end
end)--]]