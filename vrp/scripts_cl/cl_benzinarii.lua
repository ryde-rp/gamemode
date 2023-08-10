DecorRegister("customFuel", 1)
local gasStations = {
    vec3(49.4187, 2778.793, 58.043),
    vec3(263.894, 2606.463, 44.983),
    vec3(1039.958, 2671.134, 39.550),
    vec3(1207.260, 2660.175, 37.899),
    vec3(2581.321, 362.039, 108.468),
    vec3(2679.858, 3263.946, 55.240),
    vec3(2005.055, 3773.887, 32.403),
    vec3(1687.156, 4929.392, 42.078),
    vec3(1701.314, 6416.028, 32.763),
    vec3(179.857, 6602.839, 31.868),
    vec3(-94.4619, 6419.594, 31.489),
    vec3(-2554.996, 2334.40, 33.078),
    vec3(-1800.375, 803.661, 138.651),
    vec3(-1437.622, -276.747, 46.207),
    vec3(-2096.243, -320.286, 13.168),
    vec3(-724.619, -935.1631, 19.213),
    vec3(-526.019, -1211.003, 18.184),
    vec3(-70.2148, -1761.792, 29.534),
    vec3(265.648, -1261.309, 29.292),
    vec3(819.653, -1028.846, 26.403),
    vec3(1208.951, -1402.567, 35.224),
    vec3(1181.381, -330.847, 69.316),
    vec3(620.843, 269.100, 103.089),
    vec3(-66.443321228028, -2532.1376953125, 6.1356973648072),
    vec3(2539.3547363282, 2594.62109375, 37.94486618042),
    -- vec3(175.20892333984, -1562.2717285156, 29.264505386352),
    vec3(2521.4465332032, 4196.818359375, 39.947662353516),
    vec3(1361.2163085938, 3596.671875, 34.899726867676),
    vec3(1785.4904785156, 3330.7272949218, 41.613903045654),
    vec3(15.390856742859, -2786.044921875, 2.5259523391724), 
    vec3(5017.8198242188, -5195.3803710938, 2.6709997653962),
    vec3(-764.3374633789,-1434.904296875,5.0577268600464),
}

local thePumps = {-2007231801, 1339433404, 1694452750, 1933174915, -462817101, -469694731, -164877493}
local usageData = {
    [0] = 0.8, --0: Compacts + overwrite starting index
    0.6, --1: Sedans
    0.8, --2: SUVs
    0.6, --3: Coupes
    0.8, --4: Muscle
    0.8, --5: Sports Classics
    0.8, --6: Sports
    1.0, --7: Super
    1.0, --8: Motorcycles
    0.8, --9: Off-road
    0.8, --10: Industrial
    0.8, --11: Utility
    0.8, --12: Vans
    0, --13: Cycles
    0.4, --14: Boats
    1.3, --15: Helicopters
    0, --16: Planes
    0.8, --17: Service
    0.8, --18: Emergency
    0.8, --19: Military
    0.8, --20: Commercial
    0.8, --21: Trains
}

local function changeFuel(veh, change)
    if change < 0 then
        change = 0
    elseif change > 100 then
        change = 100
    end

    SetVehicleFuelLevel(veh, change + 0.0)
    DecorSetFloat(veh, "customFuel", change)
end

Citizen.CreateThread(function()
    while true do
        local ticks = 5000
        if (GVEHICLE ~= 0) then
            ticks = 1

            local vehicle = GVEHICLE
            if DoesEntityExist(vehicle) then
                local fuel = GetVehicleFuelLevel(vehicle)

                DecorSetFloat(vehicle, 'customFuel', fuel)
            
                if GetIsVehicleEngineRunning(vehicle) and (GetPedInVehicleSeat(vehicle, -1) == tempPed) and fuel ~= 0 then
                    changeFuel(vehicle, fuel - (0.0037037037 * usageData[GetVehicleClass(vehicle)] * 0.2))
                end
            end
        end

        Wait(ticks)
    end
end)

