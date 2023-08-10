local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local InElectricianPlayers = {}

local function GetElectricianExperience(user_id)
    local userSkill = vRP.GetUserJobExperience({user_id, "Electrician"})
    if userSkill > 420 then
        return 3
    elseif userSkill > 300 then
        return 2
    end
    return 1
end

local function GenerateElectricianMission(player, user_id, skill)
    math.randomseed(os.time())
    if skill == 1 then
        InElectricianPlayers[user_id] = math.random(1, #Config.ElectricianLocations[1])
        TriggerClientEvent("fp-electrician:GenerateElectricianLevelOne", player, InElectricianPlayers[user_id])
    elseif skill == 2 then
        InElectricianPlayers[user_id] = math.random(1, #Config.ElectricianLocations[2])
        TriggerClientEvent("fp-electrician:GenerateElectricianLevelTwo", player, InElectricianPlayers[user_id])
    elseif skill == 3 then
        InElectricianPlayers[user_id] = math.random(1, #Config.ElectricianLocations[3])
        TriggerClientEvent("fp-electrician:GenerateElectricianLevelThree", player, InElectricianPlayers[user_id])
    end
end

RegisterServerEvent("fp:job-electrician", function(userSkill)
    local player = source
    local user_id = vRP.getUserId({player})
    if vRP.getUserHoursPlayed{user_id} >= 25 then


    if vRP.getInventoryItemAmount({user_id, "electrician_license"}) >= 1 then
    if GetElectricianExperience(user_id) >= userSkill then
        TriggerClientEvent("FairPlay:JobChange", player, "Electrician", userSkill)
        SetTimeout(1000, function()
            GenerateElectricianMission(player, user_id, userSkill)
        end)
    end
end
    else
        vRPclient.notify(player, {"Nu ai 25 ore !"})
    end
end)

RegisterCommand("testelec", function(player, args)
    local skill = tonumber(args[1])
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        TriggerClientEvent("FairPlay:JobChange", player, "Electrician", skill)
        SetTimeout(1000, function()
            GenerateElectricianMission(player, user_id, skill)
        end)
    end
end)

RegisterServerEvent("fp-electrician:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "electrician_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Electrician pentru $10.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,10000}) then
                        vRPclient.notify(player,{"Ai platit $10.000 pentru Licenta de Electrician"})
                        vRP.giveInventoryItem({user_id,"electrician_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $10.000","error"})
                    end
                end
            end})
        end
    end
end)

RegisterServerEvent("fp-electrician:RewardElectrician", function(skill, noReward)
    local player = source
    local user_id = vRP.getUserId({player})

    local playerCoords = GetEntityCoords(GetPlayerPed(player))

    if noReward then
        GenerateElectricianMission(player, user_id, skill)
        return;
    end

    if GetElectricianExperience(user_id) >= skill then
        if skill == 1 then
            vRPclient.calcPositionDist(player, {Config.ElectricianLocations[1][InElectricianPlayers[user_id]][1]}, function(distance)
                if distance <= 100 then
                    if GetElectricianExperience(user_id) <= 1 then
                        vRP.IncreaseUserJobExperience({user_id, "Electrician", 1})
                    end

                    GenerateElectricianMission(player, user_id, skill)
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Electrician"][1])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Electrician"][1]).."$", "info"})
                else
                    LogToDiscord("Injection Detected! [Electrician01] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                    vRP.kickPlayer({player, "Injection Detected! [Electrician01]"})
                end
            end)
        elseif skill == 2 then
            vRPclient.calcPositionDist(player, {Config.ElectricianLocations[2][InElectricianPlayers[user_id]][1]}, function(distance)
                if distance <= 70 then
                    vRP.IncreaseUserJobExperience({user_id, "Electrician", 2})
                    GenerateElectricianMission(player, user_id, skill)
    
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Electrician"][2])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Electrician"][2]).."$", "info"})
                else
                    LogToDiscord("Injection Detected! [Electrician02] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                    vRP.kickPlayer({player, "Injection Detected! [Electrician02]"})
                end
            end)
        elseif skill == 3 then 
            vRPclient.calcPositionDist(player, {Config.ElectricianLocations[3][InElectricianPlayers[user_id]][1]}, function(distance)
                if distance <= 70 then
                    vRP.IncreaseUserJobExperience({user_id, "Electrician", 1})
                    GenerateElectricianMission(player, user_id, skill)
    
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Electrician"][3])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Electrician"][3]).."$", "info"})
                else
                    LogToDiscord("Injection Detected! [Electrician03] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                    vRP.kickPlayer({player, "Injection Detected! [Electrician03]"})
                end
            end)
        end
    else
        LogToDiscord("Injection Detected! [Electrician04] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Skill-ul nu corespunde cu cel din baza de date")
        vRP.kickPlayer({player, "Injection Detected! [Electrician04]"})
    end
end)

RegisterServerEvent("fp-electrician:OpenMenu", function()
    local player = source
    local user_id = vRP.getUserId({player})

    TriggerClientEvent("fp-electrician:OpenElectrician", player, GetElectricianExperience(user_id))
end)