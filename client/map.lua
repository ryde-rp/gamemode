local requestSent = false
local defaultBlipScale = 0.7
local defaultMarkerDistance = 7.5
local currentArea = nil
local markersData = {}
local blipsData = {}
local mapAreas = {}

-- Graphics (3d text, subtitle)
function DrawText3D(x,y,z, text, scl, font) 
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  local px,py,pz = table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)
  local scale = (1/dist*scl)*(1/GetGameplayCamFov()*100);
 
  if onScreen then
    SetTextScale(0.0*scale, 1.1*scale)
    SetTextFont(font or 0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
  end
end

function DrawRectText(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35,0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function tvRP.subtitleText(txtString, font, textSizeA, textSizeB, textAlpha, customY)
  SetTextFont(font or 0)
  SetTextProportional(0)
  SetTextScale((textSizeA or 0.25), (textSizeB or 0.3))
  SetTextColour(255, 255, 255, (textAlpha or 255))
  SetTextDropShadow(40, 5, 5, 5, 255)
  SetTextEdge(30, 5, 5, 5, 255)
  SetTextDropShadow()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(txtString)
  DrawText(0.5, (customY or 0.95))
end

function tvRP.displayHelp(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Blipuri (lista blips: https://wiki.rage.mp/index.php?title=Blips)
CreateThread(function()
  local blipId = 0
  
  for blip, blipConfig in pairs(cfg.map_blips) do
    blipId = blipId + 1
    local x,y,z = table.unpack(blipConfig.coords)
    
    local nBlip = tvRP.createBlip(("_custom_blip-%d"):format(blipId), x, y, z, blipConfig.blip_id, blipConfig.blip_color, (type(blip) == "string" and blip or (blipConfig.name or "")), blipConfig.scale)
    if blipConfig.blip_id == 161 then
      SetBlipPriority(nBlip, 1)
    else
      SetBlipPriority(nBlip, blipConfig.priority or 2)
    end
  end
end)

function tvRP.createBlip(uniqueId, x, y, z, idType, idColor, nameString, blipScale)
  if not uniqueId then return end
  
  blipsData[uniqueId] = AddBlipForCoord(x+0.001, y+0.001, z+0.001)
  SetBlipSprite(blipsData[uniqueId], idType)
  SetBlipAsShortRange(blipsData[uniqueId], true)
  SetBlipColour(blipsData[uniqueId], idColor)
  SetBlipScale(blipsData[uniqueId], (blipScale or defaultBlipScale))

  if nameString then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(nameString)
    EndTextCommandSetBlipName(blipsData[uniqueId])
  end

  return blipsData[uniqueId]
end

function tvRP.setBlipRoute(blipId, routeState, keepColor)
  if not routeState then routeState = true end
  if not blipsData[blipId] then return end
  local theBlip = blipsData[blipId]

  SetBlipRoute(theBlip, routeState)
  
  if keepColor then
    if type(keepColor) == "string" then
      SetBlipRouteColour(theBlip, GetBlipColour(theBlip))
    elseif type(keepColor) == "number" then
      SetBlipRouteColour(theBlip, keepColor)
    end
  end
end

function tvRP.setBlipPriority(blipId, priority)
  if not blipsData[blipId] then
    return
  end

  SetBlipPriority(blipsData[blipId], priority)
end

function tvRP.setBlipCoords(blipId, newCoords)
  if not blipsData[blipId] then return end
  SetBlipCoords(blipsData[blipId], newCoords)
end

function tvRP.setGPS(x,y)
  SetNewWaypoint(x+0.0001,y+0.0001)
end

RegisterNetEvent("vRP:setGPS", tvRP.setGPS)

function tvRP.deleteBlip(blipId)
  if not blipsData[blipId] then return end
  RemoveBlip(blipsData[blipId])
  blipsData[blipId] = nil
end

-- Markere/floating texts (lista markere: https://wiki.rage.mp/index.php?title=Markers)
function tvRP.createFloatingText(x, y, z, text, size, textFont, distance, markWithID)
  local document = {
      coords = vector3(x, y, z),
      text = tostring(text),
      scale = size,
      font = (textFont or 0),
      colors = {0, 0, 0, 255},
      minDist = (distance or defaultMarkerDistance),
  }

  if markWithID then markersData[markWithID] = {type = "hologram", info = document} return end
  markersData[#markersData + 1] = {type = "hologram", info = document}
end

function tvRP.setFloatingTextValue(hologramId, newValue)
  if not markersData[hologramId] then return end
  if not newValue then newValue = "" end
  markersData[hologramId].info.text = tostring(newValue)
end

function tvRP.drawIndicator(text, pos)
	AddTextEntry("DUTYSTRING", text)
	
	SetFloatingHelpTextWorldPosition(1, pos)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)

	BeginTextCommandDisplayHelp("DUTYSTRING")
	EndTextCommandDisplayHelp(2, false, false, -1)
end

function tvRP.addMarker(x, y, z, sizeX, sizeY, sizeZ, r,g, b, a, markerType, distance, markWithID)
  local x,y,z = tonumber(x),tonumber(y),tonumber(z)
  local document = {
      coords = vector3(x,y,z),
      scale = vector3((sizeX or 0.45), (sizeY or 0.45), (sizeZ or 0.45)),
      colors = {(r or 255), (g or 255), (b or 255), (a or 255)},
      minDist = (distance or defaultMarkerDistance),
      displayId = (markerType or 21),
  }
  if markWithID then
    markersData[markWithID] = {type = "marker", info = document}
    return
  end
  markersData[#markersData + 1] = {type = "marker", info = document}
end

function tvRP.removeMarker(marker_id)
  if not markersData[marker_id] then return end
  markersData[marker_id] = nil
end

CreateThread(function()
  while true do
    local scriptTicks = 500
    for _, markerData in pairs(markersData) do
      local document = markerData.info;
      local dist = #(document.coords - pedPos) <= document.minDist;
      if dist then
        scriptTicks = 1
        if markerData.type == "marker" then
          DrawMarker(document.displayId, document.coords.x, document.coords.y, document.coords.z + 1.0, 0, 0, 0, 0,0, 0, document.scale.x, document.scale.y, document.scale.z, document.colors[1], document.colors[2], document.colors[3], document.colors[4], 0, 0, true, true)
        else
          DrawText3D(document.coords.x, document.coords.y, document.coords.z, document.text, document.scale, document.font)
        end
      end
    end
    Citizen.Wait(scriptTicks)
  end
end)

-- Map Areas
function tvRP.setArea(name, x, y, z, radius, text, execAtJoin, execAtLeave)
  local areaType = "server"
  if execAtJoin then areaType = "client" end

  mapAreas[name] = {
    coords = vector3(tonumber(x) + 0.001, tonumber(y) + 0.001, tonumber(z) + 0.001),
    radius = radius,
    showMsg = text ~= nil,
    screenMsg = (type(text) == "string" and text or {
      key = text.key,
      text = text.text,
    }),
    player_in = false,
    areaType = areaType,
    onJoin = (execAtJoin or function() end),
    onLeave = (execAtLeave or function() end),
  }
end

function tvRP.removeArea(name)
  if not mapAreas[name] then return end
  mapAreas[name] = nil
end

function tvRP.enterArea(areaId)
  if not mapAreas[areaId] then return end
  mapAreas[areaId].onJoin(areaId)
  currentArea = areaId
end

function tvRP.leaveArea(areaId)
  if not mapAreas[areaId] then return end
  mapAreas[areaId].onLeave(areaId)
  currentArea = nil
  if requestSent then
    requestSent = false
    TriggerEvent("vRP:requestKey", false)
  end
end

CreateThread(function()
  while true do
    Citizen.Wait(1000)
    for areaKey, areaDocument in pairs(mapAreas) do
      local inState = #(areaDocument.coords - pedPos) <= areaDocument.radius
      if areaDocument.player_in and not inState and currentArea then
        if areaDocument.areaType == "server" then
          vRPserver.leaveArea({areaKey})
          requestSent = false;
        else
          tvRP.leaveArea(areaKey)
          requestSent = false;
        end
        currentArea = nil
      elseif not areaDocument.player_in and inState then
          if areaDocument.showMsg then
            while inState do
              if #(areaDocument.coords - pedPos) < areaDocument.radius then
                if not currentArea then
                  if type(areaDocument.screenMsg) == "table" then
                    if not requestSent then
                      requestSent = true
                      TriggerEvent("vRP:requestKey", {key = areaDocument.screenMsg.key, text = areaDocument.screenMsg.text})
                    end
                  else
                    tvRP.subtitleText(areaDocument.screenMsg)
                  end
                  if IsControlJustReleased(0, 38) then
                    if areaDocument.areaType == "server" then
                      vRPserver.enterArea({areaKey})
                      currentArea = areaKey
                      TriggerEvent("vRP:requestKey", false)
                    else
                      tvRP.enterArea(areaKey)
                      TriggerEvent("vRP:requestKey", false)
                    end
                  end
                end
              else
                inState = false
                currentArea = nil
                tvRP.leaveArea(areaKey)
                requestSent = false;
                tvRP.closeMenu()
                break
              end
              Citizen.Wait(1)
            end
          else
              if areaDocument.areaType == "server" then
                  vRPserver.enterArea({areaKey})
                  currentArea = areaKey
              else tvRP.enterArea(areaKey)
                  currentArea = areaKey
              end
          end
      end
      areaDocument.player_in = inState
    end
  end
end)