Citizen.CreateThread(function()
    for stationId, stationCoords in pairs(gasStations) do
        tvRP.createBlip(("vRPfuel:stationBlip-%d"):format(stationId), stationCoords.x, stationCoords.y, stationCoords.z, 361, 79, "Benzinarie", 0.4)
    end

    while true do
        local ticks = 1500
        local vehicle = GetPlayersLastVehicle(tempPed)
        local vehCoords = GetEntityCoords(vehicle)

        local dist = #(vehCoords - pedPos)
        local nearFuelStation = false

        if (GVEHICLE == 0) and dist <= 6.0 then
            for _, pumpModel in pairs(thePumps) do
                local closestPump = GetClosestObjectOfType(pedPos, 1.5, pumpModel, false, false)

                if closestPump ~= 0 then
                    ticks = 1

                    local coords = GetEntityCoords(closestPump)
                    DrawText3D(coords.x, coords.y, coords.z + 1.0, "Pret: ~g~$500~n~~b~E~w~ - Alimenteaza vehicul~n~~b~G~w~ - Umple canistra", 0.9)

                    if IsControlJustReleased(0, 51) then
                        if not tvRP.isInComa() then
                            TriggerServerEvent("uVeh$startRefuel", GetVehicleFuelLevel(vehicle))
                        end
                    end

                    if IsControlJustReleased(0, 47) then
                        if not tvRP.isInComa() then
                    	   vRPserver.cumparaCanistra{}
                        end
                    end
                end
            end
        else
            for _, pumpModel in pairs(thePumps) do
                local closestPump = GetClosestObjectOfType(pedPos, 1.5, pumpModel, false, false)

                if closestPump ~= 0 then
                    ticks = 1

                    local coords = GetEntityCoords(closestPump)
                    DrawText3D(coords.x, coords.y, coords.z + 1.0, "Pret: ~g~$1800~n~~b~E~w~ - Umple canistra", 0.9)

                    if IsControlJustReleased(0, 51) then
                        if not tvRP.isInComa() then
                            vRPserver.cumparaCanistra{}
                        end
                    end
                end
            end
        end

        Wait(ticks)
    end
end)

RegisterNetEvent("uVeh$fuelVehicle", function(much)
    if tvRP.isInComa() then
        return
    end
    
    Citizen.CreateThread(function()
        SetCurrentPedWeapon(tempPed, -1569615261, true) -- weapon_unarmed
        RequestAnimDict("timetable@gardener@filling_can")

        while not HasAnimDictLoaded("timetable@gardener@filling_can") do
            Citizen.Wait(1)
        end

        TaskPlayAnim(tempPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    end)

    local vehicle = GetPlayersLastVehicle(tempPed)
    local fuel = tonumber(GetVehicleFuelLevel(vehicle))
    local amount = tonumber(much) + tonumber(GetVehicleFuelLevel(vehicle))

    FreezeEntityPosition(tempPed, true)
    FreezeEntityPosition(vehicle, false)

    if amount > 100 then amount = 100 end

    while tonumber(fuel) <= amount do
        if tonumber(fuel) >= 100 then
            break
        end

        TriggerEvent("vRP:progressBar", {
            duration = 500,
            text = "⛽ Alimentezi vehiculul..",
        })

        fuel = tonumber(GetVehicleFuelLevel(vehicle))

        changeFuel(vehicle, fuel + 1)
        Citizen.Wait(600)
    end


    Citizen.Wait(100)
    FreezeEntityPosition(tempPed, false)
    ClearPedTasksImmediately(tempPed)
end)

RegisterNetEvent("fuel$folosesteCanistra", function()
    if tvRP.isInComa() then
        return
    end

    local vehicle = tvRP.getVehicleInDirection(GetEntityCoords(tempPed, 1), GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 2.0, 0.0))
    if (DoesEntityExist(vehicle)) then
        local fuel = tonumber(GetVehicleFuelLevel(vehicle))
        local amount = (100 - fuel) + fuel

        FreezeEntityPosition(tempPed, true)
        FreezeEntityPosition(vehicle, false)
        
        local animDict = "weapon@w_sp_jerrycan"
        local animName = "fire"
        
        RequestModel(GetHashKey("prop_ld_jerrycan_01"))
        while not HasModelLoaded(GetHashKey("prop_ld_jerrycan_01")) do
            Citizen.Wait(1)
        end

        ClearPedSecondaryTask(tempPed)
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(1)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 0.0, -5.0)
        local canObj = CreateObject(GetHashKey("prop_ld_jerrycan_01"), plyCoords, 1, 0, 0)

        TaskPlayAnim(tempPed, animDict, animName, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
        AttachEntityToEntity(canObj, tempPed, GetPedBoneIndex(tempPed, 28422), 0.09, 0.0, 0.0, 0.0, 270.0, 0.0, 1, 1, 0, 1, 0, 1)
        
        if amount > 100 then amount = 100 end

        while tonumber(fuel) <= amount do
            if tonumber(fuel) >= 100 then
                break
            end

            TriggerEvent("vRP:progressBar", {
                duration = 500,
                text = "⛽ Alimentezi vehiculul..",
            })

            fuel = tonumber(GetVehicleFuelLevel(vehicle))

            changeFuel(vehicle, fuel + 1)
            Citizen.Wait(600)
        end

        Citizen.Wait(100)
        ClearPedSecondaryTask(tempPed)
        DeleteEntity(canObj)

        FreezeEntityPosition(tempPed, false)
    end
end)

exports("changeFuel", changeFuel)