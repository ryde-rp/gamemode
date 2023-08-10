local Doors = module("cfg/doorlock")

Citizen.CreateThread(function()
    Wait(500)
    TriggerClientEvent('vrp-doorlock:populateDoors', -1, Doors)
end)

RegisterServerEvent("vrp-doorlock:tryOpen", function(id)
    local player = source
    local user_id = vRP.getUserId(player)
    local doorType = Doors[id].acces
    if doorType.faction then
        if vRP.isUserInFaction(user_id, doorType.faction) then
            vRPclient.playAnim(player, {false, {{"mp_arresting", "a_uncuff", 1}}, false})
            SetTimeout(4000, function()
                Doors[id].locked = not Doors[id].locked
                TriggerClientEvent("vrp-doorlock:setOneStatus", -1, id, Doors[id].locked)
            end)
        else
            if Doors[id].locked then
                vRPclient.notify(player, {"Nu ai acces sa deschizi aceasta usa"})
            else
                vRPclient.notify(player, {"Nu ai acces sa inchizi aceasta usa"})
            end
        end
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent('vrp-doorlock:populateDoors', source, Doors)
    end
end)
