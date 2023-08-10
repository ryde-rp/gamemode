function tvRP.gotoWaypoint()
  local targetPed = tempPed
  local targetVeh = GetVehiclePedIsUsing(targetPed)
  if(IsPedInAnyVehicle(targetPed))then
    targetPed = targetVeh
  end

  if(not IsWaypointActive())then
    tvRP.notify("Markerul nu a fost gasit.", "error")
    return
  end

  local waypointBlip = GetFirstBlipInfoId(8)
  local x,y,z = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector())) 

  local ground
  local groundFound = false

  for height = 0, 800, 2 do
    SetEntityCoordsNoOffset(targetPed, x,y,height+0.0001, 0, 0, 1)
    Citizen.Wait(10)

    ground,z = GetGroundZFor_3dCoord(x,y,height+0.0001)
    if(ground) then
      z = z + 1
      groundFound = true
      break;
    end
  end

  if(not groundFound)then
    z = 1000
    GiveDelayedWeaponToPed(PlayerPedId(), 0xFBAB5776, 1, 0)
  end

  SetEntityCoordsNoOffset(targetPed, x,y,z, 0, 0, 1)
  tvRP.notify("Te-ai teleportat la waypoint!", "success")
end

RegisterCommand("noclip", function()
  vRPserver.tryNoclipToggle({})
end)
RegisterKeyMapping("noclip", "Activeaza/dezactiveaza noclip", "keyboard", "F2")

RegisterNetEvent("vRP:adminAnnouncement")
AddEventHandler("vRP:adminAnnouncement", function(sender, message)
  SendNUIMessage({
    act = "interface",
    target = "adminAnnounce",

    admin = sender,
    text = message,
  })

  TriggerEvent("vRP:playAudio", "anuntadmin")
end)

local ncSpeeds = {0, 0.5, 2, 4, 6, 10, 20, 45}
local isInNoclip, ncIndex, entityInNoclip, isNoclipInv = false, 1, nil, false
function tvRP.toggleNoclip()
  local pedId = PlayerPedId()
  isInNoclip = not isInNoclip
  if isInNoclip then
    tvRP.notify("Ti-ai activat No-Clip!", "success")
  else
    tvRP.notify("Ti-ai dezactivat No-Clip!")
  end

  if IsPedInAnyVehicle(pedId, false) then
      entityInNoclip = GetVehiclePedIsIn(pedId, false)
  else
      entityInNoclip = pedId
  end

  SetEntityCollision(entityInNoclip, not isInNoclip, not isInNoclip)
  FreezeEntityPosition(entityInNoclip, isInNoclip)
  SetEntityInvincible(entityInNoclip, isInNoclip)
  SetVehicleRadioEnabled(entityInNoclip, not isInNoclip)

  if isNoclipInv then
      isNoclipInv = not isNoclipInv
      SetEntityVisible(entityInNoclip, not isNoclipInv, 0)
      if entityInNoclip ~= PlayerPedId() then
          SetEntityVisible(PlayerPedId(), not isNoclipInv, 0)
      end
  end
end

local canUseWeapon = true
function tvRP.toggleAllWeapons(state)
  canUseWeapon = state

  while not canUseWeapon do
    Citizen.Wait(1)
    tvRP.subtitleText("~HC_31~Un membru staff a dezactivat folosirea armelor")

    DisableControlAction(0,24,true)
    DisableControlAction(0,25,true)
    DisableControlAction(0,47,true)
    DisableControlAction(0,58,true)
    DisableControlAction(0,263,true)
    DisableControlAction(0,264,true)
    DisableControlAction(0,257,true)
    DisableControlAction(0,140,true)
    DisableControlAction(0,141,true)
    DisableControlAction(0,142,true)
    DisableControlAction(0,143,true)
  end
end

function tvRP.isNoclip()
  return isInNoclip
end

exports("isInNoclip", tvRP.isNoclip)

local function ButtonMessage(text)
  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform(text)
  EndTextCommandScaleformString()
end

local function setupScaleform(scaleform)

    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 289, true))
    ButtonMessage("Iesi din Noclip")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 85, true))
    ButtonMessage("Sus")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 48, true))
    ButtonMessage("Jos")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 34, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 35, true))
    ButtonMessage("Stanga / Dreapta")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 32, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 33, true))
    ButtonMessage("Fata / Spate")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 51, true))
    ButtonMessage("Vrei sa fi invizibil?")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 21, true))
    ButtonMessage("Viteza de mers ["..ncIndex.."]")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(100)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

