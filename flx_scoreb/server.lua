--by !FEL1X

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP")

function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }
    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end

function getFactionName(faction)
    if faction == "user" then
        return "No Faction"
    else
        return faction
    end
end

function getJobName(job)
    if job == "" then
        return "Unemployed"
    else
        return job
    end
end

function RefreshScoreboard()
    local players = vRP.getUsers({})
    TriggerClientEvent("flx-scoreb:refrehScoreboard", -1)
    for user_id,source in pairs(players) do
        local playerID = user_id
        vRP.getUserIdentity({user_id, function(identity)
            if identity then
                local playerName = Sanitize(identity.firstname.." "..identity.name)
                local playerJob = getJobName(vRP.getUserGroupByType({user_id,'job'}))
                local playerFaction = getFactionName(vRP.getUserFaction({user_id}))
                TriggerClientEvent("flx-scoreb:addUserToScoreboard", -1, source ,playerID, playerName, playerJob, playerFaction)
                TriggerClientEvent("flx-scoreb:sendConfigToNUI", -1)
            end
        end})
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(1000)
        RefreshScoreboard()
    end
    TriggerClientEvent("flx-scoreb:sendConfigToNUI", -1)
end)

RegisterCommand("refreshscoreboard", function()
    RefreshScoreboard()
end, true)

RegisterServerEvent("flx-scoreb:updateValues")
AddEventHandler(
    "flx-scoreb:updateValues",
    function()
        local onlinePlayers = getOnlinePlayers()
        local onlineStaff = getOnlineStaff()
        local onlinePolice = getOnlineByType(Config.policeCounterType, Config.policeCounterIdentifier)
        local onlineEMS = getOnlineByType(Config.emsCounterType, Config.emsCounterIdentifier)
        local onlineTaxi = getOnlineByType(Config.taxiCounterType, Config.taxiCounterIdentifier)
        local onlineMechanics = getOnlineByType(Config.mechanicCounterType, Config.mechanicCounterIdentifier)
        TriggerClientEvent("flx-scoreb:setValues", -1, onlinePlayers, onlineStaff, onlinePolice, onlineEMS, onlineTaxi, onlineMechanics)
    end
)

RegisterNetEvent('flx-scoreb:requestUserData')
AddEventHandler(
    'flx-scoreb:requestUserData',  
    function(target)
        TriggerClientEvent("flx-scoreb:retrieveUserData", tonumber(target), source, tonumber(target))
    end
)

RegisterNetEvent('flx-scoreb:sendRequestedData')
AddEventHandler(
    'flx-scoreb:sendRequestedData',  
    function(to, data)
        local user_id = vRP.getUserId({source})
        if user_id ~= nil then
            vRP.getUserIdentity({user_id, function(identity)
                if identity then
                    data.playerID = user_id
                    data.roleplayName = Sanitize(identity.firstname.." "..identity.name)
                    TriggerClientEvent("flx-scoreb:receiveRequestedData", to, source, data)
                end
            end})
        end
    end
)

AddEventHandler(
    "vRP:playerSpawn",
    function()
        Citizen.Wait(500)
        RefreshScoreboard()
    end
)

AddEventHandler(
    "vRP:playerLeave",
    function ()
        Citizen.Wait(500)
        RefreshScoreboard()
    end
)

function getOnlinePlayers()
    local players = vRP.getUsers({})
    local playersCount = 0
    for _ in pairs(players) do
        playersCount = playersCount + 1
    end
    return playersCount
end

function getOnlineStaff()
    local staffCount = vRP.countOnlineStaff()
    return staffCount
end

function getOnlineByType(type, value)
    if type == "job" then
        local usersGroup = vRP.getUsersByGroup({value})
        return #usersGroup
    elseif type == "faction" then
        local players = vRP.getUsers({})
        local factionCount = 0
        for user_id, _ in pairs(players) do
            if vRP.isUserInFaction({user_id,value}) then
                factionCount = factionCount + 1
            end
        end
        return factionCount
    elseif type == "permission" then
        local players = vRP.getUsers({})
        local permissionCount = 0
        for user_id, _ in pairs(players) do
            if vRP.hasPermission({user_id, value}) then
                permissionCount = permissionCount + 1
            end
        end
        return permissionCount
    end
end

