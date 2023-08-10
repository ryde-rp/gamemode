local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local inConstructorPlayers = {}

local function GetConstructorExperience(user_id)
    local userSkill = vRP.GetUserJobExperience({user_id, "Constructor"})
    if userSkill >= 500 then
        return 3
    elseif userSkill >= 200 then
        return 2
    end
    return 1
end

local function GenerateConstructorMission(player, user_id, skill)
    math.randomseed(os.time());
    if skill == 1 then
        inConstructorPlayers[user_id] = math.random(1, #Config.ConstructorLocations[1])
        TriggerClientEvent("fp-constructor:GenerateLevelOne", player, inConstructorPlayers[user_id])
    elseif skill == 2 then
        inConstructorPlayers[user_id] = math.random(1, #Config.ConstructorLocations[2])
        TriggerClientEvent("fp-constructor:GenerateLevelTwo", player, inConstructorPlayers[user_id])
    elseif skill == 3 then
        inConstructorPlayers[user_id] = math.random(1, #Config.ConstructorLocations[3])
        TriggerClientEvent("fp-constructor:GenerateLevelThree", player, inConstructorPlayers[user_id])
    end
end

RegisterServerEvent("fp:jobs-constructor", function(skill)
    local player = source
    local user_id = vRP.getUserId({player})
 if vRP.getUserHoursPlayed{user_id} >= 50 then

    if vRP.getInventoryItemAmount({user_id, "constructor_license"}) >= 1 then
    if GetConstructorExperience(user_id) >= skill then

        TriggerClientEvent("FairPlay:JobChange", player, "Constructor", skill)
        if skill ~= 1 then
            SetTimeout(1000, function()
                GenerateConstructorMission(player, user_id, skill)
            end)
        end
    end
end
    else
  vRPclient.notify(player, {"Nu ai 50 ore !"})
    end
end)

RegisterCommand("testconstructor", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        local skill = tonumber(args[1])
        TriggerClientEvent("FairPlay:JobChange", player, "Constructor", skill)
        if skill ~= 1 then
            SetTimeout(1000, function()
                GenerateConstructorMission(player, user_id, skill)
            end)
        end
    end
end)

RegisterServerEvent("fp-constructor:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "constructor_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Constructor pentru $10.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,10000}) then
                        vRPclient.notify(player,{"Ai platit $10.000 pentru Licenta de Constructor"})
                        vRP.giveInventoryItem({user_id,"constructor_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $10.000","error"})
                    end
                end
            end})
        end
    end
end)


local ConstructorCooldowns = {}
RegisterServerEvent("fp-constructor:reward", function(skill, noReward)
    local player = source
    local user_id = vRP.getUserId({player})

    if noReward then
        GenerateConstructorMission(player, user_id, skill)
        return;
    end

    if skill == 1 then
        vRPclient.calcPositionDist(player, {Config.ConstructorLocations[1][inConstructorPlayers[user_id]][1]}, function(distance)
            if distance <= 15 then
                if (ConstructorCooldowns[user_id] or 0) <= os.time() then
                    if GetConstructorExperience(user_id) <= 1 then
                        vRP.IncreaseUserJobExperience({user_id, "Constructor", 1})
                    end
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Constructor"][1])})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Constructor"][1]).."$", "info"})
                    ConstructorCooldowns[user_id] = os.time() + 7;
                else
                    LogToDiscord("Injection Detected! [Constructor04] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Lucreaza mult prea rapid, nu apuca cooldown-ul sa expire")
                    vRP.kickPlayer({player, "Injection Detected! [Constructor04]"})
                end
            else
                LogToDiscord("Injection Detected! [Constructor01] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                vRP.kickPlayer({player, "Injection Detected! [Constructor01]"})
            end
        end)
    elseif skill == 2 then
        vRPclient.calcPositionDist(player, {Config.ConstructorLocations[2][inConstructorPlayers[user_id]].Location}, function(distance)
            if distance <= 70 then
                if (ConstructorCooldowns[user_id] or 0) <= os.time() then
                    ConstructorCooldowns[user_id] = os.time() + 7;
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Constructor"][2])})
                    vRP.IncreaseUserJobExperience({user_id, "Constructor", 1})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Constructor"][2]).."$", "info"})
                    GenerateConstructorMission(player, user_id, skill)
                else
                    LogToDiscord("Injection Detected! [Constructor07] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Lucreaza mult prea rapid, nu apuca cooldown-ul sa expire")
                    vRP.kickPlayer({player, "Injection Detected! [Constructor07]"})
                end
            else
                LogToDiscord("Injection Detected! [Constructor02] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                vRP.kickPlayer({player, "Injection Detected! [Constructor02]"})
            end
        end)
    elseif skill == 3 then
        vRPclient.calcPositionDist(player, {Config.ConstructorLocations[3][inConstructorPlayers[user_id]].Location}, function(distance)
            if distance <= 50 then
                if (ConstructorCooldowns[user_id] or 0) <= os.time() then
                    ConstructorCooldowns[user_id] = os.time() + 15;
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Constructor"][3])})
                    vRP.IncreaseUserJobExperience({user_id, "Constructor", 1})
                    vRPclient.notify(player, {"Ai primit "..tonumber(Config.JobMoneys["Constructor"][3]).."$", "info"})
                    GenerateConstructorMission(player, user_id, skill)
                else
                    LogToDiscord("Injection Detected! [Constructor05] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Lucreaza mult prea rapid, nu apuca cooldown-ul sa expire")
                    vRP.kickPlayer({player, "Injection Detected! [Constructor05]"})
                end
            else
                LogToDiscord("Injection Detected! [Constructor03] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
                vRP.kickPlayer({player, "Injection Detected! [Constructor03]"})
            end
        end)
    end
end)

RegisterServerEvent("fp-constructor:OpenMenu", function()
    local player = source
    local user_id = vRP.getUserId({player})

    TriggerClientEvent("fp-constructor:OpenConstructor", player, GetConstructorExperience(user_id))
end)