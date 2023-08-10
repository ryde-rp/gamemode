
local cantShuffle, fixEvent = true, false

local function setShuffleState(x)
  cantShuffle = x
end

AddEventHandler("gameEventTriggered", function(name, args)
  if name == "CEventNetworkPlayerEnteredVehicle" then
    if fixEvent then
      return
    end

    fixEvent = true
    Citizen.CreateThread(function()
      while IsPedInAnyVehicle(tempPed, false) and cantShuffle do
        local veh = GVEHICLE
        if veh ~= 0 then
          if GetPedInVehicleSeat(veh, 0) == tempPed then
            if GetIsTaskActive(tempPed, 165) then
              SetPedIntoVehicle(tempPed, veh, 0)
            end
          end
        end

        Wait(1)
      end
    end)

    fixEvent = false
  end
end)

RegisterCommand("shuff", function()
  if GVEHICLE ~= 0 then
    setShuffleState(false)

    Wait(5000)
    setShuffleState(true)
  end
end)