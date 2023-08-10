local activeCalls = {}
local inCall = {}

function tvRP.TakeApel(id, faction)
    local player = source
    local user_id = vRP.getUserId(player)
    local userIdentity = vRP.getIdentity(user_id)
    local calls = activeCalls[faction] or {}
    local data = calls[id]
    if not data then
        return vRPclient.notify(player, {"Acest apel este indisponibil momentan.", "error"})
    end

    if faction == "Politia Romana" then
        if not vRP.isUserPolitist(user_id) then return end
        local target_src = vRP.getUserSource(tonumber(data.playerID))

        if target_src then
            TriggerClientEvent("qb-phone:client:autoAnswer", player)
            TriggerClientEvent("fp-services:generateCall", target_src, user_id, exports['vrp_phone']:getPhoneNumber(user_id), "Politia Romana")

            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]

            vRP.doFactionFunction("Politia Romana", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)
            
            return true
        else
            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]

            vRP.doFactionFunction("Politia Romana", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)
            
            vRPclient.notify(player, {"Jucatorul nu mai este online", "error"})
            return "offline"
        end
    else
        if not vRP.isUserMedic(user_id) then return end
        local target_src = vRP.getUserSource(tonumber(data.playerID))

        if target_src then
            TriggerClientEvent("qb-phone:client:autoAnswer", player)
            TriggerClientEvent("fp-services:generateCall", target_src, user_id, exports['vrp_phone']:getPhoneNumber(user_id), "Centru Medical")

            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]
            
            vRP.doFactionFunction("Smurd", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)
            return true
        else
            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]

            vRP.doFactionFunction("Smurd", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)

            vRPclient.notify(player, {"Jucatorul nu mai este online", "error"})
            return "offline"
        end
    end
end

function tvRP.CancelCall(id, faction)
    local player = source
    local user_id = vRP.getUserId(player)
    local userIdentity = vRP.getIdentity(user_id)
    local data = activeCalls[faction][id]

    if faction == "Politia Romana" then
        if not vRP.isUserPolitist(user_id) then return end
    
        if vRP.isFactionLeader({ user_id }) then
            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]

            vRP.doFactionFunction("Politia Romana", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)

            local target_src = vRP.getUserSource(tonumber(data.playerID))
            if target_src then
                local copName = userIdentity.firstname.." "..userIdentity.name
                vRPclient.notify(player, {copName.." ti-a inchis apelul", "info"})
            end
            
            return true
        end
    else
        if not vRP.isUserMedic(user_id) then return end
    
        if vRP.isFactionLeader({ user_id }) then
            activeCalls[faction][id] = nil
            inCall[data.playerID] = nil
            local oneTbl = activeCalls[faction]

            vRP.doFactionFunction("Smurd", function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, oneTbl)
            end)

            local target_src = vRP.getUserSource(tonumber(data.playerID))
            if target_src then
                local copName = userIdentity.firstname.." "..userIdentity.name
                vRPclient.notify(player, {copName.." ti-a inchis apelul", "info"})
            end

            return true
        end
    end
    return false
end

RegisterServerEvent("vRP:factionCall", function(service)
    local player = source
    local user_id = vRP.getUserId(player)

    if inCall[user_id] then
        return exports["vrp_phone"]:sendPhoneError(player, "Ai deja un apel activ!")
    end

    local userIdentity = vRP.getIdentity(user_id)
    local existingTbl = activeCalls[service]

    if not existingTbl then
        activeCalls[service] = {}
    end

    local callsCount = #(existingTbl or {})
    local callID = callsCount + 1

    vRPclient.getPositionWithArea(player, {}, function(positionTbl)
        if type(positionTbl) == "table" then
            activeCalls[service][callID] = {
                callID = callID,
                faction = service,
                coords = positionTbl.coords,
                location = positionTbl.zone,
                playerID = user_id,
                date = os.date("%d.%m.%Y %H:%M"),
                name = userIdentity.firstname.." "..userIdentity.name,
                phone = userIdentity.phone,
            }

            local newTbl = activeCalls[service]
            vRP.doFactionFunction(service, function(src)
                TriggerClientEvent("vRP:updateFactionCalls", src, newTbl)
                vRPclient.notify(src, {"Un nou apel a fost inregistrat!", "info", false, "fas fa-phone"})
            end)

            inCall[user_id] = true
            exports["vrp_phone"]:sendPhoneInfo(player, "Apelul tau a fost inregistrat!")
        end
    end)
end)

local factionLogos = {
    ["Politia Romana"] = "https://cdn.discordapp.com/attachments/1013920317128843355/1035669777512931359/police-logo.png",
    ["Smurd"] = "https://cdn.discordapp.com/attachments/1013920317128843355/1035671579486584833/viceroy.png",
}

RegisterCommand("apeluri", function(player)
    local user_id = vRP.getUserId(player)
    local userFaction = vRP.getUserFaction(user_id)
    local canAccess = vRP.isUserPolitist(user_id) or vRP.isUserMedic(user_id)

    if canAccess then
        TriggerClientEvent("vRP:openFactionCalls", player, activeCalls[userFaction] or {}, factionLogos[userFaction])
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, isSpawned)
    inCall[user_id] = nil
end)