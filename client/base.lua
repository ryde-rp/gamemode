tvRP = {}
Tunnel.bindInterface("vRP",tvRP)

Proxy.addInterface("vRP",tvRP)
vRPserver = Tunnel.getInterface("vRP","vRP")

cfg = module("cfg/client")

tempPed = PlayerPedId()
tempPlayer = PlayerId()
pedPos = GetEntityCoords(tempPed)
GVEHICLE = GetVehiclePedIsIn(tempPed)
GSWIMMING = IsPedSwimming(tempPed)

Citizen.CreateThread(function()
  Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), 'FE_THDR_GTAO', '~b~RYDE ~w~ROMANIA - ~w~RYDE-RP.COM')

  -- 1.0, 1.0 -> out of range
  SetHudComponentPosition(3, 1.0, 1.0)
  SetHudComponentPosition(4, 1.0, 1.0)
  SetHudComponentPosition(6, 1.0, 1.0)
  SetHudComponentPosition(7, 1.0, 1.0)
  SetHudComponentPosition(8, 1.0, 1.0)
  SetHudComponentPosition(9, 1.0, 1.0)
  SetHudComponentPosition(13, 1.0, 1.0)

  SetWeaponDamageModifier(GetHashKey("WEAPON_UNARMED"), 0.5) 
  SetWeaponDamageModifier(GetHashKey("WEAPON_FLASHLIGHT"), 0.1)
  SetWeaponDamageModifier(GetHashKey("WEAPON_NIGHTSTICK"), 0.2)
  
  SetMapZoomDataLevel(0, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 0
  SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
  SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
  SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
  SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
  SetRadarZoom(950)

  while true do
    tempPed = PlayerPedId()
    tempPlayer = PlayerId()
    pedPos = GetEntityCoords(tempPed)
    GVEHICLE = GetVehiclePedIsIn(tempPed)
    GSWIMMING = IsPedSwimming(tempPed) or IsPedSwimmingUnderWater(tempPed)

    Citizen.Wait(100)
  end
end)

Citizen.CreateThread(function()
  Wait(2000)
  RequestStreamedTextureDict("squaremap", false)
  while not HasStreamedTextureDictLoaded("squaremap") do
    Wait(50)
  end

  local defaultAspectRatio = 1920/1080 -- Don't change this.
  local resolutionX, resolutionY = GetActiveScreenResolution()
  local aspectRatio = resolutionX/resolutionY
  local minimapOffset = 0
  if aspectRatio > defaultAspectRatio then
    minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
  end

  SetMinimapClipType(0)
  AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
  AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
  SetMinimapComponentPosition("minimap", "L", "B", 0.002+minimapOffset, -0.007, 0.1638, 0.183)
  SetMinimapComponentPosition("minimap_mask", "L", "B", 0.2+minimapOffset, 0.0, 0.065, 0.20)
  SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01+minimapOffset, 0.065, 0.262, 0.300)
  SetBlipAlpha(GetNorthRadarBlip(), 0)

  local minimap = RequestScaleformMovie("minimap")
  SetRadarBigmapEnabled(true, false)
  Wait(0)
  SetRadarBigmapEnabled(false, false)

  while true do
    Wait(100)
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
    SetRadarBigmapEnabled(false, false)    
    SetRadarZoom(1100)
  end
end)

Citizen.CreateThread(function()
  while true do
    if IsPedArmed(tempPed, 6) then
      DisableControlAction(1, 140, true)
      DisableControlAction(1, 141, true)
      DisableControlAction(1, 142, true)
    end

    DisablePlayerVehicleRewards(tempPlayer)

    Citizen.Wait(1)
  end
end)

