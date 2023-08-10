local function setData(uMoney, uBankMoney, uCoins)
    Wait(500)
    SendNUIMessage{
		act = "event",
		event = "setHudData",
		cash = uMoney,
		bank = uBankMoney,
		coins = uCoins,
	}
end

RegisterNetEvent("fp-hud:setData", setData)

local uHungerData = 0
local uThirstData = 0

RegisterNetEvent("fp-hud:setDependencies", function(uThirst, uHunger)
    uHungerData = math.ceil(100 - uHunger)
    uThirstData = math.ceil(100 - uThirst)
end)

AddEventHandler("pma-voice:setTalkingMode", function(theLevel)
    SendNUIMessage({
        act = "event",
        event = "setVoiceLevel",
        lvl = theLevel,
    })
end)

local wasHudHidden = true
local hudHidden = false
RegisterNetEvent("ui$hideMainElement", function(state)
    hudHidden = state
    if hudHidden then
        wasHudHidden = true
    end

    if state then
      SendNUIMessage{
        act = "event",
        event = "openMap",
        state = false,
      }
    end
end)

RegisterNetEvent("ui$hideUserElement", function(state)
    hudHidden = state
    if hudHidden then
        wasHudHidden = true
    end
    
    SendNUIMessage{
        act = "event",
        event = "setUInterfaceState",
        state = not state,
    }
end)

CreateThread(function()
  while true do
    Wait(500)

    SendNUIMessage{
        act = "event",
        event = "setDependenciesData",
        thirst = tonumber(uThirstData),
        hunger = tonumber(uHungerData),
        armour = tonumber(GetPedArmour(tempPed)) or 0,
        health = tonumber(GetEntityHealth(tempPed) - 100),
        talking = NetworkIsPlayerTalking(tempPlayer),
    }

    while IsPauseMenuActive() do
      wasHudHidden = true
      
      SendNUIMessage{
        act = "event",
        event = "openMap",
        state = false,
      }
      Wait(100)
    end

    if wasHudHidden then
        SendNUIMessage{
            act = "event",
            event = "openMap",
            state = true,
        }

        wasHudHidden = false
    end
  end
end)

CreateThread(function()
    while true do
        local var1, var2 = GetStreetNameAtCoord(pedPos.x, pedPos.y, pedPos.z)
        local secondStreet = GetStreetNameFromHashKey(var1)
        local theStreet = GetStreetNameFromHashKey(var2)

        if secondStreet:len() < 2 then
            secondStreet = "Necunoscută"
        elseif theStreet:len() < 2 then
            theStreet = "Necunoscută"
        end

        SendNUIMessage({
            act = "event",
            event = "setDisplayLocation",
            firstStreet = theStreet,
            secondStreet = secondStreet,
            onlinePlayers = onlinePlayers,
        })

        Wait(2000)
    end
end)

local speedometer = false
CreateThread(function()
    while true do
        Wait(500)
        if GVEHICLE ~= 0 and (GetPedInVehicleSeat(GVEHICLE, -1) == tempPed) then
            if not speedometer then
                SendNUIMessage({
                    act = "setSpeedoData",
                    speedoShown = true,
                })
                speedometer = true
            end
        else
            if speedometer then
                SendNUIMessage({
                    act = "setSpeedoData",
                    speedoShown = false,
                })
                speedometer = false
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        while GVEHICLE ~= 0 do

            local vehicle = GVEHICLE
            if DoesEntityExist(vehicle) and speedometer then
                local carSpeed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
                local carGEAR = GetVehicleCurrentGear(vehicle)
                local carOdometer = ("%.2f"):format((DecorGetFloat(vehicle, "FairPlay_vehkm") or 0) / 1000)
                local fuel = math.floor(GetVehicleFuelLevel(vehicle) + 0.0)
                local _, lights, highbeams = GetVehicleLightsState(vehicle)

                local openedOne = false
                for i=0, GetNumberOfVehicleDoors(vehicle) do
                    if GetVehicleDoorAngleRatio(vehicle, i) > 0.0 then
                        openedOne = true
                        break
                    end
                end

                SendNUIMessage({
                	act = "setSpeedoData",
                	speedoShown = true,
                	speed = carSpeed,
                	tank = fuel,
                    gear = carGEAR,
                    odometer = carOdometer,
                    seatbelt = carBelt,
                    vehicleon = IsVehicleEngineOn(vehicle),
                    lights = (lights > 0) or (highbeams > 0),
                    doors = openedOne,
                })
            end

            Citizen.Wait(50)
        end

        Citizen.Wait(100)
    end
end)

AddEventHandler("getOnlinePly", function(amm)
    amm = amm.." / "..GetConvarInt("sv_maxclients", 512)
    SendNUIMessage({
        act = "UpdatePlayerCount",
        onlinePlayers = amm,
    })
end)

RegisterNetEvent("vRP:setClientId", function(id)
    SendNUIMessage({
        act = "SetUserId",
        userId = id,
    })
end)


RegisterNetEvent("FP:ToggleHud", function(type, state)
    if type == "radar" then
        DisplayRadar(state)
        SendNUIMessage({
            act = "ToggleHud",
            type = "radar",
            state = state,
        })
    else
        SendNUIMessage({
            act = "ToggleHud",
            type = type,
            state = state,
        })
    end
end)

local HudRunning = false;
RegisterNUICallback("aditionalHudState", function(data, cb)
    HudRunning = data.running
end)

local additionalHud = true
RegisterCommand("+viewAdditionalHud", function()
    additionalHud = true
    if HudRunning then return end;
    loadAnimDict("amb@code_human_wander_idles@male@idle_a")
    TaskPlayAnim(tempPed, "amb@code_human_wander_idles@male@idle_a", "idle_a_wristwatch", 8.0, 8.0, -1, 48, 0, false, false, false)

    CreateThread(function()
        while additionalHud do
            DisablePlayerFiring(tempPlayer, true)
            Wait(1)
        end

        DisablePlayerFiring(tempPlayer, false)
    end)
    
    SendNUIMessage{
        act = "switchAdditionalHud",
        on = additionalHud,
    }
end)

RegisterCommand("-viewAdditionalHud", function()
    additionalHud = false
    tvRP.stopAnim()

    SendNUIMessage{
        act = "switchAdditionalHud"
    }
end)

RegisterKeyMapping("+viewAdditionalHud", "Vezi informatii despre caracter", "keyboard", "F1")