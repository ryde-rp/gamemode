--by !FEL1X

local isScoreboardOpen = false
local requestedData

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(Config.updateScoreboardInterval)
        TriggerServerEvent("flx-scoreb:updateValues")
    end
end)

local PlayerPedPreview
function createPedScreen(playerID)
    CreateThread(function()
        ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_JOINING_SCREEN"), true, -1)
        Citizen.Wait(100)
        N_0x98215325a695e78a(false)
        PlayerPedPreview = ClonePed(playerID, GetEntityHeading(playerID), true, false)
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedPreview))
        SetPedMute(PlayerPedPreview)
        SetEntityCoords(PlayerPedPreview, x,y,z-10)
        FreezeEntityPosition(PlayerPedPreview, true)
        SetEntityVisible(PlayerPedPreview, false, false)
        NetworkSetEntityInvisibleToNetwork(PlayerPedPreview, false)
        Wait(200)
        SetPedAsNoLongerNeeded(PlayerPedPreview)
        GivePedToPauseMenu(PlayerPedPreview, 2)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(true)
    end)
end

RegisterCommand('togglescoreboard', function()
    if not isScoreboardOpen then
        TriggerServerEvent('flx-scoreb:requestUserData', tonumber(GetPlayerServerId(PlayerId())))
        if Config.showPlayerPed then
            SetFrontendActive(true)
            createPedScreen(PlayerPedId())
        end
        SendNUIMessage({
            action = "show",
            keyBindValue = tostring(GetControlInstructionalButton(0, 0x3635f532 | 0x80000000, 1)),
        })
        SetNuiFocus(true,true)
        if Config.screenBlur then
            TriggerScreenblurFadeIn(Config.screenBlurAnimationDuration)
        end
        isScoreboardOpen = true
    elseif isScoreboardOpen then
        if Config.showPlayerPed then
            DeleteEntity(PlayerPedPreview)
            SetFrontendActive(false)
        end
        SendNUIMessage({
            action = "hide",
            keyBindValue = tostring(GetControlInstructionalButton(0, 0x3635f532 | 0x80000000, 1)),
        })
        SetNuiFocus(false,false)
        isScoreboardOpen = false
        if Config.screenBlur then
            TriggerScreenblurFadeOut(Config.screenBlurAnimationDuration)
        end
    end
end, false)

RegisterKeyMapping('togglescoreboard', 'Show/Hide Scoreboard', 'keyboard', 'GRAVE')

RegisterNUICallback('closeScoreboard', function()
    ExecuteCommand('togglescoreboard')
end)

RegisterNetEvent("flx-scoreb:addUserToScoreboard")
AddEventHandler(
    "flx-scoreb:addUserToScoreboard",
    function(source,playerID, playerName, playerJob, playerGroup)
        SendNUIMessage(
            {
                action="addUserToScoreboard",
                source = source,
                playerID = playerID,
                playerName = playerName,
                playerJob = playerJob,
                playerGroup = playerGroup,
            }
        )
    end
)

RegisterNetEvent("flx-scoreb:sendConfigToNUI")
AddEventHandler("flx-scoreb:sendConfigToNUI",
    function()
        SendNUIMessage({
            action = "getConfig",
            config = json.encode(Config),
        })
    end
)

RegisterNetEvent("flx-scoreb:setValues")
AddEventHandler(
    "flx-scoreb:setValues",
    function(onlinePlayers, onlineStaff, onlinePolice, onlineEMS, onlineTaxi, onlineMechanics)
        SendNUIMessage(
            {
                action="updateScoreboard",
                onlinePlayers = onlinePlayers,
                onlineStaff = onlineStaff,
                onlinePolice = onlinePolice,
                onlineEMS = onlineEMS,
                onlineTaxi = onlineTaxi,
                onlineMechanics = onlineMechanics,
            }
        )
    end
)

RegisterNetEvent("flx-scoreb:refrehScoreboard")
AddEventHandler(
    "flx-scoreb:refrehScoreboard",
    function()
        SendNUIMessage(
            {
                action="refreshScoreboard",
            }
        )
    end
)

RegisterNUICallback('showPlayerPed', function(data)
    if Config.showPlayerPed then
        local playerID = data.source
        DeleteEntity(PlayerPedPreview)
        Citizen.Wait(100)
        local playerTargetID = GetPlayerPed(GetPlayerFromServerId(playerID))
        PlayerPedPreview = ClonePed(playerTargetID, GetEntityHeading(playerTargetID), true, false)
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedPreview))
        SetPedMute(PlayerPedPreview)
        SetEntityCoords(PlayerPedPreview, x,y,z-10)
        FreezeEntityPosition(PlayerPedPreview, true)
        SetEntityVisible(PlayerPedPreview, false, false)
        NetworkSetEntityInvisibleToNetwork(PlayerPedPreview, false)
        Wait(200)
        SetPedAsNoLongerNeeded(PlayerPedPreview)
        GivePedToPauseMenu(PlayerPedPreview, 2)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(true)
        TriggerServerEvent('flx-scoreb:requestUserData', tonumber(playerID), data.playerID)
    end
end)

RegisterNetEvent("flx-scoreb:receiveRequestedData")
AddEventHandler(
    "flx-scoreb:receiveRequestedData",
    function(from, data)
        requestedData = data
        SendNUIMessage(
        {
            action="playerInfoUpdate",
            playerName = requestedData.playerName,
            playerID = requestedData.playerID,
            timePlayed = requestedData.timePlayed,
            roleplayName = requestedData.roleplayName,
        }
    )
    end
)

RegisterNetEvent("flx-scoreb:retrieveUserData")
AddEventHandler(
    "flx-scoreb:retrieveUserData",
    function(from, to)
        local data = {}
        data.playerName = GetPlayerName(PlayerId())
        data.playerID = to
        local retVal, timePlayed = StatGetInt('mp0_total_playing_time')
        data.timePlayed = timePlayed
        TriggerServerEvent('flx-scoreb:sendRequestedData', from, data)
    end
)
