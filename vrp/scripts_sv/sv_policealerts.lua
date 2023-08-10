
local backupCodes = {
    [0] = " are nevoie de intariri ",
    [1] = " are nevoie de asistenta",
    [2] = " are nevoie de ingrijiri medicale",
    [3] = " are nevoie de asistenta urgenta",
    [4] = " are nevoie de ingrijiri medicale",
}

local bkCooldown = 0

RegisterCommand("bk", function(player, args)
    local user_id = vRP.getUserId(player)
    local userIdentity = vRP.getIdentity(user_id)
    local code = tonumber(args[1])

    if code == 0 or code == 4 then
        if vRP.isUserPolitist(user_id) or vRP.isUserMedic(user_id) then
            if code == 4 then
                vRP.doFactionFunction("Smurd", function(src)
                    TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
                end)
                return;
            end
        
            if code == 0 then
                vRP.doFactionFunction("Smurd", function(src)
                    TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
                end)
                vRP.doFactionFunction("Politia Romana", function(src)
                    TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
                end)
                return;
            end
        else
            return vRPclient.notify(player, {"Doar Politistii sau Medicii au accees la aceste coduri de alerta!"})
        end
    end

    if code == 1 or code == 2 or code == 3 then
        if not vRP.isUserPolitist(user_id) then
            return vRPclient.notify(player, {"Doar politistii au acces la aceasta comanda!"})
        end
    end

    if not backupCodes[code] then return vRPclient.notify(player, {"Acest cod de asistenta nu exista!", "error"}) end

    if (bkCooldown or 0) >= os.time() then return vRPclient.notify(player, {"Este cooldown activ, asteapta "..bkCooldown - os.time().." secunde inainte sa dai un bk", "error"}) end

    bkCooldown = os.time() + 5
    
    if code == 2 then
        vRP.doFactionFunction("Smurd", function(src)
            TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
        end)
        vRP.doFactionFunction("Politia Romana", function(src)
            TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
        end)
        return;
    end

    vRP.doFactionFunction("Politia Romana", function(src)
        TriggerClientEvent("vRP:showPoliceRequest", src, GetEntityCoords(GetPlayerPed(player)), code, "20:00", userIdentity.firstname, userIdentity.name)
    end)
end)

local shootcooldown = 0

RegisterServerEvent("vRP:registerPoliceAlert", function(data, playerCoords)
    if shootcooldown >= os.time() then return end;
    vRP.doFactionFunction("Politia Romana", function(src)
        TriggerClientEvent("vRP:alertThePolice", src, data, playerCoords)
    end)
    shootcooldown = shootcooldown + 3;
end)