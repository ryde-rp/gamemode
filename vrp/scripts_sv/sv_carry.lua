local piggybacking = {}
local beingPiggybacked = {}
local carrying = {}
local carried = {}

RegisterServerEvent("Piggyback:sync")
AddEventHandler("Piggyback:sync", function(targetSrc)
    if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][piggyBack]")
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    if #(sourceCoords - targetCoords) <= 3.0 then 
        TriggerClientEvent("Piggyback:syncTarget", targetSrc, source)
        piggybacking[source] = targetSrc
        beingPiggybacked[targetSrc] = source
    end
end)

RegisterServerEvent("Piggyback:stop")
AddEventHandler("Piggyback:stop", function(targetSrc)
    if piggybacking[source] then
        TriggerClientEvent("Piggyback:cl_stop", targetSrc)
        piggybacking[source] = nil
        beingPiggybacked[targetSrc] = nil
    elseif beingPiggybacked[source] then
        TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
        piggybacking[beingPiggybacked[source]] = nil
        beingPiggybacked[source] = nil
    end
end)

RegisterServerEvent("CarryPeople:sync")
AddEventHandler("CarryPeople:sync", function(targetSrc)
    if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][carryPeople]")
    end

    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    
    if #(sourceCoords - targetCoords) <= 3.0 then 
        TriggerClientEvent("CarryPeople:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

RegisterServerEvent("CarryPeople:stop")
AddEventHandler("CarryPeople:stop", function(targetSrc)
    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])          
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

AddEventHandler('vRP:playerLeave', function()    
    if piggybacking[source] then
        TriggerClientEvent("Piggyback:cl_stop", piggybacking[source])
        beingPiggybacked[piggybacking[source]] = nil
        piggybacking[source] = nil
    end

    if beingPiggybacked[source] then
        TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
        piggybacking[beingPiggybacked[source]] = nil
        beingPiggybacked[source] = nil
    end

    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)