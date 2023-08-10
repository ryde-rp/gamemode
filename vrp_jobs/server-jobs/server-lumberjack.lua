local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local inLumberjackPlayers = {}

local function GetLumberjackExperience(user_id)
    local userExperience = vRP.GetUserJobExperience({user_id, "Taietor de Lemne"})

    if userExperience > 420 then
        return 3
    elseif userExperience > 300 then
        return 2
    end
    return 1
end

local function GenerateLumberjackMission(player, user_id)
    inLumberjackPlayers[user_id] = math.random(1, #Config.LumberjackLocations[1])
    TriggerClientEvent("fp-lumberjack:GenerateMission", player, inLumberjackPlayers[user_id])
end

RegisterServerEvent("fp:job-lumberjack", function(userSkill)
    local player = source
    local user_id = vRP.getUserId({player})
    if vRP.getUserHoursPlayed{user_id} >= 125 then

    if vRP.getInventoryItemAmount({user_id, "forestier_license"}) >= 1 then

    if GetLumberjackExperience(user_id) >= userSkill  then
        if userSkill == 3 then
            vRPclient.getNearestOwnedJobVehicle(player, {15}, function(veh)
                if veh then
                    TriggerClientEvent("FairPlay:JobChange", player, "Taietor de Lemne", userSkill, veh)
                else
                    vRPclient.notify(player, {"Nu ai o masina de job in apropiere", "error"})
                end
            end)
            return;
         end
          TriggerClientEvent("FairPlay:JobChange", player, "Taietor de Lemne", userSkill)
            end
         end
    else
         vRPclient.notify(player, {"Nu ai 125 ore !"})
    end
end)

RegisterCommand("testlumber", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        local userSkill = tonumber(args[1])
        if userSkill == 3 then
            vRPclient.getNearestOwnedJobVehicle(player, {50}, function(veh)
                if veh then
                    TriggerClientEvent("FairPlay:JobChange", player, "Taietor de Lemne", userSkill, veh)
                else
                    vRPclient.notify(player, {"Nu ai o masina de job in apropiere", "error"})
                end
            end)
            return;
        end
        TriggerClientEvent("FairPlay:JobChange", player, "Taietor de Lemne", userSkill)
    end
end)

RegisterServerEvent("fp-lumberjack:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "forestier_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Lumber pentru $10.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,10000}) then
                        vRPclient.notify(player,{"Ai platit $10.000 pentru Licenta de Lumber"})
                        vRP.giveInventoryItem({user_id,"forestier_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $10.000","error"})
                    end
                end
            end})
        end
    end
end)


local LumberjackCooldown = {}
RegisterServerEvent("fp-lumberjack:reward", function(skill, noReward)
    local player = source
    local user_id = vRP.getUserId({player})

    if noReward then
        GenerateLumberjackMission(player, user_id)
        return;
    end

    if skill == 1 then
        local prelucratLocation = vector3(-471.82211303711,5303.2412109375,86.032455444336)
        if (LumberjackCooldown[user_id] or 0) < os.time() then
            LumberjackCooldown[user_id] = os.time() + 10;
            vRPclient.calcPositionDist(player, {prelucratLocation}, function(distance)
                if distance <= 50 then
                    if GetLumberjackExperience(user_id) <= 1 then
                        vRP.IncreaseUserJobExperience({user_id, "Taietor de Lemne", 1})
                    end 
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Taietor de Lemne"][1])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Taietor de Lemne"][1]).."$", "info"})
                else
                    LogToDiscord("Injection Detected! [TaietorDeLemne01] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                    vRP.kickPlayer({player, "Injection Detected! [TaietorDeLemne01]"})
                end
            end)
        end
    elseif skill == 2 then
        vRPclient.calcPositionDist(player, {Config.LumberjackLocations[1][inLumberjackPlayers[user_id]][1]}, function(distance)
            if distance <= 50 then
                if (LumberjackCooldown[user_id] or 0) < os.time() then
                    LumberjackCooldown[user_id] = os.time() + 10;
                    vRP.IncreaseUserJobExperience({user_id, "Taietor de Lemne", 2})

                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Taietor de Lemne"][2])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Taietor de Lemne"][2]).."$", "info"})
                end
            else
                LogToDiscord("Injection Detected! [TaietorDeLemne02] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                vRP.kickPlayer({player, "Injection Detected! [TaietorDeLemne02]"})
            end
        end)
    elseif skill == 3 then
        local finishCoords = vector3(-555.84722900391,5388.3579101563,68.82356262207)
        vRPclient.calcPositionDist(player, {finishCoords}, function(distance)
            if distance <= 30 then
                if (LumberjackCooldown[user_id] or 0) < os.time() then
                    LumberjackCooldown[user_id] = os.time() + 10;
                    vRP.giveInventoryItem({user_id, "bustean", math.random(1, 20), true})
                    vRP.IncreaseUserJobExperience({user_id, "Taietor de Lemne", 1})
                end
            else    
                LogToDiscord("Injection Detected! [TaietorDeLemne03] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                vRP.kickPlayer({player, "Injection Detected! [TaietorDeLemne03]"})
            end
        end)
    end
end)

RegisterServerEvent("fp-lumberjack", function()
    local player = source
    local user_id = vRP.getUserId({player})
    TriggerClientEvent("fp:job-lumberjack:openmenu", player, GetLumberjackExperience(user_id))
end)