-- Util Peds implementation by Proxy#4444
-- made for FairPlay RP -> www.fairplay-rp.ro
-- Lista peduri: https://wiki.rage.mp/index.php?title=Peds

local tempPeds = {}
local inAnyDialog = false

local inputKeys = {
  [51] = "INPUT_CONTEXT",
  [47] = "INPUT_DETONATE",
}

local textKeys = {
  [47] = "G",
}

function tvRP.createPed(id, options)
  local model = GetHashKey(options.model)
  RequestModel(model)

  local coords = options.position

  RequestAnimDict("mini@strip_club@idles@bouncer@base")
  while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
    Citizen.Wait(1)
  end

  while not HasModelLoaded(model) do
    Citizen.Wait(250)
  end

  local nPed = CreatePed(1, model, coords.x, coords.y, coords.z - 1.0, (options.rotation or 0) + 0.0, false, false)
  tempPeds[id] = {
    coords = coords,
    minDist = options.minDist or 3.5,
    fields = options.fields or {},
    name = options.name,
    desc = options.description,
    text = options.text or "Bine ai venit la noi, cu ce te putem ajuta?!",
    enterKey = options.key or 51,
    entity = nPed,
    requestText = options.requestText,
  }

  tempPeds[id].fields[#tempPeds[id].fields + 1] = {
    item = "Va multumesc mult pentru ajutor!",
    post = "closePedDialog",
  }

  SetModelAsNoLongerNeeded(model)
  FreezeEntityPosition(nPed, (options.freeze or false))
  SetEntityInvincible(nPed, true)
  SetBlockingOfNonTemporaryEvents(nPed, true)

  Citizen.Wait(1000)
  local scenario = options.scenario
  if scenario then
    if scenario.default then
      TaskPlayAnim(nPed,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    else
      if scenario.anim then
        RequestAnimDict(scenario.anim.dict)
        while not HasAnimDictLoaded(scenario.anim.dict) do
          Citizen.Wait(1)
        end

        TaskPlayAnim(nPed, scenario.anim.dict, scenario.anim.name, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
      else
        if scenario.startAtPosition then
          local behindPed = GetOffsetFromEntityInWorldCoords(nPed, 0.0, 0 - 0.5, -0.5);
          TaskStartScenarioAtPosition(nPed, scenario.name:upper(), behindPed.x, behindPed.y, behindPed.z, GetEntityHeading(nPed), 0, 1, false)
        else
          TaskStartScenarioInPlace(nPed, scenario.name:upper(), 0, false)
        end
      end
    end
  end

  for _, v in pairs(options.variations or {}) do
    local face = v.faceData
    if face then

      if face.face then
        SetPedHeadBlendData(nPed, face.face, face.face, 0, face.faceTexture, face.faceTexture, 0, 1.0, 0.1, 0.0, false)
        SetPedHeadOverlay(nPed, 2, 12, 1.0)
        SetPedHeadOverlayColor(nPed, 2, 1, 1, 0)
      end

      if face.ruj then
        SetPedHeadOverlay(nPed, 8, face.ruj, 1.0)
        SetPedHeadOverlayColor(nPed, 8, 1, face.culoareRuj, 0)
      end

      if face.barba then
        SetPedHeadOverlay(nPed, 1, face.barba, 1.0)
        SetPedHeadOverlayColor(nPed, 1, 1, 1, 0)
      end

      if face.machiaj then
        SetPedHeadOverlay(nPed, 4, face.machiaj, 1.0)
        SetPedHeadOverlayColor(nPed, 4, 1, face.culoareMachiaj, 0)
      end
    end

    local clothes = v.haine
    if clothes then
      for k, v in pairs(clothes) do
        local args = splitString(k, ":")
        local index = parseInt(args[2])

        if index ~= 0 then
          SetPedComponentVariation(nPed, index, v[1], v[2], v[3] or 2)
        end
      end
    end

  end

  return tonumber(nPed)
end

function tvRP.deletePed(id)
  if tempPeds[id] then
    DeletePed(tempPeds[id].entity)
  end

  tempPeds[id] = nil
end

local cam = false
CreateThread(function()
  local requestedInteract = false
  while true do
    for thePed, pedData in pairs(tempPeds) do
      local coords = pedData.coords

      while #(coords - pedPos) <= pedData.minDist do
        if not tempPeds[thePed] then
          break
        end

        if not inAnyDialog then
          local key = pedData.enterKey
          if IsControlJustReleased(0, key) then
            TriggerEvent("vRP:requestKey", false)
            inAnyDialog = true

            local px, py, pz = table.unpack(pedData.coords)
            local x, y, z = px + GetEntityForwardX(pedData.entity) * 1.2, py + GetEntityForwardY(pedData.entity) * 1.2, pz + 0.52
            local rx = GetEntityRotation(pedData.entity, 2)

            local camRotation = rx + vector3(0.0, 0.0, 181)
            local camCoords = vector3(x, y, z)

            ClearFocus()
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())

            SetCamActive(cam, true)
            RenderScriptCams(true, true, 1000, true, false)

            SendNUIMessage({
              act = "interface",
              target = "pedDialog",

              fields = pedData.fields,
              name = pedData.name,
              desc = pedData.desc,
              text = pedData.text,
            })

            TriggerEvent("vRP:interfaceFocus", true)
          end

          -- DrawText3D(coords.x, coords.y, coords.z + 0.40, optionsText, 1.0)
          if pedData.drawIndicator then
            tvRP.drawIndicator("~"..inputKeys[key].."~ Interactioneaza", coords)
          elseif not requestedInteract then
            requestedInteract = true
            TriggerEvent("vRP:requestKey", {key = textKeys[key] or "E", text = pedData.requestText or "Interactioneaza"})
          end

          -- DrawMarker(20,coords.x + 0.01, coords.y, coords.z + 1.20,0,0,0,0,0,0,0.60, 0.60,-0.60,80, 157, 202, 75, true, true)
          DrawText3D(coords.x, coords.y, coords.z + 1.1, pedData.name, 0.750)
        end

        Citizen.Wait(1)
      end
    end

    if requestedInteract then
      TriggerEvent("vRP:requestKey", false)
      requestedInteract = false
    end

    Citizen.Wait(1000)
  end
end)

RegisterNUICallback("closePedDialog", function(_, cb)
  CreateThread(function()
    Citizen.Wait(800)
    inAnyDialog = false
  end)

  TriggerEvent("vRP:interfaceFocus", false)
  ClearFocus()
  RenderScriptCams(false, true, 1000, true, false)
  DestroyCam(cam, false)
  cam = false

  cb("ok")
end)

RegisterNUICallback("useDialogPedOption", function(data, cb)
  if data.args then
    TriggerServerEvent(data.post, data.args[1] or "")
  else
    TriggerEvent(data.post)
  end

  cb("ok")
end)