Citizen.CreateThread(function()
  for i = 1, 12 do
      EnableDispatchService(i, false)
  end

  local updateRatio = false
  Citizen.CreateThread(function() Citizen.Wait(5000) updateRatio = true end)

  while true do
    SetPlayerWantedLevel(tempPlayer, 0, false)
    SetPlayerWantedLevelNow(tempPlayer, false)

    RemoveAllPickupsOfType(0xDF711959) -- Rifle
    RemoveAllPickupsOfType(0xF9AFB48F) -- Pistol
    RemoveAllPickupsOfType(0xA9355DCD) -- Shotgun
    RemoveAllPickupsOfType(`PICKUP_ARMOUR_STANDARD`)

    SetPlayerWantedLevelNoDrop(tempPlayer, 0, false)

    if updateRatio then
      local aspect = GetAspectRatio(0)
      SendNUIMessage({
        act = 'setAspectRatio',
        aspect = string.format("%.1f", aspect)
      })
    end

    Citizen.Wait(2000)
  end
end)

Citizen.CreateThread(function()
  while true do
    SetVehicleDensityMultiplierThisFrame(0.0)
    SetPedDensityMultiplierThisFrame(0.0) 
    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)
    SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    
    local x,y,z = pedPos.x, pedPos.y, pedPos.z
    ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
    RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
    Citizen.Wait(25)
  end
end)

function tvRP.teleport(x,y,z)
  SetEntityCoords(tempPed, x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  vRPserver.updatePos({x,y,z})
end

function tvRP.getPosition()
  local x,y,z = table.unpack(GetEntityCoords(tempPed))
  return x,y,z
end

function tvRP.calcPositionDist(coords)
  return #(coords - pedPos)
end

function tvRP.getPositionWithArea()
  local x,y,z = table.unpack(GetEntityCoords(tempPed))

  local theZone, _ = GetStreetNameAtCoord(x, y, z)
  local theStreet = GetStreetNameFromHashKey(theZone)

  return {coords = {x,y,z}, zone = theStreet}
end

function tvRP.isInside()
  local x,y,z = tvRP.getPosition()
  return not (GetInteriorAtCoords(x,y,z) == 0)
end

function tvRP.getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(tempPed))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function tvRP.isFalling()
  return IsPedFalling(tempPed) or IsPedInParachuteFreeFall(tempPed)
end

function tvRP.formatMoney(amount)
  local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function tvRP.getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(tempPed)
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function tvRP.washMyCar()
  local veh = GetVehiclePedIsIn(tempPed, false)
  if IsEntityAVehicle(veh) then
    Citizen.CreateThread(function()
      SetVehicleDirtLevel(veh, 0.0)
      SetVehicleUndriveable(veh, false)

      tvRP.notify("Ti-ai spalat masina!", "success")
    end)
  else
    tvRP.notify("Trebuie sa fii intr-o masina!", "error")
  end
end

tvRP.user_cdata = {}
function tvRP.setCData(dkey, dvalue)
  tvRP.user_cdata[dkey] = dvalue
end

function tvRP.setCDataVar(dkey, vkey, vvalue)
  local dvalue = tvRP.getCData(dkey)

  if dvalue then
    dvalue[vkey] = vvalue
  else
    tvRP.setCData(dkey, {[vkey] = vvalue})
  end
end

function tvRP.getCData(dkey)
  return tvRP.user_cdata[dkey]
end

function tvRP.getCDataVar(dkey, vkey)
  local dvalue = tvRP.getCData(dkey) or {}

  if dvalue then
    return dvalue[dkey][vkey]
  end
end