CreateThread(function()
  local buttons = setupScaleform("instructional_buttons")
  local currentSpeed = tonumber(ncSpeeds[ncIndex])

  while true do
    Citizen.Wait(1000)
    
    while isInNoclip do
      Citizen.Wait(1)
      
      DrawScaleformMovieFullscreen(buttons)

      local yoff = 0.0
      local zoff = 0.0

      if IsControlJustPressed(1, 21) then             
          ncIndex = ncIndex + 1
          if ncIndex > #ncSpeeds then ncIndex = 1 end
          currentSpeed = tonumber(ncSpeeds[ncIndex])
          setupScaleform("instructional_buttons")
      end

      DisableControlAction(0, 23, true)
      DisableControlAction(0, 30, true)
      DisableControlAction(0, 31, true)
      DisableControlAction(0, 32, true)
      DisableControlAction(0, 33, true)
      DisableControlAction(0, 34, true)
      DisableControlAction(0, 35, true)
      DisableControlAction(0, 266, true)
      DisableControlAction(0, 267, true)
      DisableControlAction(0, 268, true)
      DisableControlAction(0, 269, true)
      DisableControlAction(0, 44, true)
      DisableControlAction(0, 20, true)
      DisableControlAction(0, 74, true)
      DisableControlAction(0, 75, true)

      if IsDisabledControlPressed(0, 32) then
          yoff = 0.5
      end

      if IsDisabledControlPressed(0, 33) then
          yoff = -0.5
      end

      if IsDisabledControlPressed(0, 34) then
          SetEntityHeading(entityInNoclip, GetEntityHeading(entityInNoclip)+2)
      end

      if IsDisabledControlPressed(0, 35) then
          SetEntityHeading(entityInNoclip, GetEntityHeading(entityInNoclip)-2)
      end

      if IsDisabledControlPressed(0, 85) then
          zoff = 0.2
      end

      if IsDisabledControlPressed(0, 48) then
          zoff = -0.2
      end

      if IsDisabledControlJustPressed(1, 51) then
          isNoclipInv = not isNoclipInv

          SetEntityVisible(entityInNoclip, not isNoclipInv, 0)
          if entityInNoclip ~= PlayerPedId() then
              SetEntityVisible(PlayerPedId(), not isNoclipInv, 0)
          end
      end

      local newPos = GetOffsetFromEntityInWorldCoords(entityInNoclip, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
      local heading = GetEntityHeading(entityInNoclip)
      SetEntityVelocity(entityInNoclip, 0.0, 0.0, 0.0)
      SetEntityRotation(entityInNoclip, 0.0, 0.0, 0.0, 0, false)
      SetEntityHeading(entityInNoclip, heading)
      SetEntityCoordsNoOffset(entityInNoclip, newPos.x, newPos.y, newPos.z, isInNoclip, isInNoclip, isInNoclip)
    end
  end
end)

local function DrawSprites(x,y,z, text, scl, stopWaiting) 
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

  if dist <= 15.0 or stopWaiting then
  
    local scale = scl
    if not stopWaiting then
      scale = (1/dist)*scl
      local fov = (1/GetGameplayCamFov())*100
      scale = scale*fov
    end
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(230, 0, 0, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
  elseif not stopWaiting then
    Citizen.Wait(500)
  end
end


local newSprites = false
RegisterNetEvent("vRP:showSprites", function()
    newSprites = not newSprites
    if newSprites then
        tvRP.notify("Ti-ai activat sprite-urile.", "info")
        Citizen.CreateThread(function()
            while newSprites do
                Citizen.Wait(1)
                for _, player in ipairs(GetActivePlayers()) do
                    if player ~= PlayerId() and GetPlayerServerId(player) ~= 0 then
                        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(player)))
                        local text = "~h~~w~SRC: "..GetPlayerServerId(player).." -~b~~h~ "..GetPlayerName(player)
                        DrawSprites(x, y, z + 1, text, 0.2, true)
                    end
                end
            end
        end)
    else
        tvRP.notify("Ti-ai dezactivat sprite-urile.", "info")
    end
end)

function tvRP.tptoWaypoint()
  tvRP.gotoWaypoint()
end

local isAdmin = false

RegisterNetEvent("vRP:setClientAdmin", function()
  isAdmin = true
end)

RegisterNetEvent("vRP:setTicketsAmm", function(numTickets)
  SendNUIMessage{
    act = "set-admin-tickets",
    isAdmin = isAdmin,
    count = numTickets,
  }
end)