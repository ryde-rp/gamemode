local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "chat")

RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

local mutedPlayers = {}

RegisterServerEvent('chat:kickSpammer')
AddEventHandler('chat:kickSpammer', function()
    TriggerClientEvent('chatMessage', -1, "^1Jucatorul  " .. GetPlayerName(source) .. " a primit kick pentru spam.")
    DropPlayer(source, 'RYDE: Ai facut prea mult spam si ai primit kick!')
end)

RegisterCommand("resetvw", function(player, args)

    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then

        local target_id = tonumber(args[1])
        if target_id then

            local target_src = vRP.getUserSource({target_id})

            if target_src then

                SetPlayerRoutingBucket(target_src, 0)
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai resetat lui ^1" .. GetPlayerName(target_src) ..
                    " ^7virtual-world-ul"})
                vRPclient.sendInfo(target_src, {"^1" .. GetPlayerName(player) .. " ^7ti-a resetat virtual-world-ul"})

            else
                vRPclient.notOnline(player)
            end

        else
            vRPclient.cmdUse(player, {"/resetvw <user_id>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("startevent", function(player)
    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then
        if eventOn then
            evCoords = {}
            eventOn = false

            TriggerClientEvent("chatMessage", -1, "^1Event^0: Event-ul a inceput. Jucatorii nu mai pot folosi comanda ^1/goevent ^0!")
        else
            TriggerClientEvent("chatMessage", player, "^0Eroare^7: Nu exista nici un eveniment activ !")
        end
    else
        TriggerClientEvent("chatMessage", player, "^1Eroare^7: Nu ai acces la aceasta comanda")
    end
end, false)

RegisterCommand("goevent", function(player)
    if eventOn then
        vRPclient.teleport(player, {evCoords[1], evCoords[2], evCoords[3]})
        TriggerClientEvent("zedutz:setFreeze", player, true)
    else
        TriggerClientEvent("chatMessage", player, "^1[Eroare]^7: Nu exista nici un eveniment activ")
    end
end, false)

RegisterCommand("event", function(player)
    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then
        if not eventOn then
            vRPclient.getPosition(player, {}, function(x, y, z)
                evCoords = {x, y, z + 0.5}
            end)
            eventOn = true
            TriggerClientEvent("chatMessage", -1, "^1[Event]^0: Adminul "..vRP.getPlayerName({player}).." a pornit un eveniment ! Foloseste </goevent> pentru a da tp acolo")

        end
    else
        TriggerClientEvent("chatMessage", player, "^1[Eroare]^7: Nu ai acces la aceasta comanda")
    end
end, false)

-- RegisterCommand("testtaxi", function(player)
--     local user_id = vRP.getUserId({player})
--     local user = vRP.getUserSource({user_id})
--     if vRP.isUserFondator({user_id}) then

--         local pozitie = {
--             x = 895.42523193359,
--             y = -179.46859741211,
--             z = 74.700325012207
--         }
--         local pozitiecar = {
--             x = 917.24792480469,
--             y = -181.9061126709,
--             z = 74.050842285156
--         }
--         local parcare = {
--             x = 918.90319824219,
--             y = -167.06143188477,
--             z = 74.658622741699
--         }
--         local detinator = {
--             user_id = user_id,
--             name = GetPlayerName(user)
--         }

--         exports.oxmysql:execute("INSERT INTO taxicompanies (name,pos,carpos,car,profit,owner,price,parking) VALUES(@name,@pos,@carpos,@car,@profit,@owner,@price,@parking)",{
--             ['@name'] = "Downtown",
--             ['@pos'] = json.encode(pozitie),
--             ['@carpos'] = json.encode(pozitiecar),
--             ['@car'] = 1,
--             ['@profit'] = 75,
--             ['@owner'] = json.encode(detinator),
--             ['@price'] = 0,
--             ['@parking'] = json.encode(parcare)
--         })

--         vRPclient.notify(user,{"Ai folosit comanda de TEST TAXI"})
--     end 
-- end)


RegisterCommand("setvw", function(player, args)

    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then

        local target_id = tonumber(args[1])
        local vw = tonumber(args[2])
        if target_id and vw then

            local target_src = vRP.getUserSource({target_id})

            if target_src then

                SetPlayerRoutingBucket(target_src, vw)
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai setat lui ^1" .. GetPlayerName(target_src) ..
                    " ^7virtual-world in ^1" .. vw})
                vRPclient.sendInfo(target_src,
                    {"^1" .. GetPlayerName(player) .. " ^7ti-a setat virtual-world-ul in ^1" .. vw})

            else
                vRPclient.notOnline(player)
            end

        else
            vRPclient.cmdUse(player, {"/setvw <user_id> <world>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("anim", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserAdministrator({user_id}) then
        local target_id = tonumber(args[1])
        local anim = args[2]
        if target_id then
            local target_src = vRP.getUserSource({target_id})
            if target_src then
                vRPclient.executeCommand(target_src, {"e " .. anim .. ""})
            else
                vRPclient.notConnected(player)
            end
        else
            vRPclient.cmdUse(player, {"/anim <user_id> <anim>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)


RegisterCommand("freeze", function(player, args)

    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then

        local target_id = tonumber(args[1])
        if target_id then

            local target_src = vRP.getUserSource({target_id})

            if target_src then

                vRPclient.setFreeze(target_src, {true, true})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat freeze lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat freeze."})

            else
                vRPclient.notOnline(player)
            end

        else
            vRPclient.cmdUse(player, {"/freeze <user_id>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("unfreeze", function(player, args)

    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then

        local target_id = tonumber(args[1])
        if target_id then

            local target_src = vRP.getUserSource({target_id})

            if target_src then

                vRPclient.setFreeze(target_src, {false, true})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat unfreeze lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat unfreeze."})

            else
                vRPclient.notOnline(player)
            end

        else
            vRPclient.cmdUse(player, {"/unfreeze <user_id>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("freezearea", function(player, args)
    local user_id = vRP.getUserId({player})
    if not vRP.isUserHelper({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.cmdUse(player, {"/freezearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then

        vRPclient.getNearestPlayers(player, {radius}, function(users)

            local msg = "^5RYDE: ^1" .. GetPlayerName(player) .. " ^7ti-a dat freeze"
            local amm = 0

            for src, dst in pairs(users) do
                amm = amm + 1

                vRPclient.setFreeze(src, {true, true})
                vRPclient.sendInfo(src, {msg})
            end

            vRPclient.sendInfo(player, {"^2Succes: ^7Ai dat freeze la ^1" .. amm .. "^7 jucatori"})
        end)

    else
        vRPclient.showError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("unfreezearea", function(player, args)
    local user_id = vRP.getUserId({player})
    if not vRP.isUserHelper({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.cmdUse(player, {"/unfreezearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then

        vRPclient.getNearestPlayers(player, {radius}, function(users)

            local msg = "^5RYDE: ^7^1" .. GetPlayerName(player) .. " ^7ti-a dat unfreeze."
            local amm = 0

            for src, dst in pairs(users) do
                amm = amm + 1

                vRPclient.setFreeze(src, {false, true})
                vRPclient.sendInfo(src, {msg})
            end

            vRPclient.sendInfo(player, {"^2Succes: ^7Ai dat unfreeze la ^1" .. amm .. "^7 jucatori."})
        end)

    else
        vRPclient.showError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("drop", function(player, args)
    if player == 0 then
        local src = tonumber(args[1])
        if src then
            local kickmsg = "[Kick]"
            for i = 2, #args do
                kickmsg = kickmsg .. " " .. args[i]
            end

            DropPlayer(src, kickmsg)
        else
            print("/drop <src>")
        end
    else

        local user_id = vRP.getUserId({player})
        if vRP.isUserAdministrator({user_id}) then
            if args[1] and args[2] then

                local src = tonumber(args[1])
                local kickmsg = ""
                for i = 2, #args do
                    kickmsg = kickmsg .. " " .. args[i]
                end

                DropPlayer(src, kickmsg)

                vRP.sendStaffMessage({"^1Drop^7: " .. GetPlayerName(player) .. " i-a dat drop lui src " .. src .. " cu mesajul: " ..kickmsg, 4})
            else
                vRPclient.sendSyntax(player, {"/drop <src> <kick-msg>"})
            end
        else
            vRPclient.noAccess(player)
        end
    end
end)

RegisterCommand("eject", function(player)
    vRPclient.getNearestPlayer(player, {10}, function(nplayer)
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
            vRPclient.isHandcuffed(nplayer, {}, function(handcuffed) -- check handcuffed
                if handcuffed then
                    vRPclient.ejectVehicle(nplayer, {})
                else
                    vRPclient.showError(player, {"Utilizatorul selectat treuie sa fie incatusat."})
                end
            end)
        else
            vRPclient.showError(player, {"Nu este nici un jucator langa tine."})
        end
    end)
end)

RegisterCommand("aa2", function(player)
    local user_id = vRP.getUserId({player})
    if vRP.isUserTrialHelper({user_id}) then
        SetEntityCoords(GetPlayerPed(player), -174.23487854004,497.4382019043,137.6669921875)
    end
end, false)

RegisterCommand("clearinv", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserAdministrator({user_id}) then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource({target_id})
            if target_src then
                vRP.clearInventory({target_id})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai sters inventarul lui ^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a sters inventar-ul."})
            else
                vRPclient.notConnected(player)
            end
        else
            vRPclient.cmdUse(player, {"/clearinv <user_id>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("uncuff", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserHelper({user_id}) then
        local target_id = tonumber(args[1])
        if target_id then
            local target_src = vRP.getUserSource({target_id})
            if target_src then
                vRPclient.setHandcuff(target_src, {false})
                vRPclient.sendInfo(player, {"^2Succes: ^7I-ai dat uncuff lui^1" .. GetPlayerName(target_src)})
                vRPclient.sendInfo(target_src, {"" .. GetPlayerName(player) .. " ^7ti-a dat uncuff"})
            else
                vRPclient.notOnline(player)
            end
        else
            vRPclient.cmdUse(player, {"/uncuff <user_id>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)


RegisterCommand("unban", function(src, args)
    local target_id = tonumber(args[1])

    if src == 0 then
        if not target_id then return print("^5Sintaxa: ^7/unban <id>") end
        
        vRP.isUserBanned{target_id, function(banned, _)
            if not banned then return print("^1Failed: ^7Jucatorul nu este banat.") end

            vRP.unbanPlayer{0, target_id}
            print("^2Success: ^7Jucatorul a fost debanat.")
        end}

        return
    end

    local user_id = vRP.getUserId{src}
    if not vRP.isUserAdministrator{user_id} then return vRPclient.denyAcces(src, {}) end

    if not target_id then
        return vRPclient.cmdUse(src, {"/unban <user_id>"})
    end

    exports.oxmysql:execute("SELECT username FROM users WHERE id = @id",{['@id'] = target_id}, function(success, result)
        if (#result > 0) and result[1].username then
            vRP.isUserBanned{target_id, function(banned, banDocument)
                if banned then
                    vRP.request{src, ("Ban System<br>Esti sigur ca vrei sa-l debanezi pe %s?<br>Motiv ban: %s<br>Banat de: %s"):format(result[1].username, banDocument.banReason, banDocument.bannedBy, banDocument.expireDate), false, function(_, ok)
                        if ok then
                            vRP.unbanPlayer{user_id, target_id}
                        end
                    end}
                else
                    vRPclient.notConnected(src)
                end
            end}
        end
    end)
end)


RegisterCommand("sprites", function(player)

    local user_id = vRP.getUserId({player})
    

    if vRP.hasGroup({user_id, "Sindicat"}) or vRP.isUserHelper({user_id}) then
        TriggerClientEvent("vRP:showSprites", player)
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("ticketee", function(player)
    vRPclient.executeCommand(player, {"facetitickete"})
end)

RegisterCommand("facetitickete", function(player)
    if (player == 0) or vRP.isUserAdministrator({vRP.getUserId({player})}) or vRP.getUserId({player}) == 3770 then
        vRP.doStaffFunction({1, function(src)
            vRPclient.sendInfo(src,
                {"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})
            vRPclient.sendInfo(src,
                {"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})
            vRPclient.sendInfo(src,
                {"^7Sunt foarte multe tickete în așteptare, în caz că ai uitat, comanda e ^1/tk^7!"})

            TriggerClientEvent("vRP:playAudio", src, "alarmstaff")
        end})
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("svid", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        if tonumber(args[1]) and args[2] then
            local target_src = vRP.getUserSource({tonumber(args[1])})
            if target_src then
                local carModel = args[2]
                local vehicle = vRP.spawnVehicle({GetHashKey(carModel), GetEntityCoords(GetPlayerPed(target_src)), GetEntityHeading(GetPlayerPed(target_src)), true, false})
                SetPedIntoVehicle(GetPlayerPed(target_src), vehicle, -1)
                SetVehicleNumberPlateText(vehicle, "METHIU 69ADM")
                SetTimeout(200, function()
                    if DoesEntityExist(vehicle) then
                        SetEntityRoutingBucket(vehicle, tonumber(GetPlayerRoutingBucket(target_src)))
                    end
                end)

                if not args[3] then
                    vRPclient.notify(target_src, {"Ti-a fost spawnat un vehicul de tip "..carModel.." de la "..GetPlayerName(player)})
                    vRPclient.notify(player, {"I-ai spawnat un vehicul de tip "..args[2].." lui "..GetPlayerName(target_src), "success"})
                end
            else
                vRPclient.notOnline(player)
            end
        else
            vRPclient.cmdUse(player, {"/svid <user_id> <vehicul>"})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

RegisterCommand("veh", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId{src}
    if not vRP.isUserMod{user_id} then
        return vRPclient.denyAcces(src, {})
    end
    
    local carModel = tostring(args[1])
    if not args[1] then
        return vRPclient.cmdUse(src, {"/veh <car_model>"})
    end

    local vehicle = vRP.spawnVehicle({GetHashKey(carModel), GetEntityCoords(GetPlayerPed(src)), GetEntityHeading(GetPlayerPed(src)), true, false})
    SetPedIntoVehicle(GetPlayerPed(src), vehicle, -1)
    SetVehicleNumberPlateText(vehicle, "METHIU 69ADM")
    SetTimeout(200, function()
        if not DoesEntityExist(vehicle) then
            return vRPclient.notify(src, {"Modelul "..carModel.." este invalid!", "warning"})
        else
            SetEntityRoutingBucket(vehicle, tonumber(GetPlayerRoutingBucket(src)))
            vRPclient.notify(src, {"Ai spawnat un vehicul cu modelul: "..carModel, "success"})
       end
    end)
end)

local disLogs = {}
local lastDisc = {}
RegisterCommand("dislogs", function(player)
    local user_id = vRP.getUserId({player})
    if vRP.isUserAdministrator({user_id}) then
        if disLogs[player] then
            disLogs[player] = nil
            vRPclient.sendInfo(player, {"^1Succes: ^7Logurile au fost dezactivate."})
        else
            disLogs[player] = true
            vRPclient.sendInfo(player, {"^2Succes: ^7Logurile au fost activate."})
        end
    else
        vRPclient.denyAcces(player)
    end
end, false)

RegisterCommand("disarea", function(player, args)
    local pedCds = GetEntityCoords(GetPlayerPed(player))
	local user_id = vRP.getUserId({player})
	if vRP.isUserAdministrator({user_id}) then
	    local radius = tonumber(args[1])
	    if radius and radius > 0 and radius <= 1000 then

            local totalLeft = 0
            local msg = "^7-------- Ultimele deconectari ^7 --------"

            for indx, data in pairs(lastDisc) do
                if data.expire >= os.time() then

                    local dist = #(data.pos - pedCds)
                    if dist <= radius then
                        local years, months, days, hours, minutes, seconds = passedTime(data.time, os.time())

                        msg = msg .. "\n^1" .. data.name .. " ["..data.user_id.."]:^7 "..math.floor(dist).." metri - "..os.date("%H:%M", data.time).." ^1(acum "..minutes.." minute, "..seconds.." secunde)^7"
                        totalLeft += 1
                    end
                else
                    lastDisc[indx] = nil
                end
            end

            msg = msg .. "\n\n^uPe o raza de "..radius.." de metri sunt in total: "..totalLeft.." (de) deconectari\n^7------------------------------------"
            vRPclient.msg(player, {msg})

	    else
		    vRPclient.sendSyntax(player, {"/disarea <raza (1-1000)>"})
	    end
	else
	  vRPclient.noAccess(player)
	end
end)

RegisterServerEvent("chat:sendLogs")
AddEventHandler("chat:sendLogs", function(logmsg)
    if not string.find(logmsg, "Type: 13") then
        for v, state in pairs(disLogs) do
            TriggerClientEvent('chatMessage', v, logmsg)
        end
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, spawned, reason)
    if reason and not string.find(reason:lower(), "restart") and spawned then
        local pos = GetEntityCoords(GetPlayerPed(player))
        if user_id then

            table.insert(lastDisc, {user_id = user_id, name = GetPlayerName(player), pos = pos, time = os.time(), expire = os.time() + 1800})
            TriggerEvent("chat:sendLogs", "["..os.date("%d/%m/%Y %H:%M").."] "..GetPlayerName(player).." ["..user_id.."] - ^1"..reason)
            PerformHttpRequest(
                "https://discord.com/api/webhooks/1051527316209152050/ZfHDzMKwthssadfgzREBKL3Mx6CnPb74u8WNW5iH5K9dm3oNyTWUZNnZZjvcz_Bb8jLc",
                function(err, text, headers)
                end, 'POST', json.encode({
                    embeds = {{
                        description = reason,
                        color = 0xce0944,
                        author = {
                            name = (GetPlayerName(player) or 'Unknown') .. " [" .. user_id .. "]",
                            icon_url = "https://cdn.discordapp.com/attachments/1051527282176565298/1137006399705063494/logofinal.png"
                        },
                        footer = {
                            text = os.date("%d/%m/%y %H:%M")..""
                        }
                    }}

                }), {
                    ['Content-Type'] = 'application/json'
                })
        end
        disLogs[player] = nil
    end
end)

local forReply = {}

RegisterCommand("cancelpm", function(player, args)
    local user_id = vRP.getUserId({player})

    if user_id then
        for target_id, replyId in pairs(forReply) do
            if replyId == user_id then
                replyId = nil
                forReply[target_id] = nil
            end
        end

        vRPclient.sendInfo(player, {"Ai oprit toate PM-urile active."})
    end
end)

RegisterCommand("pm", function(player, args)
    local user_id = vRP.getUserId({player})

    if not vRP.isUserTrialHelper({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local target_id = tonumber(args[1])
    if not target_id or not args[2] then
        return vRPclient.cmdUse(player, {"/pm <id> <mesaj>"})
    end

    if target_id == user_id then
        return vRPclient.showError(player, {"Trebuie sa dai PM altui jucator, nu poti vorbii cu tine"})
    end

    local target_src = vRP.getUserSource({target_id})
    if not target_src then
        return vRPclient.notConnected(player)
    end

    local msg = table.concat(args, " ", 2)

    if msg ~= " " and msg ~= "" then
        TriggerClientEvent("chatMessage", player, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("chatMessage", target_src, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("vRP:playAudio", target_src, "pmSound", 1.0)

        if not forReply[target_id] or forReply[target_id] ~= user_id then
            forReply[target_id] = user_id

            TriggerClientEvent('chatMessage', target_src, "^zPM-Reply: ^7Pentru a raspunde la PM foloseste comanda ^z/r <mesaj>")
        end
    end
end)

RegisterCommand("r", function(player, args)
    local user_id = vRP.getUserId({player})
    local target_id = forReply[user_id]

    if not target_id then
        return vRPclient.showError(player, {"Nici un membru staff nu ti-a dat mesaj."})
    end

    local target_src = vRP.getUserSource({target_id})
    if not target_src then
        return vRPclient.notConnected(player)
    end

    if not args[1] then
        return vRPclient.cmdUse(player, {"/r <mesaj>"})
    end

    local msg = table.concat(args, " ", 1)

    forReply[target_id] = user_id

    if msg ~= "" and msg ~= " " then
        TriggerClientEvent("chatMessage", player, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("chatMessage", target_src, "^t(PM): ^7"..GetPlayerName(player).." -> "..GetPlayerName(target_src)..": ^j"..msg)
        TriggerClientEvent("vRP:playAudio", target_src, "pmSound", 1.0)
    end
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, dbdata)
    if first_spawn then

        if dbdata.chatMute then
            mutedPlayers[user_id] = dbdata.chatMute
        end

        PerformHttpRequest(
            "https://discord.com/api/webhooks/1051527316209152050/ZfHDzMKwthssadfgzREBKL3Mx6CnPb74u8WNW5iH5K9dm3oNyTWUZNnZZjvcz_Bb8jLc",
            function(err, text, headers)
            end, 'POST', json.encode({
                embeds = {{
                    description = "A intrat pe server",
                    color = 0x34eb34,
                    author = {
                        name = (GetPlayerName(player) or 'Unknown') .. " [" .. user_id .. "]",
                        icon_url = "https://cdn.discordapp.com/attachments/1051527282176565298/1137006348501012530/logofinal.png"
                    },
                    footer = {
                        text = os.date("%d/%m/%y %H:%M")
                    }
                }}

            }), {
                ['Content-Type'] = 'application/json'
            })

        if not vRP.isUserVip({user_id}) and not vRP.isUserAdministrator({user_id}) then
            local author = GetPlayerName(player)
            local prevName = author

            author = sanitizeString(author, "^", false)
            if author ~= prevName then
                for i = 1, 10 do
                    Citizen.Wait(500)
                    TriggerClientEvent("chatMessage", player,
                        "RYDE: Doar membrii cu grade de VIP au voie sa detina culori in nume. Scoate caracterul \"^\" din nume.")
                end
                Citizen.Wait(1000)
                DropPlayer(player,
                    "RYDE: Doar membrii cu grade de VIP au voie sa detina culori in nume. Scoate caracterul \"^\" din nume.")
            end
        end
    end
end)

RegisterCommand("fonline", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserAdministrator({user_id}) then
        local userFaction = vRP.getUserFaction({user_id})
        if args[1] then
            userFaction = table.concat(args, " ", 1)
        end

        local fType = vRP.getFactionType({userFaction})

        if fType == "Gang" or fType == "Mafie" or userFaction == "Smurd" or userFaction == "Politia Romana" then
            local msg = "^7---- Membrii Online: ^5" .. userFaction .. "^7 ----"

            local users = vRP.getUsersByFaction({userFaction})
            local online = 0

            for k, v in pairs(users) do
                local src = vRP.getUserSource({v.id})
                if src then
                    msg = msg .. "\n" .. v.username .. " [" .. v.id .. "]"
                    online = online + 1
                end
            end
            msg = msg .. "\nTotal membrii conectati in factiune: "..online.." (de) jucatori\n^7-------------------"
            vRPclient.msg(player, {msg})
        else
            vRPclient.showError(player, {"Factiunea selectata este una invalida."})
        end
    else
        vRPclient.denyAcces(player)
    end
end)

local adminsOnly = false
RegisterCommand("chatoff", function(player)
    local user_id = vRP.getUserId({player})
    if user_id then
        if vRP.isUserAdministrator({user_id}) then
            vRPclient.msg(-1, {"^1Chat^7: " .. GetPlayerName(player) .. " a oprit chat-ul global!"})
            adminsOnly = true
        else
            vRPclient.noAccess(player)
        end
    end
end)

RegisterCommand("chaton", function(player)
    local user_id = vRP.getUserId({player})
    if user_id then
        if vRP.isUserAdministrator({user_id}) then
            vRPclient.msg(-1, {"^1Chat^7: " .. GetPlayerName(player) .. " a pornit chat-ul global!"})
            adminsOnly = false
        else
            vRPclient.noAccess(player)
        end
    end
end)

local lastMessage = {}
AddEventHandler('_chat:messageEntered', function(author, color, message)
    local user_id = vRP.getUserId({source})
    
    if user_id then
        if message and author then

            local adminLvl = vRP.getUserAdminLevel({user_id})

            if (adminLvl > 0) or (lastMessage[user_id] or 0) < os.time() then
                local colorData = {
                    chatColor = "7",
                    chatPrefix = "[Cetățean]",
                }
                if user_id == 1 then
                    colorData.chatColor = "z"
                    colorData.chatPrefix = "^7[👑]^z [Owner] "
                    colorData.messageColor = "z"
                elseif user_id == 2 then
                    colorData.chatColor = "z"
                    colorData.chatPrefix = "^7[💸]^z [DEVELOPER] "
                    colorData.messageColor = "z"
                elseif adminLvl == 1 then
                    colorData.chatColor = "2"
                    colorData.chatPrefix = "[Helper in Teste]"
                    colorData.messageColor = "0"
                elseif adminLvl == 2 then
                    colorData.chatColor = "2"
                    colorData.chatPrefix = "[Helper]"
                    colorData.messageColor = "0"
                elseif adminLvl == 3 then
                    colorData.chatColor = "3"
                    colorData.chatPrefix = "[Helper Avansat]"
                    colorData.messageColor = "0"
                elseif adminLvl == 4 then
                    colorData.chatColor = "6"
                    colorData.chatPrefix = "[Moderator]"
                    colorData.messageColor = "0"
                elseif adminLvl == 5 then
                    colorData.chatColor = "5"
                    colorData.chatPrefix = "[Super Moderator] "
                    colorData.messageColor = "0"
                elseif adminLvl == 6 then
                    colorData.chatColor = "4"
                    colorData.chatPrefix = "[Lider Moderator]"
                    colorData.messageColor = "0"
                elseif adminLvl == 7 then
                    colorData.chatColor = "3"
                    colorData.chatPrefix = "[Admin]"
                    colorData.messageColor = "0"
                elseif adminLvl == 8 then
                    colorData.chatColor = "3"
                    colorData.chatPrefix = "[Super Admin]"
                    colorData.messageColor = "0"
                elseif adminLvl == 9 then
                    colorData.chatColor = "6"
                    colorData.chatPrefix = "[Supervizor]"
                    colorData.messageColor = "0"
                elseif adminLvl == 10 then
                    colorData.chatColor = "1"
                    colorData.chatPrefix = "[Head Of Staff]"
                    colorData.messageColor = "0"
                elseif adminLvl == 11 then
                    colorData.chatColor = "2"
                    colorData.chatPrefix = "[Co-Fondator]"
                    colorData.messageColor = "0"
                elseif adminLvl == 12 then
                    colorData.chatColor = "2"
                    colorData.chatPrefix = "[Fondator]"
                    colorData.messageColor = "0"
                elseif adminLvl == 13 then
                    colorData.chatColor = "3"
                    colorData.chatPrefix = "[Manager]"
                    colorData.messageColor = "0"
                elseif adminLvl == 14 then
                    colorData.chatColor = "5"
                    colorData.chatPrefix = "[💎 Ryde Regal]"
                    colorData.messageColor = "0"
                elseif adminLvl == 15 then
                    colorData.chatColor = "1"
                    colorData.chatPrefix = "[Co-Owner]"
                    colorData.messageColor = "0"
                elseif adminLvl == 16 then
                    colorData.chatColor = "z"
                    colorData.chatPrefix = "[Owner Ryde]"
                    colorData.messageColor = "z"
                elseif adminLvl == 17 then
                    colorData.chatColor = "z"
                    colorData.chatPrefix = "[Developer]"
                    colorData.messageColor = "z"
                elseif vRP.isUserVipPlatinum({user_id}) then
                    colorData.chatColor = "5"
                    colorData.chatPrefix = "💎[RYDE KING]"
                elseif vRP.isUserVipGold({user_id}) then
                    colorData.chatColor = "3"
                    colorData.chatPrefix = "🥇[GOLD ACCOUNT]"
                elseif vRP.isUserVipSilver({user_id}) then
                    colorData.chatColor = "u"
                    colorData.chatPrefix = "🥈[SILVER ACCOUNT]"
                elseif vRP.hasUserFaction({user_id}) then
                    local userFaction = vRP.getUserFaction({user_id})
        
                    if userFaction == "Politia Romana" then
                        colorData.chatColor = "f"
                        colorData.chatPrefix = "[POLITIST]"
                    elseif userFaction == "Smurd" then
                        colorData.chatColor = "8"
                        colorData.chatPrefix = "[SMURD]"
                    elseif userFaction == "DIICOT" then
                        colorData.chatColor = "f"
                        colorData.chatPrefix = "[DIICOT]"
                    elseif userFaction == "Surnik 13" then
                            colorData.chatColor = "3"
                            colorData.chatPrefix = "[SURNIK 13]"
                    elseif userFaction == "Los Vagos" then
                            colorData.chatColor = "1"
                            colorData.chatPrefix = "[Los Vagos]"
                    elseif userFaction == "Los Varrios" then
                            colorData.chatColor = "1"
                            colorData.chatPrefix = "[LOS VARRIOS]"
                    elseif vRP.getFactionType({userFaction}) == "Mafie" then
                        colorData.chatColor = "i"
                        colorData.chatPrefix = "🔪"..userFaction.."🔪"
                    end
                end
        
                if not WasEventCanceled() then
                    if message:len() > 300 then
                        return vRPclient.showError(source, {"Mesajul tau depaseste limita de 300 de caractere!"})
                    end
        
                    if adminsOnly and adminLvl < 3 then
                        return vRPclient.sendError(source, {"Chat: ^7 Chat-ul este oprit momentan de catre un admin."})
                    end
        
                    if (mutedPlayers[user_id] or 0) < os.time() then
                        local theColor = colorData.chatColor
                        TriggerClientEvent('chatMessage', -1, "^"..theColor..colorData.chatPrefix.."^7 " .. author .. " [^"..theColor.. user_id .."^7]: ^" ..(colorData.messageColor or "7")..message, source)
                        print("["..os.date("%H:%M").."] ^7["..user_id..'] '..author..': ' .. message .. '^7')
                        lastMessage[user_id] = os.time() + 5
                    else
                        local totalsec = mutedPlayers[user_id] - os.time()
                        vRPclient.sendError(source, {"Chat: ^7Ai mute inca ^1" .. totalsec .. "^7 (de) secunde!"})
                    end
                end
    

            else
                vRPclient.showError(source, {"Chat: ^7Asteapta inca ^1"..(lastMessage[user_id] - os.time()).." (de) secunde^7 inainte de a scrie un mesaj pe chat!"})
            end

        end
    
    else
        DropPlayer(source, "Conexiunea cu serverul a fost intrerupta.")
    end
end)

RegisterCommand("say", function(src, args)
    if src == 0 then
        if not args[1] then return print("^5Sintaxa: ^7/say <mesaj>") end
        TriggerClientEvent("chatMessage", -1, "^e(Broadcast): ^7"..table.concat(args, " "))
    else
        local user_id = vRP.getUserId{src}
        local allowed = (user_id >= 1 and user_id < 4)
        
        if not allowed then
            return vRPclient.denyAcces(src, {})
        end

        if not args[1] then
            return vRPclient.cmdUse(src, {"/say <mesaj>"})
        end

        TriggerClientEvent("chatMessage", -1, "^3(Broadcast) "..(GetPlayerName(src) or "Necunoscut").. " ["..user_id.."]: ^7"..table.concat(args, " "))
    end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    print(command)
    local name = GetPlayerName(source)
    if not WasEventCanceled() then
        vRPclient.showError(source, {"Comanda /"..command.." nu este inregistrata sau nu functioneaza."})
    end

    CancelEvent()
end)

RegisterCommand("clear", function(src)
    if src == 0 then
        TriggerClientEvent("chat:clear", -1)
        vRPclient.sendInfo(-1, {"Adminul Ryde-Team (0) a sters tot chatul."})
        return
    end
    
    local user_id = vRP.getUserId{src}
    if vRP.isUserHelper{user_id} then
        TriggerClientEvent("chat:clear", -1)
        vRPclient.sendInfo(-1, {"Adminul "..GetPlayerName(src).." ("..user_id..") a sters tot chatul."})
    else
        vRPclient.denyAcces(src, {})
    end
end)

RegisterCommand("tpto", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId{src}
    if not vRP.isUserTrialHelper{user_id} then return vRPclient.denyAcces(src, {}) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.cmdUse(src, {"/tpto <id>"}) end
    local target_src = vRP.getUserSource{target_id}
    if not target_src then return vRPclient.notConnected(src) end

    vRPclient.getPosition(target_src, {}, function(tX, tY, tZ)
        vRPclient.teleport(src, {tX, tY, tZ})
        vRPclient.notify(src, {"Te-ai teleportat la "..GetPlayerName(target_src), "success"})
    end)
    
    if not args[2] then
        vRPclient.notify(target_src, {"Adminul "..GetPlayerName(src).." s-a teleportat la tine"})
    end
end)


RegisterCommand("taketk", function(player, args)
    local user_id = vRP.getUserId({player})
    if not vRP.isUserDeveloper({user_id}) then return vRPclient.denyAcces(player, {}) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.cmdUse(player, {"/taketk <id>"}) end
    local target_src = vRP.getUserSource({target_id})
    if not target_src then return vRPclient.notConnected(player) end
    vRPclient.executeCommand(target_src, {"tk"})
    vRPclient.sendInfo(player, {"L-ai trimis pe "..GetPlayerName(target_src).." la ticket"})
end)

RegisterCommand("tptome", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId{src}
    if not vRP.isUserTrialHelper{user_id} then return vRPclient.denyAcces(src, {}) end
    local target_id = tonumber(args[1])
    if not target_id then return vRPclient.cmdUse(src, {"/tptome <id>"}) end
    local target_src = vRP.getUserSource{target_id}
    if not target_src then return vRPclient.notConnected(src) end

    vRPclient.getPosition(src, {}, function(pX, pY, pZ)
        vRPclient.teleport(target_src, {pX, pY, pZ})
        vRPclient.notify(target_src, {"Adminul "..GetPlayerName(src).." te-a teleportat la el", "warning"})
        vRPclient.notify(source, {"L-ai teleportat la tine pe jucatorul "..GetPlayerName(target_src).." ("..target_id..")", "success"})
    end)
end)

RegisterCommand("tptow", function(src)
    local user_id = vRP.getUserId{src}
    if vRP.isUserMod{user_id} then
        vRPclient.gotoWaypoint(src, {})
    else
        vRPclient.denyAcces(src, {})
    end
end)

RegisterCommand("respawn", function(src, args)
	local respawnLocation = {-508.95568847656,-261.23751831055,35.479434967041}

    local user_id = vRP.getUserId{src}
    if not vRP.isUserTrialHelper{user_id} then
        return vRPclient.denyAcces(src, {})
    end
    
    local target_id = tonumber(args[1])
    if not target_id then
        return vRPclient.cmdUse(src, {"/respawn <id>"})
    end
    
    local target_src = vRP.getUserSource{target_id}
    if not target_src then
        return vRPclient.notConnected(src)
    end
    
    vRPclient.sendInfo(-1, {"Adminul "..GetPlayerName(src).." ("..user_id..") i-a dat respawn lui "..GetPlayerName(target_src).." ("..target_id..")"})
    vRPclient.teleport(target_src, respawnLocation)
    vRPclient.loadFreeze(target_src, {true})

    Citizen.CreateThread(function()
        vRPclient.teleport(target_src, respawnLocation)
        Citizen.Wait(500)
        vRPclient.loadFreeze(target_src, {false})
    end)
end)

RegisterCommand("arevive", function(src, args)
    local user_id = vRP.getUserId{src}
    if not vRP.isUserTrialHelper{user_id} then
        return vRPclient.denyAcces(src, {})
    end

    local target_id = tonumber(args[1])
    if not target_id then
        return vRPclient.cmdUse(src, {"/revive <id>"})
    end
    
    local target_src = vRP.getUserSource{target_id}
    if not target_src then
        return vRPclient.notConnected(src)
    end
    vRPclient.sendInfo(-1, {"^0Adminul^1 "..GetPlayerName(src).." ^0i-a dat revive lui^1 "..GetPlayerName(target_src).." ("..target_id..")"})
    
    vRPclient.setHealth(target_src, {200})
end)

RegisterCommand("arevivearea", function(player, args)
    local user_id = vRP.getUserId({player})

    if not vRP.isUserHelper({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local radius = tonumber(args[1])
    if not radius then
        return vRPclient.cmdUse(player, {"/revivearea <radius (max 50)>"})
    end

    if radius <= 50 and radius >= 1 then
        vRPclient.getNearestPlayers(player, {radius}, function(users)
            users[player] = 1

            for nearestSrc, _ in pairs(users) do
                vRPclient.varyHealth(nearestSrc, {100})

                SetTimeout(500, function()
                    vRPclient.varyHealth(nearestSrc, {100})
                end)
            end

            vRPclient.sendInfo(-1, {"^0Adminul^1 "..GetPlayerName(player).." ^0a dat revive pe o raza de^1 "..radius.." metri"})
        end)
    else
        vRPclient.showError(player, {"Raza poate fii maxim de 50 de metri."})
    end
end)

RegisterCommand("areviveall", function(source)
    local player = source
    if source == 0 then
        vRPclient.varyHealth(-1, {100})
    
        SetTimeout(500, function()
            vRPclient.varyHealth(-1, {100})
        end)

        vRPclient.sendInfo(-1, {"Server-ul a dat ^5revive^7 la toti jucatorii conectati."})
    end

    local user_id = vRP.getUserId({player})
    if not vRP.isUserMod({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    vRPclient.varyHealth(-1, {100})
    
    SetTimeout(500, function()
        vRPclient.varyHealth(-1, {100})
    end)

    vRPclient.sendInfo(-1, {"^0Adminul^1 " .. GetPlayerName(player) .. " ^0a dat revive la tot server-ul."})
end)

RegisterCommand("setadmin", function(player, args)
    local granted = false
    if player == 0 then
        granted = true
    elseif IsPlayerAceAllowed(player, "command") then
        granted = true
    end

    if not granted then
        return vRPclient.denyAcces(player, {})
    end

    local targetid = tonumber(args[1])
    local adminLvl = tonumber(args[2])

    if targetid and adminLvl then
        local targetSrc = vRP.getUserSource({targetid})

        local name = ""
        if targetSrc then
            print("Done online")
            vRP.setUserAdminLevel({targetid, adminLvl})

            if player ~= 0 then
                name = "de la " .. GetPlayerName(player)
            end

            if adminLvl == 0 then
                vRPclient.notify(targetSrc, {"Ai primit remove din staff.", "warning", false, "fas fa-user"})
                vRP.addPanelHistory({targetid, "A primit remove din staff" .. name, "removeadmin"})
            else
                vRPclient.notify(targetSrc, {"Ai primit Admin Level: "..adminLvl, "info", false, "fas fa-user"})
                Citizen.Wait(100)
                vRP.addPanelHistory({targetid,"A primit gradul de " ..vRP.getUserAdminTitle({targetid}) .. " " .. name, "setadmin"})
            end
        else
            print("Done offline")

            exports.oxmysql:execute("UPDATE users SET adminLvl = @adminLvl WHERE id = @id",{['@id'] = targetid, ['@adminLvl'] = adminLvl})

            if adminLvl == 0 then
                vRP.addPanelHistory({targetid, "A primit remove din staff" .. name, "removeadmin"})
            else
                vRP.addPanelHistory({targetid, "A primit gradul de " ..vRP.getUserAdminTitle({targetid}) .. " " .. name, "setadmin"})
            end
        end
    else
        print("Syntax: /setadmin <user_id> <adminLvl>")
    end
end)

RegisterCommand("veh", function(src, args)
    if src == 0 then return end
    local user_id = vRP.getUserId{src}
    if not vRP.isUserMod{user_id} then
        return vRPclient.denyAcces(src, {})
    end
    
    local carModel = tostring(args[1])
    if not args[1] then
        return vRPclient.cmdUse(src, {"/veh <car_model>"})
    end
    local vehicle = vRP.spawnVehicle({GetHashKey(carModel), GetEntityCoords(GetPlayerPed(src)), GetEntityHeading(GetPlayerPed(src)), true, false})
    SetPedIntoVehicle(GetPlayerPed(src), vehicle, -1)
    SetVehicleNumberPlateText(vehicle, "METHIU 69ADM")
    SetTimeout(200, function()
        if not DoesEntityExist(vehicle) then
            return vRPclient.notify(src, {"Modelul "..carModel.." este invalid!", "warning"})
        else
            SetEntityRoutingBucket(vehicle, tonumber(GetPlayerRoutingBucket(src)))
            vRPclient.notify(src, {"Ai spawnat un vehicul cu modelul: "..carModel, "success"})
       end
    end)
end)

RegisterCommand("faggio", function(source)
    if source == 0 then return end
    local user_id = vRP.getUserId({source})

    if not vRP.isUserTrialHelper({user_id}) then
        return vRPclient.denyAcces(source, {})
    end

    local vehicle = vRP.spawnVehicle({GetHashKey("faggio"), GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source)), true, false})
    SetPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
    SetEntityRoutingBucket(vehicle, GetPlayerRoutingBucket(source))
    vRPclient.notify(source, {"Ai spawnat un Faggio!", "info", false, "fas fa-motorcycle"})
end)

RegisterServerEvent("chat:onStaffMessage", function(msg)
    vRPclient.executeCommand(source, {"a "..msg})
end)

RegisterServerEvent("chat:onDepartmentMessage", function(msg)
    local player = source
    local user_id = vRP.getUserId({player})

    if vRP.isUserPolitist({user_id}) then
        vRPclient.executeCommand(player, {"d "..msg})
    elseif vRP.isUserMedic({user_id}) then
        vRPclient.executeCommand(player, {"m "..msg})
    else
        vRPclient.sendError(player, {"Nu ai acces la acest chat."})
    end
end)

local staffMessage = "^j[Staff Chat] (%s)^7 %s (%d): ^j%s"
RegisterCommand("a", function(src, args)
    if src == 0 then
        if not args[1] then
            return print("^5Sintaxa: ^7/a <staff_message>")
        end

        local theMessage = table.concat(args, " ")

        vRP.doStaffFunction({1, function(src)
            TriggerClientEvent('chatMessage', src, staffMessage:format("^9$$$^5", "Consola", 0, theMessage));
        end})

        return
    end

    local user_id = vRP.getUserId{src}
    if not vRP.isUserTrialHelper{user_id} then return vRPclient.denyAcces(src, {}) end
    
    if not args[1] then return vRPclient.cmdUse(src, {"/a <staff_message>"}) end
    local theMessage = table.concat(args, " ")
    
    local author = GetPlayerName(src) or "Necunoscut"
    vRP.doStaffFunction({1, function(src)
        TriggerClientEvent('chatMessage', src, staffMessage:format(vRP.getUserAdminTitle{user_id}, author, user_id, theMessage));
    end})

    print("["..os.date("%d/%m/%Y %H:%M").."] ^7[Staff]["..user_id..'] '..author..': ' .. theMessage .. '^7')
end)

RegisterCommand("hs", function(src, args)
    if src == 0 then
        if not args[1] then
            return print("^5Sintaxa: ^7/a <staff_message>")
        end

        local theMessage = table.concat(args, " ")

        vRP.doStaffFunction({5, function(src)
            TriggerClientEvent('chatMessage', src, ("^7[High Staff] %s(%s)^7 %s (%d): %s%s"):format("^3", "^9$$$^3", "Consola", 0, "^3", theMessage));
        end})

        return
    end

    local user_id = vRP.getUserId{src}
    if not vRP.isUserAdministrator{user_id} then return vRPclient.denyAcces(src, {}) end
    
    if not args[1] then return vRPclient.cmdUse(src, {"/hs <staff_message>"}) end
    local theMessage = table.concat(args, " ")
    
    local author = GetPlayerName(src) or "Necunoscut"
    local chatColor = tostring(vRP.getUserColoredAdminTitle{user_id}):sub(1, 2)
    vRP.doStaffFunction({5, function(src)
        TriggerClientEvent('chatMessage', src, ("^7[High Staff] %s(%s)^7 %s (%d): %s%s"):format(chatColor, vRP.getUserAdminTitle{user_id}, author, user_id, chatColor, theMessage));
    end})

    print("^1[High-Staff]^7 "..author.." ["..user_id.."]: ^1"..theMessage.."^7")
end)

RegisterCommand("ban", function(src, args)
    local target_id = tonumber(args[1])
    local time = tonumber(args[2])
    local dreptPlata = ((tonumber(args[3]) or 0) == 0) and true or false

    if not target_id or not time or not tonumber(args[3]) or not args[4] then
        local syntax = "/ban <user_id> <time (-1 = permanent)> <plata (0 = da, 1 = nu)> <motiv>"
        if src == 0 then
            print("^5Sintaxa: ^7"..syntax)
        else
            vRPclient.cmdUse(src, {syntax})
        end

        return
    end

    if src == 0 then
        local theReason = table.concat(args, " ", 4)
        if time == 0 then return print("Trebuie sa specifici un numar valid de zile!") end
        vRP.banPlayer{0, target_id, (time or -1), theReason, dreptPlata}
        return
    end

    local user_id = vRP.getUserId{src}
    if not vRP.isUserMod{user_id} then return vRPclient.denyAcces(src) end

    local theReason = table.concat(args, " ", 4)
    if time == 0 then return vRPclient.showError(src, {"Trebuie sa specifici un numar valid de zile."}) end
    vRP.banPlayer{user_id, target_id, (time or -1), theReason, dreptPlata}
end)

RegisterCommand("kick", function(player, args)
    if player == 0 then
        local usr = parseInt(args[1])
        if usr ~= nil and usr then
            local src = vRP.getUserSource({usr})
            if src ~= nil and usr then
                vRP.kick({src, "RYDE: Ai primit kick de la Consola!"})
            else
                print("Jucator-ul este offline!")
            end
        else
            print("/kick <user_id>")
        end
    else
        local user_id = vRP.getUserId({player})
        if vRP.isUserHelper({user_id}) then
            if args and args[1] and args[2] then
                local target_id = parseInt(args[1])
                local reason = args[2]
                for i = 3, #args do
                    reason = reason .. " " .. args[i]
                end
                if target_id and reason then
                    local target_src = vRP.getUserSource({target_id})
                    if target_id ~= 3 then
                        if target_src then
                            local adminName = GetPlayerName(player) or "Necunoscut"

                            vRPclient.sendInfo(-1, {"^1Kick: ^0Adminul^1 "..adminName.." ^0l-a dat afara pe^1 "..(GetPlayerName(target_src) or "Necunoscut").." ("..target_id.."), motiv: "..reason})
                            vRP.kick{target_src, "Adminul "..adminName.." ti-a dat kick!\nMotiv: "..reason}
                        else
                            vRPclient.notOnline(player)
                        end
                    else
                        TriggerClientEvent("chatMessage", -1, "^1[SYSTEM] ^7" .. GetPlayerName(player) ..
                            " a incercat sa-i dea kick lui ^1" .. GetPlayerName(target_src))
                        vRP.kick({player, "Ti-ai dat muie singur"})
                    end
                end
            else
                vRPclient.cmdUse(player, {"/kick <user_id> <motiv>"})
            end
        else
            vRPclient.denyAcces(player)
        end
    end
end)

RegisterCommand("id", function(player, args)
    if args[1] then
        local strToFind = args[1]
        if strToFind:len() >= 0 then

            local users = vRP.getUsers({})

            if player ~= 0 then
                local user_id = vRP.getUserId({player})
                for k, v in pairs(users) do
                    if GetPlayerName(v) then
                        if string.find(GetPlayerName(v):upper(), strToFind:upper()) or string.find(k, strToFind) then
                            local fct = vRP.getUserFaction({k}) or "user"
                            local job = "Somer"
                            if fct == "user" then
                                fct = "Civil"
                            end


                                local usrr = "^5" .. GetPlayerName(v) .. "^7(^5" .. k .. "^7) | Ore: ^5" .. vRP.getUserHoursPlayed({k}) .. "^7 | Ore ^5(last 7 days): ^7"..vRP.getUserLastHours({k}).." ^5|^7 "
                                if vRP.isUserTrialHelper({user_id}) then
                                    usrr = usrr .. " Factiune: ^5" .. fct .. "^7 | Src: ^5" ..(v < 60000 and v or 'Loading Screen') .. " ^7| V-World: ^5" ..GetPlayerRoutingBucket(v)
                                end

                                TriggerClientEvent("chatMessage", player, usrr)

                        end
                    elseif tostring(k) ~= "0" and k then
                        Citizen.CreateThread(function()
                            vRP.deleteOnlineUser({k})
                        end)
                    end
                end
            else
                print("^7----------------------------------------------------------------------------------------------------------------------------------------------------\n# Rezultatele cautarii dupa cheia: ^3" .. args[1].."^7")
                for k, v in pairs(users) do
                    if GetPlayerName(v) then
                        if string.find(GetPlayerName(v):upper(), strToFind:upper()) or string.find(k, strToFind) then
                            local fct = vRP.getUserFaction({k}) or "user"
                            local job = "Somer"
                            if fct == "user" then
                                fct = "Civil"
                            end
                                local usrr = "^5" .. GetPlayerName(v) .. "^7[^5" .. k .. "^7] Job: ^5" .. job .."^7 Ore: ^5" .. vRP.getUserHoursPlayed({k}) .. "^7 Ore ^5(last 7 days): ^7"..vRP.getUserLastHours({k}).."^5 ^7| Factiune: ^5" .. fct .. "^7 Src: ^5" ..(v < 60000 and v or 'Loading Screen') .. "^7 V-World: ^5" ..GetPlayerRoutingBucket(v).." ^7Bank: ^5$"..vRP.formatMoney({vRP.getBankMoney({k})}).."^7 Wallet: ^5$"..vRP.formatMoney({vRP.getMoney({k})}).."^7 Coins: ^5"..vRP.getXZCoins({k})
                                print(usrr)
                        end
                    elseif tostring(k) ~= "0" and k then
                        vRP.deleteOnlineUser({k})
                    end
                end
                print("^7----------------------------------------------------------------------------------------------------------------------------------------------------")
            end
        else
            if player ~= 0 then
                vRPclient.cmdUse(player, {"/id <parte din nume (min. 2 litere) / id>"})
            else
                print("/id <parte din nume>")
            end
        end
    else
        if player ~= 0 then
            vRPclient.cmdUse(player, {"/id <parte din nume (min. 2 litere) / id>"})
        else
            print("/id <parte din nume>")
        end
    end
end)

RegisterCommand("stats", function(player)
    if player == 0 then
        -- replace last command
        return ExecuteCommand("status")
    end

    local name = GetPlayerName(player)
    local user_id = vRP.getUserId({player})
    local identity = vRP.getIdentity({user_id}) or {sex = "M"}
    local sex = identity.sex or "M"
    local userFaction = vRP.getUserFaction({user_id})
    local vipTag = vRP.getUserVipRank({user_id})

    if vipTag > 0 then
        vipTag = vRP.getUserVipTitle({user_id, vipTag}):gsub(" Account", "")
    else
        vipTag = false
    end

    if userFaction == "user" then
        userFaction = "Not in a faction"
    end

    local userObj = {
        faction = userFaction,
        accountLvl = vipTag,
        lastHours = vRP.getUserLastHours({user_id}),
        totalHours = vRP.getUserHoursPlayed({user_id}),
    }

    TriggerClientEvent("vRP:showAccountStats", player, user_id, name, sex:lower(), userObj, vRP.getWarns({user_id}))
end)

RegisterCommand("unmute", function(source, args)
    local target_id = tonumber(args[1])

    local user_id = vRP.getUserId({source})
    if not vRP.isUserMod({user_id}) then
        return vRPclient.denyAcces(source, {})
    end

    if not target_id then
        return vRPclient.cmdUse(source, {"/unmute <id>"})
    end

    local targetSrc = vRP.getUserSource({target_id})
    if not targetSrc then
        return vRPclient.notConnected(source)
    end

    mutedPlayers[target_id] = nil
    vRPclient.msg(-1, {"^4Unmute: Adminul "..GetPlayerName(source).." ("..user_id..") i-a dat unmute lui "..GetPlayerName(targetSrc).." ("..target_id..")"})
end)

-- RegisterCommand("savepoint", function(source)
--     local fileReader = io.open("resources/[gamemode]/chat/savedPoints.txt", "a")

--     vRPclient.getPosition(source, {}, function(x,y,z)
--         fileReader:write(("vec3(%s, %s, %s),"):format(x,y,z))
--         fileReader:close()
--     end)
-- end)

RegisterCommand("ss", function(player, args)
    local user_id = vRP.getUserId({player})
    if not vRP.isUserMod({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local target_id = tonumber(args[1])
    if not target_id then
        return vRPclient.cmdUse(player, {"/ss <id>"})
    end

    local target_src = vRP.getUserSource({target_id})
    if not target_src then
        return vRPclient.notConnected(player)
    end

    TriggerClientEvent("RYDE-ac$requestScreenshot", target_src, player)
    vRP.sendStaffMessage({"^5RYDE:^7Adminul ^5" .. GetPlayerName(player) .. " ^7[^5"..user_id.."^7] a folosit screenshot pe ^5" ..GetPlayerName(target_src).." ^7[^5"..target_id.."^7]", 5})
end)

RegisterServerEvent("RYDE-ac$sendScreenshot")
AddEventHandler("RYDE-ac$sendScreenshot", function(player, data)
    local css = [[
        .div_screenshot{
            width: 80%;
            height: 80%;
            margin: auto;
            margin-top: 1vh;
            z-index: -1;
            color: white;
            font-family: "Smooch Sans";
        }
    ]]

    vRPclient.setDiv(player, {"screenshot", css, '<center><h2 style="width: 100%; background-color: rgba(0, 0, 0, .25); border: 2px solid #ffffff10; padding: 1vh;"><i class="fas fa-camera" style="padding: .5vh; background-color: rgba(255, 255, 255, .15); border: 2px solid #ffffff10; border-radius: .25vw;"></i> &nbsp; Ecranul lui ' .. GetPlayerName(source) .. ' [' .. vRP.getUserId({source}) .. ']</h2><br/><img style="box-shadow: 0 0 6vw #00000070; border-radius: .25vw; border: 2px solid #ffffff10; padding: 1vh; background: #00000020;" src="' .. data .. '" style="max-width: 1280px;" /></center>'})
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        vRPclient.removeDiv(player, {"screenshot"})
    end)
end)

RegisterCommand("cleanup", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        TriggerClientEvent("RYDE-utils:delAllVehs", -1, tonumber(args[1]) or 60)
    else
        vRPclient.denyAcces(player, {})
    end
end)

RegisterCommand("cancelcleanup", function(player)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        TriggerClientEvent("RYDE-utils:cancelDellAllVehs", -1, 60)
        vRPclient.sendInfo(-1, {"Adminul " .. GetPlayerName(player) .. " ("..user_id..") a anulat stergerea masinilor"})
    else
        vRPclient.denyAcces(player, {})
    end
end)

local function giveAllBankMoney(amount)
    local users = vRP.getUsers({})
    for user_id, source in pairs(users) do
        vRP.giveBankMoney({user_id, tonumber(amount)})
        print("Bonus (money) dat pentru ID: "..user_id)
    end
end

local function giveAllCoins(amount)
    local users = vRP.getUsers({})
    for user_id, source in pairs(users) do
        vRP.giveCoins({user_id, tonumber(amount)})
        print("Bonus (coins) dat pentru ID: "..user_id)
    end
end

RegisterCommand("giveallmoney", function(player, args)
    if player == 0 then
        local theMoney = parseInt(args[1]) or 0
        if theMoney < 1 then
            return print("/giveallmoney <amount>")
        end

        giveAllBankMoney(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: Server-ul a oferit tuturor jucatorilor $" ..vRP.formatMoney({theMoney}) .. ".")
    else
        local user_id = vRP.getUserId({player})
        if not vRP.isUserDeveloper({user_id}) then
            return vRPclient.denyAcces(player, {})
        end

        local theMoney = parseInt(args[1]) or 0

        if theMoney < 1 then
            return vRPclient.cmdUse(player, {"/giveallmoney <amount>"})
        end

        giveAllBankMoney(theMoney)
        TriggerClientEvent("chatMessage", -1, "^2Bonus: " .. vRP.getPlayerName({player}) .. " a oferit tuturor jucatorilor $" ..vRP.formatMoney({theMoney}) .. ".")
    end
end)

RegisterCommand("giveallcoins", function(player, args)
    if player == 0 then
        local theMoney = parseInt(args[1]) or 0
        if theMoney < 1 then
            return print("/giveallcoins <amount>")
        end

        giveAllCoins(theMoney)
        TriggerClientEvent("chatMessage", -1, "^3Bonus: Server-ul a oferit tuturor jucatorilor suma de " ..vRP.formatMoney({theMoney}) .. " rydeCoins.")
    else
        local user_id = vRP.getUserId({player})
        if not vRP.isUserDeveloper({user_id}) then
            return vRPclient.denyAcces(player, {})
        end

        local theMoney = parseInt(args[1]) or 0

        if theMoney < 1 then
            return vRPclient.cmdUse(player, {"/giveallcoins <amount>"})
        end

        giveAllCoins(theMoney)
        TriggerClientEvent("chatMessage", -1, "^3Bonus: " .. vRP.getPlayerName({player}) .. " a oferit tuturor suma de " ..vRP.formatMoney({theMoney}) .. " rydeCoins.")
    end
end)

RegisterCommand("resetvwall", function(player)
    local user_id = vRP.getUserId({player})
    if not vRP.isUserAdministrator({user_id}) then
        return vRPclient.denyAcces(player, {})
    end

    local users = vRP.getUsers({})
    for uid, src in pairs(users) do
        SetPlayerRoutingBucket(src, 0)
    end

    vRPclient.sendInfo(-1, {"Adminul "..GetPlayerName(player) .. " a resetat virtual world-ul pentru tot server-ul"})
end)

-- RegisterCommand("testtaxi", function(player)
--     local user_id = vRP.getUserId({player})
--     local user = vRP.getUserSource({user_id})

--     local pozitie = {
--         x = 895.66870117188,
--         y = -179.19967651367,
--         z = 74.700202941895
--     }
--     local pozitiecar = {
--         x = 910.85113525391,
--         y = -175.33839416504,
--         z = 74.265602111816
--     }
--     local parcare = {
--         x = -1428.525390625,
--         y = -676.7938842773,
--         z = 26.660442352295
--     }
--     local detinator = {
--         user_id = user_id,
--         name = GetPlayerName(user)
--     }

--     exports.oxmysql:execute("INSERT INTO taxicompanies (name,pos,carpos,car,profit,owner,price,parking) VALUES(@name,@pos,@carpos,@car,@profit,@owner,@price,@parking)",{
--         ['@name'] = "Downtown",
--         ['@pos'] = json.encode(pozitie),
--         ['@carpos'] = json.encode(pozitiecar),
--         ['@car'] = 1,
--         ['@profit'] = 75,
--         ['@owner'] = json.encode(detinator),
--         ['@price'] = 0,
--         ['@parking'] = json.encode(parcare)
--     })

--     vRPclient.notify(user,{"Ai folosit comanda de TEST TAXI"})
-- end)