function tvRP.getPlayersInCoords(x, y, z, radius)
  local r = {}

  for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      local px,py,pz = table.unpack(GetEntityCoords(ped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
  end

  return r
end

function tvRP.getNearestPlayers(radius)
  local r = {}

  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

  for _, player in ipairs(GetActivePlayers()) do
    if player ~= pid then
      local ped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(ped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

function tvRP.getNearestPlayer(radius)
  local p = nil

  local plys = tvRP.getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(plys) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end

function tvRP.playScreenEffect(name, duration)
  if duration < 0 then -- loop
    StartScreenEffect(name, 0, true)
  else
    StartScreenEffect(name, 0, true)

    Citizen.CreateThread(function()
      Citizen.Wait(math.floor((duration+1)*1000))
      StopScreenEffect(name)
    end)
  end
end

function tvRP.stopScreenEffect(name)
  StopScreenEffect(name)
end

local anims = {}
local anim_ids = Tools.newIDGenerator()
local inAnim = false

function loadAnimDict(dict)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(1)
  end

  return true
end

function tvRP.playAnim(upper, seq, looping)
  Citizen.CreateThread(function()
      Citizen.Wait(250)
      Citizen.CreateThread(function()
        while inAnim do
          DisableControlAction(0, 37, false)
          Citizen.Wait(1)
        end
      end)
      Citizen.Wait(15000)
      inAnim = false
  end)
  if seq.task ~= nil then -- is a task (cf https://github.com/ImagicTheCat/vRP/pull/118)
    tvRP.stopAnim(true)

    inAnim = true
    

    local ped = tempPed
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local x,y,z = tvRP.getPosition()
      TaskStartScenarioAtPosition(ped, seq.task, x, y, z-1, GetEntityHeading(ped), 0, 0, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    tvRP.stopAnim(upper)

    inAnim = true

    local flags = 0
    if upper then flags = flags+48 end
    if looping then flags = flags+1 end

    Citizen.CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = anim_ids:gen()
      anims[id] = true

      for k,v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i=1,loops do
          if anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local i = 0
            while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
              Citizen.Wait(10)
              RequestAnimDict(dict)
              i = i+1
            end

            -- play anim
            if HasAnimDictLoaded(dict) and anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end

              TaskPlayAnim(tempPed,dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
            end

            Citizen.Wait(0)
            while GetEntityAnimCurrentTime(tempPed,dict,name) <= 0.95 and IsEntityPlayingAnim(tempPed,dict,name,3) and anims[id] do
              Citizen.Wait(0)
            end
          end
        end
      end

      -- free id
      anim_ids:free(id)
      anims[id] = nil
    end)
  end
end

local canStopAnim = false
function tvRP.setCanStop(set)
  canStopAnim = not set
end

function tvRP.isInAnim()
  return inAnim
end

function tvRP.stopAnim(upper)
  anims = {} -- stop all sequences
  if not importantAnim then
    inAnim = false
    if upper then
      ClearPedSecondaryTask(tempPed)
    else
      ClearPedTasks(tempPed)
    end
  else
    tvRP.notify("Nu poti oprii aceasta animatie.", "error")
  end
end

local ragdoll = false

function tvRP.setRagdoll(flag)
  ragdoll = flag
end

function tvRP.setRagdoll(flag)
  ragdoll = flag
  Citizen.CreateThread(function()
      while ragdoll do
        SetPedToRagdoll(tempPed, 1000, 1000, 0, 0, 0, 0)
        Citizen.Wait(200)
      end
  end)
end

-- SOUND
-- some lists: 
-- pastebin.com/A8Ny8AHZ
-- https://wiki.gtanet.work/index.php?title=FrontEndSoundlist

-- play sound at a specific position
function tvRP.playSpatializedSound(dict,name,x,y,z,range)
  PlaySoundFromCoord(-1,name,x+0.0001,y+0.0001,z+0.0001,dict,0,range+0.0001,0)
end

function tvRP.playSound(dict,name)
  PlaySound(-1,name,dict,0,0,1)
end

function tvRP.deleteEntity(entity)
  if DoesEntityExist(entity) then
    DeleteObject(entity)
  end
end

function tvRP.deleteVehicle(veh)
  if DoesEntityExist(veh) then
    DeleteEntity(veh)

    if IsEntityAMissionEntity(veh) then
      DeleteVehicle(veh)
    end
  end
end

function tvRP.getVehicleInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end

function tvRP.getVehicleInFront()
    local pos = pedPos
    local entityWorld = GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 5.0, 0.0)
    
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, tempPed, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)

    return result
end

function tvRP.deleteVehicleInFront()
  local ped = GetPlayerPed(-1)
  local entity = nil

  if (IsPedSittingInAnyVehicle(ped)) then 
    entity = GetVehiclePedIsIn(ped, false)
  else
    entity = tvRP.getVehicleInDirection(GetEntityCoords(ped, 1), GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0))
  end
  
  NetworkRequestControlOfEntity(entity)
  
  local timeout = 2000
  while timeout > 0 and not NetworkHasControlOfEntity(entity) do
      Citizen.Wait(100)
      timeout = timeout - 100
  end

  SetEntityAsMissionEntity(entity, true, true)
  
  local timeout = 2000
  while timeout > 0 and not IsEntityAMissionEntity(entity) do
      Citizen.Wait(100)
      timeout = timeout - 100
  end

  if DoesEntityExist(entity) then
      Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
  end

  Citizen.Wait(50)

  if DoesEntityExist(entity) then 
    DeleteEntity(entity)
  end

  return DoesEntityExist(entity)
end

function tvRP.deleteNearestVehicle(radius)
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  local veh = tvRP.getNearestVehicle(radius)
  if not DoesEntityExist(veh) then
    return false
  end
  
  if IsEntityAVehicle(veh) then
    SetVehicleHasBeenOwnedByPlayer(veh,false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
  end

  local deletedOne = false
  if DoesEntityExist(veh) then
    deletedOne = not tvRP.deleteVehicleInFront()
  else
    deletedOne = true
  end

  return deletedOne
end

function tvRP.fixCar()
  local playerPed = PlayerPedId()
  if IsPedInAnyVehicle(playerPed) then
    local vehicle = GetVehiclePedIsIn(playerPed)
    SetVehicleEngineHealth(vehicle, 9999)
    SetVehiclePetrolTankHealth(vehicle, 9999)
    SetVehicleFixed(vehicle)

    return true
  end

  return false
end

function tvRP.flipVehicle()
  local theVehicle = tvRP.getNearestVehicle(3.5)

  if theVehicle then
    SetVehicleOnGroundProperly(theVehicle)
  end
end

function tvRP.executeCommand(command)
  ExecuteCommand(command)
end

function tvRP.doesModelExist(model)
  return IsModelInCdimage(model)
end

function tvRP.spawnCar(model, coords, heading, keepOutPed)
    local i = 0
    local mhash = GetHashKey(model)
    while not HasModelLoaded(mhash) and i < 1000 do
      RequestModel(mhash)
      Citizen.Wait(30)
      i = i + 1
    end

    if HasModelLoaded(mhash) then
      local nveh = CreateVehicle(mhash, (coords or pedPos), (heading and (heading + 0.0) or GetEntityHeading(tempPed)), true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      
      if not keepOutPed then
        SetPedIntoVehicle(tempPed,nveh,-1)
      end

      Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true)
      SetVehicleHasBeenOwnedByPlayer(nveh,true)
      SetModelAsNoLongerNeeded(mhash)
      return nveh
  end
end

function tvRP.repairVehicle()
  local playerPed = tempPed
  if (GVEHICLE == 0) then
    local vehicle = GVEHICLE
    SetVehicleEngineHealth(vehicle, 9999)
    SetVehiclePetrolTankHealth(vehicle, 9999)
    SetVehicleFixed(vehicle)
    return true
  else
    return false
  end
end

local onCayo = false
local cayoLocation = vector3(4840.571, -5174.425, 2.0)
local function loadCayoPerico()
    SetDeepOceanScaler(0.0)
    while true do
      local dst = #(cayoLocation - pedPos)
      if dst <= 1900 then
          Citizen.InvokeNative(0x9A9D1BA639675CF1, "HeistIsland", true)
          Citizen.InvokeNative(0x5E1460624D194A38, true)
          Citizen.InvokeNative(0xF74B1FFA4A15FBEA, true)
          Citizen.InvokeNative(0x53797676AD34A9AA, false)
          SetAudioFlag('PlayerOnDLCHeist4Island', true)
          SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
          SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
          onCayo = true
      else
          Citizen.InvokeNative(0x9A9D1BA639675CF1, "HeistIsland", false)
          Citizen.InvokeNative(0x5E1460624D194A38, false)
          Citizen.InvokeNative(0xF74B1FFA4A15FBEA, false)
          Citizen.InvokeNative(0x53797676AD34A9AA, true)  
          SetAudioFlag('PlayerOnDLCHeist4Island', false)
          SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', false, false)
          SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, false)
          onCayo = false
      end
      Citizen.Wait(1500)

      while IsPauseMenuActive() do 
        Citizen.Wait(1)
        SetRadarAsExteriorThisFrame()
        SetRadarAsInteriorThisFrame(`h4_fake_islandx`, vec(4700.0, -5145.0), 0, 0)
      end

    end
end
Citizen.CreateThread(loadCayoPerico)

function tvRP.isOnCayo()
  return onCayo
end

function tvRP.notify(msg,notifType,displayTime,customIcon)
  SendNUIMessage{
    act = "event",
    event = "notificare",
    type = notifType,
    displayTime = displayTime or 5000,
    text = msg,
    icon = customIcon,
  }
end

function tvRP.notifyPicture(icon, type, sender, title, text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  SetNotificationMessage(icon, icon, true, type, sender, title, text)
  DrawNotification(false, true)
end

function tvRP.showError(msg)
  TriggerEvent("chatMessage", "^1"..msg)
end

function tvRP.sendInfo(msg)
  TriggerEvent("chatMessage", "^5"..msg)
end

function tvRP.msg(msg)
  TriggerEvent("chatMessage", msg)
end

function tvRP.denyAcces()
  tvRP.showError('Nu ai acces la acesta comanda.')
end

function tvRP.notConnected()
  tvRP.showError('Utilizatorul selectat nu este conectat pe server.')
end

function tvRP.cmdUse(correctForm)
  tvRP.msg("^5Syntax: ^7"..correctForm)
end

tvRP.sendSyntax = tvRP.cmdUse
tvRP.sendError = tvRP.showError
tvRP.noAccess = tvRP.denyAcces
tvRP.notOnline = tvRP.notConnected

function tvRP.getCObjects()
  return GetGamePool("CObject")
end

function tvRP.getCVehicles()
  return GetGamePool("CVehicle")
end

function tvRP.getCPeds()
  return GetGamePool("CPed")
end

function tvRP.getGamePool(pool)
  return GetGamePool(pool)
end

function EnumerateEntitiesWithinDistance(gameData, coords, radius, affectPlayers)
    local nEnts = {}

    if not coords then
        coords = pedPos
    end

    for _objectId, theEntity in pairs(gameData) do
        local inRadius = #(coords - GetEntityCoords(theEntity)) <= radius

        if inRadius then
          nEnts[#nEnts + 1] = affectPlayers and _objectId or theEntity
      end
    end

    return nEnts
end

function tvRP.randomNumberFromString(format)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- handle game spawn logic
AddEventHandler('onClientMapStart', function()
  exports.vrp:setAutoSpawn(true)
end)

-- handle framework events

RegisterNetEvent("vRP:playAudio", function(sound, volume)
  SendNUIMessage{
    act = "sound_manager",
    call = "play",
    sound = sound,
    volume = volume,
  }
end)

RegisterNetEvent("vRP:stopAudio", function()
  SendNUIMessage{
    act = "sound_manager",
    call = "stop",
  }
end)

RegisterNetEvent("vRPnotify", tvRP.notify)

TriggerServerEvent('vRP:loadPlayer')
RegisterNetEvent('vRP:checkIDRegister')
AddEventHandler('vRP:checkIDRegister', function()
  TriggerEvent('playerSpawned', GetEntityCoords(PlayerPedId()))
end)

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRPcli:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

RegisterNetEvent("vRP:onFactionChange")

Citizen.CreateThread(function()
  local protectedClientEvents = {
    "vRP:onJobChange",
    "fp-inventory:refreshDrops",
    "fp-jail:setState",
    "vRP:setDealershipConfig",
  }

  for _, event in pairs(protectedClientEvents) do
    RegisterNetEvent(event)
    AddEventHandler(event, function()
      local invokedResource = GetInvokingResource()

      if invokedResource then
        TriggerServerEvent("vRP:onEventTriggered", event, invokedResource)
      end
    end)
  end
end)

RegisterCommand("usecursor", function()
  TriggerEvent("vRP:interfaceFocus", true)
  SetCursorLocation(0.5, 0.5)

  Citizen.Wait(500)
  SendNUIMessage({
    act = "useCursor",
  })
end)

RegisterKeyMapping("usecursor", "Foloseste cursorul", "keyboard", "GRAVE")

exports("getClientObject", function()
  return tvRP
end)