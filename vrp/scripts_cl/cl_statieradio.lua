local radioMenu = false
local radioData = {
    volume = 50,
    channel = 0,

    onRadio = false,
    radioProp = false,
}

local cfg = {
    maxFrequency = 999,
    restrictedChannels = {},
}

local function connectRadio(channel)
    radioData.channel = channel

    if radioData.onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        radioData.onRadio = true
    end
    
    exports["pma-voice"]:setRadioChannel(channel)

    local channelObj = splitString(tostring(channel), ".")
    if channelObj[2] ~= nil and channelObj[2] ~= "" then
        tvRP.notify("Te-ai conectat la frecventa "..channel.." MHz", "info", false, "fas fa-walkie-talkie")
    else
        tvRP.notify("Te-ai conectat la frecventa "..channel..".00 MHz", "info", false, "fas fa-walkie-talkie")
    end
end

local function leaveRadio(silentQuit)
    TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)

    radioData.channel = 0
    radioData.onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    
    if not silentQuit then
        tvRP.notify("Te-ai deconectat!", "warning", false, "fas fa-walkie-talkie")
    end
end

local function toggleRadioAnimation(pState)
    loadAnimDict("cellphone@")

    if pState then
        TriggerEvent("attachItemRadio","radio01")
        TaskPlayAnim(tempPed, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
        radioData.radioProp = CreateObject('prop_cs_hand_radio', 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(radioData.radioProp, tempPed, GetPedBoneIndex(tempPed, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
    else
        StopAnimTask(tempPed, "cellphone@", "cellphone_text_read_base", 1.0)
        ClearPedTasks(tempPed)

        if radioData.radioProp ~= 0 then
            DeleteObject(radioData.radioProp)
            DeleteEntity(radioData.radioProp)
            radioData.radioProp = 0
        end
    end
end

local function disableControls()
    DisableControlAction(0,24,true) -- disable attack
    DisableControlAction(0,25,true) -- disable aim
    DisableControlAction(0,47,true) -- disable weapon
    DisableControlAction(0,58,true) -- disable weapon
    DisableControlAction(0,263,true) -- disable melee
    DisableControlAction(0,264,true) -- disable melee
    DisableControlAction(0,257,true) -- disable melee
    DisableControlAction(0,140,true) -- disable melee
    DisableControlAction(0,141,true) -- disable melee
    DisableControlAction(0,142,true) -- disable melee
    DisableControlAction(0,143,true) -- disable melee
    DisableControlAction(0,268,true)
    DisableControlAction(0,182,true)
    DisableControlAction(0,217,true)
    DisableControlAction(0,269,true)
    DisableControlAction(0,270,true)
    DisableControlAction(0,1,true)
    DisableControlAction(0,2,true)
    DisableControlAction(0,3,true)
    DisableControlAction(0,4,true)
    DisableControlAction(0,5,true)
    DisableControlAction(0,6,true)
    DisableControlAction(0,7,true)
    DisableControlAction(0,14,true)
    DisableControlAction(0,15,true)
    DisableControlAction(0,16,true)
    DisableControlAction(0,17,true)
    DisableControlAction(0,245,true)
    DisableControlAction(0,246,true)
    DisableControlAction(0,254,true)
    DisableControlAction(0,255,true)
    DisableControlAction(0,236,true)
    DisableControlAction(0,252,true)
    DisableControlAction(0,253,true)
    DisableControlAction(0,73,true)
    DisableControlAction(0,74,true)
    DisableControlAction(0,303,true)
    DisableControlAction(0,305,true)
    DisableControlAction(0,199,true)
    DisableControlAction(0,22,true)
    DisableControlAction(0,202,true)
    DisableControlAction(0,311,true)
    DisableControlAction(0,323,true)
    DisableControlAction(0,29,true)
    DisableControlAction(0,79,true)
    DisableControlAction(0,0,true)
    DisableControlAction(0,322,true)
    DisableControlAction(0,177,true)
    DisableControlAction(0,200,true)
    DisableControlAction(0,75, true)
    DisableControlAction(0,244, true)
    DisableControlAction(0,86, true)
    DisableControlAction(0,85, true)
    DisableControlAction(0,80, true)
    DisableControlAction(0,38, true)
end

local function toggleRadio(toggle)
    radioMenu = toggle
    TriggerEvent("vRP:interfaceFocus", radioMenu)
    SetNuiFocusKeepInput(radioMenu)

    if radioMenu then
        toggleRadioAnimation(true)
    else
        toggleRadioAnimation(false)
    end

    CreateThread(function()
        while radioMenu do
            disableControls()
            Wait(1)
        end 
    end)

    SendNUIMessage{
        act = "event",
        event = "toggleRadioMenu",
        state = radioMenu
    }
end

exports("IsRadioOn", function()
    return radioData.onRadio
end)

RegisterNetEvent('vRP:onComaEntered', function()
    if radioData.channel ~= 0 then
        leaveRadio(true)
    end
end)

RegisterNetEvent("fp-radio:useItem", function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent("fp-radio:restrictChannels", function(x)
    cfg.restrictedChannels = x
end)

RegisterNUICallback('vRP_radio:joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel <= cfg.maxFrequency and rchannel ~= 0 then
            if rchannel ~= radioData.channel then
                
                if cfg.restrictedChannels[rchannel] then
                    vRPserver.canJoinRadio({rchannel}, function(ok)
                        if ok then
                            connectRadio(rchannel)
                        else
                            tvRP.notify("Frecventa este indisponibila!", "error", false, "fas fa-walkie-talkie")
                        end
                    end)
                else
                    connectRadio(rchannel)
                end

            else
                tvRP.notify("Esti deja conectat pe acest canal!", "error", false, "fas fa-walkie-talkie")
            end
        else
            tvRP.notify("Frecventa este invalida!", "error", false, "fas fa-walkie-talkie")
        end
    else
        tvRP.notify("Frecventa este invalida!", "error", false, "fas fa-walkie-talkie")
    end
end)

RegisterNUICallback('vRP_radio:leaveRadio', function(data, cb)
    if radioData.channel == 0 then
        tvRP.notify("Nu esti conectat la nicio frecventa!", "error", false, "fas fa-walkie-talkie")
    else
        leaveRadio()
    end
end)

RegisterNUICallback("vRP_radio:volumeUp", function(data, cb)
    if radioData.volume <= 95 then
        radioData.volume = radioData.volume + 5

        tvRP.notify("Ai setat volumul radio la: "..radioData.volume, "info", false, "fas fa-walkie-talkie")
        exports["pma-voice"]:setRadioVolume(radioData.volume)
    else
        tvRP.notify("Volumul este deja maxim.", "error", false, "fas fa-walkie-talkie")
    end

    cb()
end)

RegisterNUICallback("vRP_radio:volumeDown", function(data, cb)
    if radioData.volume >= 10 then
        radioData.volume = radioData.volume - 5

        tvRP.notify("Ai setat volumul radio la: "..radioData.volume, "info", false, "fas fa-walkie-talkie")
        exports["pma-voice"]:setRadioVolume(radioData.volume)
    else
        tvRP.notify("Volumul este deja minim.", "error", false, "fas fa-walkie-talkie")
    end

    cb()
end)

RegisterNUICallback('vRP_radio:escape', function(data, cb)
    toggleRadio(false)
    cb()
end)