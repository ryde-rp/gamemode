local radar = false

local function round(num)
    return tonumber(string.format("%.0f", num))
end

local function GetVehSpeed(veh)
    return GetEntitySpeed(veh) * 3.6
end

local function FormatSpeed(speed)
    return string.format("%03d", speed)
end

RegisterNetEvent("fp-toggleRadar", function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        return tvRP.notify("Poti deschide radarul doar cand esti in masina", "error")
    end

    radar = not radar;

    SendNUIMessage({
        act = "ToggleRadar",
        radar = radar
    })

    Citizen.CreateThread(function()
        while radar do
            Wait(100)

            local ped = PlayerPedId();
            local x, y, z = table.unpack(GetEntityCoords(ped))

            if (IsPedSittingInAnyVehicle(ped)) then
                local vehicle = GetVehiclePedIsIn(ped, false)

                if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                    local vehicleSpeed = round(GetVehSpeed(vehicle))

                    local coordA = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.0, 1.0)
                    local coordB = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 105.0, 0.0)
                    local frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, vehicle, 7)
                    local a, b, c, d, e = GetShapeTestResult(frontcar)

                    if IsEntityAVehicle(e) then
                        local model = GetDisplayNameFromVehicleModel(GetEntityModel(e))
                        local plate = GetVehicleNumberPlateText(e)
                        local herSpeedKm = GetEntitySpeed(e) * 3.6
                        local herSpeedMph = GetEntitySpeed(e) * 2.236936

                        SendNUIMessage({
                            act = "UpdateRadar",
                            model = model,
                            plate = plate,
                            speed = herSpeedKm,
                        })
                    end
                end
            else 
                radar = false
                SendNUIMessage({
                    act = "ToggleRadar",
                    radar = radar
                })
                break
            end
        end
    end)
end)