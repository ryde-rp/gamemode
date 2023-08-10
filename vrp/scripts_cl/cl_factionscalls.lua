local object = nil

RegisterNetEvent("vRP:openFactionCalls", function(calls, logo)
    local ped = tempPed
    loadAnimDict("amb@world_human_seat_wall_tablet@female@base")

    if not object then
        RequestModel("prop_cs_tablet")
        while not HasModelLoaded("prop_cs_tablet") do
            Wait(100)
        end

        local coords = GetEntityCoords(ped)
        local hand = GetPedBoneIndex(ped, 28422)

        object = CreateObject(GetHashKey("prop_cs_tablet"), coords, 1, 1, 1)
        AttachEntityToEntity(object, ped, hand, 0.0, 0.0, 0.03, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    end

    if not IsEntityPlayingAnim(ped, "amb@world_human_seat_wall_tablet@female@base", 'base', 3) then
        TaskPlayAnim(ped, "amb@world_human_seat_wall_tablet@female@base", 'base', 8.0, 1.0, -1, 49, 1.0, 0, 0, 0)
    end
    
    TriggerEvent("vRP:interfaceFocus", true)

    SendNUIMessage({
        act = "interface",
        target = "factionCalls",
        event = "show",
        calls = calls,
        logo = logo,
    })
end)

RegisterNetEvent("vRP:updateFactionCalls", function(calls)
    SendNUIMessage({
        act = "interface",
        target = "factionCalls",
        event = "update",
        calls = calls,
    })
end)

RegisterNUICallback('calls:take', function(data, callback)
    vRPserver.TakeApel({data.id, data.faction}, function(data)
        local coords = data.location
        if coords then
            SetNewWaypoint(coords[1], coords[2])
        end

        callback(data)
    end)
end)

RegisterNUICallback('calls:cancel', function(data, callback)
    vRPserver.CancelCall({data.id, data.faction}, function(data)
        callback(data)
    end)
end)

RegisterNUICallback("calls:setLocation", function(data, callback)
    local coords = data.location
    if coords then
        SetNewWaypoint(coords[1], coords[2])
    end
    
    callback("ok")
end)

RegisterNUICallback("calls:exit", function(data, cb)
    TriggerEvent("vRP:interfaceFocus", false)
    DeleteEntity(object)
    DetachEntity(object, 1, 1)
    ClearPedTasks(tempPed)
    object = nil

    cb("ok")
end)