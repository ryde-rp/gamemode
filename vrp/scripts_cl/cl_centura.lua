carBelt = false
local wasInCar = false
local speedBuffer = {0.0, 0.0}

local function IsCar(veh)
  if wasInCar then
    return true
  end
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end 

local function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

 
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)

    local ped = tempPed
    local car = GVEHICLE

    if car ~= 0 then
      if IsCar(car) then
        wasInCar = true

        if carBelt then DisableControlAction(0, 75) end
          speedBuffer[2] = speedBuffer[1]
          speedBuffer[1] = GetEntitySpeed(car)

          if speedBuffer[2] ~= nil and GetEntitySpeedVector(car, true).y > 1.0 and speedBuffer[1] > 19.25 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then

            TriggerEvent("carCrashEffect")
            if not carBelt then
              local co = GetEntityCoords(ped)
              local fw = Fwv(ped)
              SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
              SetEntityVelocity(ped, GetEntityVelocity(car))
              Citizen.Wait(1)
              SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            end
        end
      elseif wasInCar then
        wasInCar = false
        carBelt = false
        speedBuffer[1], speedBuffer[2] = 0.0, 0.0
      else
        Citizen.Wait(2000)
      end
    elseif wasInCar then
      wasInCar = false
      carBelt = false
      speedBuffer[1], speedBuffer[2] = 0.0, 0.0
    else
      Citizen.Wait(2000)
    end

  end
end)

function tvRP.isInSeatbelt()
	return carBelt
end 

local blockedVehs = {
  [8] = "Motorcycles",
  [21] = "Trains",
}

RegisterCommand("switchseatbelt", function()
  Wait(500)
  
  if (GVEHICLE ~= 0) and not blockedVehs[GetVehicleClass(GVEHICLE)] then

    carBelt = not carBelt

    if carBelt then
      tvRP.notify("Ti-ai pus centura!", "info", false, "fas fa-car")
      return
    end

    tvRP.notify("Ti-ai scos centura!", "warning", false, "fas fa-car")
  end
end)

RegisterKeyMapping("switchseatbelt", "Pune/scoate centura", "keyboard", "G")