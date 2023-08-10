local inEvent = false

function tvRP.toggleInEvent()
  inEvent = not inEvent
end

function tvRP.setInEvent(flag)
  if inEvent ~= flag then
    tvRP.toggleInEvent()
  end
end

function tvRP.isInEvent()
  return inEvent
end

RegisterNetEvent("vRP:interfaceFocus")
AddEventHandler("vRP:interfaceFocus", function(stateTbl, keepInput)
	if type(stateTbl) == "table" then
		SetNuiFocus(stateTbl[1], stateTbl[2])
	else
    SetNuiFocus(stateTbl, stateTbl)
  end

  SetNuiFocusKeepInput(keepInput)
end)

RegisterNUICallback("setFocus", function(data, cb)
  TriggerEvent("vRP:interfaceFocus", table.unpack(data.state or {false, false}))

  cb('ok')
end)

AddEventHandler("vRP:pauseChange", function(paused)
  SendNUIMessage({act="pause_change", paused=paused})
end)

function tvRP.openMenuData(menudata)
  SendNUIMessage({act="open_menu", menudata = menudata})
end

function tvRP.closeMenu()
  SendNUIMessage({act="close_menu"})
end

function tvRP.prompt(title,fields)
  SendNUIMessage({act="prompt",title=title,fields=fields})
  TriggerEvent("vRP:interfaceFocus", true)
  SetCursorLocation(0.5, 0.5)
end

function tvRP.request(id,text,title)
  SendNUIMessage({act="request",id=id,text=tostring(text),title=title})
  tvRP.playSound("HUD_MINI_GAME_SOUNDSET","5_SEC_WARNING")
  SetCursorLocation(0.5, 0.5)
end

RegisterNetEvent("vRP:requestKey", function(data)
  if type(data) == "table" then

    PlaySoundFrontend(-1, "INFO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    SendNUIMessage({
      act = "keyRequest",
      request = "use",

      key = data.key,
      text = data.text or "Interactioneaza",
    })

    return
  end

  SendNUIMessage({
    act = "keyRequest",
    request = "hide",
  })
end)

RegisterNetEvent("vRP:hint", function(text, time)
  SendNUIMessage({
    act = "hint",
    text = text:upper(),
    timeout = time,
  })
end)

RegisterNUICallback("menu",function(data,cb)
  if data.act == "close" then
    vRPserver.closeMenu({data.id})
  elseif data.act == "valid" then
    vRPserver.validMenuChoice({data.id,data.choice,data.mod})
  end

  cb("ok")
end)

RegisterNUICallback("prompt",function(data,cb)
  local responses = {}

  for k, v in pairs(data.result) do

    if v.number and v.text then
      responses[v.field] = tonumber(v.text)
    else
      responses[v.field] = v.text:len() > 0 and v.text or false
    end

  end

  TriggerServerEvent("vRP:promptResult", responses)
  TriggerEvent("vRP:interfaceFocus", false)

  cb("ok")
end)

-- gui request event
RegisterNUICallback("request",function(data,cb)
  TriggerServerEvent("vRP:requestResult", data.id, data.ok)
  TriggerEvent("vRP:interfaceFocus", false)

  cb("ok")
end)

RegisterNetEvent("vRP:progressBar", function(data, cb)
  data.anim = data.anim or {}

  exports.progressbars:Custom({
    Async = true,
    Duration = data.duration,
    Label = data.text,
    Animation = {scenario = data.anim.scenario, animationDictionary = data.anim.dict, animationName = data.anim.name},
    DisableControls = data.disableControls,
    onComplete = cb,
  })
end)


-- DIV

-- set a div
-- css: plain global css, the div class is "div_name"
-- content: html content of the div
function tvRP.setDiv(name,css,content,withFocus)
  if withFocus then
    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
  end
  SendNUIMessage({act="set_div", name = name, css = css, content = content})
end

-- set the div css
function tvRP.setDivCss(name,css)
  SendNUIMessage({act="set_div_css", name = name, css = css})
end

-- set the div content
function tvRP.setDivContent(name,content)
  SendNUIMessage({act="set_div_content", name = name, content = content})
end

-- execute js for the div
-- js variables: this is the div
function tvRP.divExecuteJS(name,js)
  SendNUIMessage({act="div_execjs", name = name, js = js})
end

-- remove the div
function tvRP.removeDiv(name,withFocus)
  if withFocus then
    SetNuiFocus(false, false)
  end
  SendNUIMessage({act="remove_div", name = name})
end

function tvRP.isPaused()
  return IsPauseMenuActive()
end

local keytable = {
  ["k"] = {
    commandname = "gui_openmainmenu",
    description = "Deschide meniul principal K",
    fnc = function()
      if (not tvRP.isInEvent()) and (not tvRP.isInComa() or not cfg.coma_disable_menu) and (not tvRP.isHandcuffed() or not cfg.handcuff_disable_menu) then
      	TriggerServerEvent("vRP:openMainMenu")
      end
    end
  },
  ["up"] = {
    commandname = "gui_menuup",
    description = "Key UP",
    fnc = function() 
      SendNUIMessage({act="event",event="UP"})
      CreateThread(function()
        local timer = 0
        while IsControlPressed(table.unpack(cfg.controls.phone.up)) do
          Citizen.Wait(0)
          timer = timer + 1
          if timer > 30 then
            Citizen.Wait(90)
            SendNUIMessage({act="event",event="UP"})
          end
        end
      end)
     end
  },
  ["down"] = {
    commandname = "gui_menudown",
    description = "Key DOWN",
    fnc = function() 
      SendNUIMessage({act="event",event="DOWN"}) 
      CreateThread(function()
        local timer = 0
        while IsControlPressed(table.unpack(cfg.controls.phone.down)) do
          Citizen.Wait(0)
          timer = timer + 1
          if timer > 30 then
          Citizen.Wait(25)
          SendNUIMessage({act="event",event="DOWN"})
          end
        end
      end)
    end
  },
  ["left"] = {
    commandname = "gui_menuleft",
    description = "Key LEFT",
    fnc = function()
    	SendNUIMessage({act="event",event="LEFT"})
    end
  },
  ["right"] = {
    commandname = "gui_menuright",
    description = "Key RIGHT",
    fnc = function()
    	SendNUIMessage({act="event",event="RIGHT"})
	end
  },
  ["return"] = {
    commandname = "gui_menuselect",
    description = "Key SELECT",
    fnc = function()
    	SendNUIMessage({act="event",event="SELECT"})
    end
  },
  ["back"] = {
    commandname = "gui_menuback",
    description = "Key BACK",
    fnc = function()
    	SendNUIMessage({act="event",event="CANCEL"})
    end
  },
  ["Y"] = {
    commandname = "gui_menuacceptrequest",
    description = "Accepta request",
    fnc = function()
    	SendNUIMessage({act="event",event="F5"})
    end
  },
  ["N"] = {
    commandname = "gui_menudenyrequest",
    description = "Respinge request",
    fnc = function()
    	SendNUIMessage({act="event",event="F6"})
	end
  }
}

for k,v in pairs(keytable) do
  RegisterCommand(v.commandname, v.fnc)
  RegisterKeyMapping(v.commandname, v.description, 'keyboard', k)
end

RegisterNUICallback("frontendSound", function(data, cb)
  PlaySoundFrontend(-1, data.dict, data.sound, 1)
  cb("ok")
end)