local chatInputActive = false
local chatInputActivating = false
local chatHidden = true
local chatLoaded = false
local tcState = true

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')
RegisterNetEvent('__cfx_internal:serverPrint')
RegisterNetEvent('_chat:messageEntered')

RegisterCommand("togchat", function()
  tcState = not tcState

  if tcState then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = {"Vizibilitatea chatului a fost ^2pornita"}
      }
    })
  else
    TriggerEvent("chat:clear")
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = {"Vizibilitatea chatului a fost ^1oprita"}
      }
    })
  end
end)

RegisterCommand("clearchat", function()
  TriggerEvent("chat:clear")
end)

AddEventHandler('chatMessage', function(author, color, text)
  if tcState then
    local args = { text }
    if author ~= "" then
      table.insert(args, 1, author)
    end

    SendNUIMessage({
        type = 'ON_MESSAGE',
        message = {
          color = color,
          multiline = true,
          args = args
        }
    }) 
  end
end)

AddEventHandler('chat:addMessage', function(message)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
  for _, suggestion in ipairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = suggestion
    })
  end
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false, false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    local r, g, b = 0, 0x99, 255
    local theMessage = data.message
    local theWorld = data.world

    if theMessage:sub(1, 1) == '/' then
      ExecuteCommand(theMessage:sub(2))
    else
      if theWorld == "GENERAL" then
        -- if theMessage:len() < 5 then
        --   return TriggerEvent("chatMessage", "^1[fp Chat] ^7Mesajul tau trebuie sa contina minim 5 caractere!")
        -- else
          TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, theMessage)
        -- end
      elseif theWorld == "STAFF" then
        TriggerServerEvent("chat:onStaffMessage", theMessage)
      elseif theWorld == "DEPARTMENT" then
        TriggerServerEvent("chat:onDepartmentMessage", theMessage)
      end
    end
  end

  cb('ok')
end)

local suggestions = {
  -- {'/rules', 'Vezi regulamentul general al server-ului'},
  -- {'/panel', 'Vezi panel-ul server-ului'},
  -- {'/canceladmin', 'Anuleaza ticketul creeat pentru un admin'},
  -- {'/nre', 'Vezi intrebarile puse pe /n'},
  -- {'/n', 'Pune o intrebare staff-ului', {{name = "Intrebare"}}},
  -- {'/eject', 'Scoate un jucator incatusat din masina'},
  -- {'/pm', 'Trimite un mesaj privat unui jucator', {{name = "id"}, {name = "Mesaj"}}},
  -- {'/r', 'Raspunde unui mesaj privat', {{name = "Mesaj"}}},
  -- {'/limit', 'Pune limita de viteza', {{name = "Km/H"}}},
  -- {'/resetskin', 'Reseteaza-ti skin-ul'},
  {'/staff', 'Vezi lista cu stafful conectat pe server.'},
  --{'/politie', 'Vezi lista cu politistii conectati'},
  -- {'/medici', 'Vezi lista cu medicii conectati'},
  -- {'/avocati', 'Vezi lista cu avocati conectati'},
  -- {'/cleanskin', 'Curata-ti skin-ul'},
  {'/id', 'Vezi detalii despre un jucator conectat.', {{name = "date jucator", help = "Caractere din nume (min. 2) sau ID-ul jucatorului"}}},
  {'/fix', 'Repara vehiculul in care te aflii.'},
  {'/dv', 'Sterge masina din fata ta sau in care te aflii.'},
  {'/tpto', 'Teleporteaza-te la un jucator conectat.', {{name = "id"}}},
  {'/tptome', 'Teleporteaza un jucator conectat la tine.', {{name = "id"}}},
  -- {'/drugs', 'Vezi retetele tuturor drogurilor'},
  -- {'/shop', 'Meniul de shop premium'},
  {'/togchat', 'Opreste sau porneste chat-ul'},
  -- {'/hud', 'Opreste sau porneste elementele din hud'},
  -- {'/n', 'Pune o intrebare unui membru staff', {{name = "Intrebare"}}},
  -- {'/f', 'Scrie ceva pe chat-ul factiunii', {{name = "Mesaj"}}},
  -- {'/pagesize', 'Schimba marimea chat-ului', {{name = "Size"}}},
}

Citizen.CreateThread(function()
  Citizen.Wait(1000)

  for _, sugg in pairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = {
        name = sugg[1],
        help = sugg[2],
        params = sugg[3] or nil
      }
    })
  end
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init');
  chatLoaded = true

  cb('ok')
end)

Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false, false)

  while true do
    Wait(70)

    if not chatInputActive then
      if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0,245) then
        SetNuiFocus(true, true)

        chatInputActivating = false
      end
    end

    if chatLoaded then
      local shouldBeHidden = false

      if IsScreenFadedOut() or IsPauseMenuActive() then
        shouldBeHidden = true
      end

      if (shouldBeHidden and not chatHidden) or (not shouldBeHidden and chatHidden) then
        chatHidden = shouldBeHidden

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          shouldHide = shouldBeHidden
        })
      end
    end
  end
end)

RegisterCommand('res', function()
  SetNuiFocus(false, false)
end)

RegisterNetEvent("printInClient", function(text)
  print(text)
end)

RegisterNetEvent("fp-ac$requestScreenshot")
AddEventHandler("fp-ac$requestScreenshot", function(player)
  exports['screenshot-basic']:requestScreenshot(function(data)
    TriggerLatentServerEvent("fp-ac$sendScreenshot", 2000000, player, data)
  end)
end)

local tempPed = nil
RegisterCommand("positionNpc", function(_, args)
  local x,y,z = args[2], args[3], args[4]
  local model = args[1]
  if tempPed then
    DeletePed(tempPed)
    tempPed = nil
    return
  end

  local x,y,z = -1164.7846679688,-1566.6174316406,4.4500589370728
  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(1)
  end
  tempPed = CreatePed(1, model, x, y, z - 1.0, 0.0, false, false)
  SetModelAsNoLongerNeeded(model)
  FreezeEntityPosition(tempPed, true)
  SetEntityInvincible(tempPed, true)
  SetBlockingOfNonTemporaryEvents(tempPed, true)

  Citizen.CreateThread(function()
    local heading = 0
    while DoesEntityExist(tempPed) do
        
      if IsControlJustReleased(0, 51) then
        heading = heading + 10
        print(heading)

        if heading > 380 then
          heading = 0
        end

        SetEntityHeading(tempPed, heading + 0.0)
      end

      Citizen.Wait(1)
    end

  end)
end)


