
local inExamination = {}

RegisterServerEvent("vrp-dmv:tryPassingTest", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if vRP.tryPayment(user_id, 100, true) then
        TriggerClientEvent("vrp-dmv:openExaminationMenu", player)
        inExamination[user_id] = "test"
    end
end)

local drivingCoords = vector3(-951.97711181641,-182.73062133789,37.091354370117)

local schoolCoords = {424.24716186523,-978.607421875,30.711385726929}

RegisterServerEvent("vrp-dmv:updateExamination", function(state)
    local player = source
    local ped = GetPlayerPed(player)
    local user_id = vRP.getUserId(player)

    if state and inExamination[user_id] then

        if type(inExamination[user_id]) == "string" then
            local veh = vRP.spawnVehicle(GetHashKey("emperor2"), drivingCoords, GetEntityHeading(ped), true, true)

            inExamination[user_id] = veh

            Citizen.SetTimeout(500, function()
                SetEntityHeading(veh, 220.0)
                SetPedIntoVehicle(ped, veh, -1)
                SetEntityRoutingBucket(veh, tonumber(GetPlayerRoutingBucket(player)))

                TriggerClientEvent("vrp-dmv:startDriving", player, NetworkGetNetworkIdFromEntity(veh))
            end)
        end
    else
        vRPclient.notify(player, {"Din pacate nu ai reusit sa treci testul teoretic.", "error"})
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if inExamination[user_id] then
        inExamination[user_id] = nil
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        local rows = exports.oxmysql:querySync("SELECT dmvTest FROM users WHERE id = @id", {['@id'] = user_id})
        if #rows > 0 then
            if first_spawn and rows[1].dmvTest then
                tmp.dmv = false
            end

            Citizen.Wait(500)
            if tmp.dmv then
                vRP.setInventoryItemAmount(user_id, "drivingLicense", 1)
            end
        end
    end
end)

RegisterServerEvent("vrp-dmv:finishExamination", function()

    local player = source
    local user_id = vRP.getUserId(player)

    if type(inExamination[user_id]) == "number" then
        local tmp = vRP.getUserTmpTable(nuser_id)

        exports.oxmysql:execute("UPDATE users SET dmvTest = @dmvTest WHERE id = @id",{
            ['@id'] = user_id,
            ['@dmvTest'] = 1
        })

        if tmp then
            tmp.dmv = true
        end

        vRP.setInventoryItemAmount(user_id, "drivingLicense", 1)
        vRPclient.notify(player, {"Felicitari, ai obtinut permisul de conducere!", "info"})
        vRPclient.teleport(player, schoolCoords)


        if DoesEntityExist(inExamination[user_id]) then
            DeleteEntity(inExamination[user_id])
        end

        inExamination[user_id] = nil
    end

end)