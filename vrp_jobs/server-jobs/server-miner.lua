local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local InMinerPlayers = {}

local function GetMinerExperience(user_id)
    local userExperience = vRP.GetUserJobExperience({user_id, "Miner"})
    if userExperience > 1000 then
        return 3
    elseif userExperience > 250 then
        return 2
    end
    return 1
end

local function GenerateMinerMission(player, user_id, skill)
    math.randomseed(os.time())
    InMinerPlayers[user_id] = math.random(1, #Config.MinerLocations[skill])
    TriggerClientEvent("fp-jobs:miner:GenerateMission", player, InMinerPlayers[user_id])
end

RegisterServerEvent("fp-miner:StartJob", function(skill)
    local player = source
    local user_id = vRP.getUserId({player})
    if vRP.getUserHoursPlayed{user_id} >= 125 then
    
    if vRP.getInventoryItemAmount({user_id, "miner_license"}) >= 1 then
    if GetMinerExperience(user_id) >= skill then
        TriggerClientEvent("FairPlay:JobChange", player, "Miner", skill)
        GenerateMinerMission(player, user_id, skill)
        end
       end
    else
    vRPclient.notify(player, {"Nu ai 125 ore !"})
  end
end)

RegisterServerEvent("fp-miner:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "miner_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Miner pentru $10.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,10000}) then
                        vRPclient.notify(player,{"Ai platit $10.000 pentru Licenta de Miner"})
                        vRP.giveInventoryItem({user_id,"miner_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $10.000","error"})
                    end
                end
            end})
        end
    end
end)

local CarbuneCooldown = {}
RegisterServerEvent('FP:GiveCarbune', function()
    local player = source
    local user_id = vRP.getUserId({player})

    if (CarbuneCooldown[user_id] or 0) <= os.time() then
        CarbuneCooldown[user_id] = os.time() + 5
        if vRP.canCarryItem({user_id, "carbune", 1, true}) then
            vRP.giveInventoryItem({user_id, "carbune", math.random(3, 5), true})
        end
    else
        DropPlayer(player, "Injection Detected [kahsaa]")
    end
end)

local MinerCooldown = {}
RegisterServerEvent("fp-miner:RewardMiner", function(skill, notReward)
    local player = source
    local user_id = vRP.getUserId({player})

    if notReward then
        GenerateMinerMission(player, user_id, skill)
        return;
    end

    vRPclient.calcPositionDist(player, {Config.MinerLocations[skill][InMinerPlayers[user_id]][1]}, function(distance)
        if distance <= 15 then
            if (MinerCooldown[user_id] or 0) <= os.time() then
                if GetMinerExperience(user_id) <= skill then
                    if skill == 1 then
                        local suma = math.random(1, 2)
                        local item = table:random(Config.MinerRewards[skill], true)
            
                        if vRP.canCarryItem({user_id, item,suma, true}) then
                            vRP.giveInventoryItem({user_id, item, suma, true})
                        end
                    elseif skill == 2 then
                        local suma = math.random(1, 3)
                        local item = table:random(Config.MinerRewards[skill], true)
            
                        if vRP.canCarryItem({user_id, item,suma, true}) then
                            vRP.giveInventoryItem({user_id, item, suma, true})
                        end
                    elseif skill == 3 then
                        local chance = math.random(1, 6)
                        if chance >= 3 then
                            local suma = math.random(1, 3)

                            if vRP.canCarryItem({user_id, "minereufier",suma, true}) then
                                vRP.giveInventoryItem({user_id, "minereufier", suma, true})
                            end
                        else
                            local suma = math.random(1, 3)
                            if vRP.canCarryItem({user_id, "minereusulf",suma, true}) then
                                vRP.giveInventoryItem({user_id, "minereusulf", suma, true})
                            end
                        end
                    end
                    local sansaTarnacop = math.random(1, 15)

                    if sansaTarnacop == 5 then
                        vRP.tryGetInventoryItem({user_id, "tarnacop", 1, false})
                        vRPclient.notify(player, {"Ti s-a spart un Tarnacop :(", "warning"})
                    end

                    MinerCooldown[user_id] = os.time() + 15
                    vRP.IncreaseUserJobExperience({user_id, "Miner", 1})
                    GenerateMinerMission(player, user_id, skill)
                else
                    vRP.kickPlayer({player, "Ai incercat sa te folosesti de un exploit!"})
                end
            else
                LogToDiscord("Injection Detected! [Miner01] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "Mineaza mult prea rapid")
                vRP.kickPlayer({player, "Injection Detected! [Miner01]"})
            end
        else
            LogToDiscord("Injection Detected! [Miner02] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "Distanta mult prea mare pana la cp \n Distanta: "..math.floor(distance))
            vRP.kickPlayer({player, "Injection Detected! [Miner02]"})
        end
    end)
end)

RegisterServerEvent("fp-miner:OpenMenu", function()
    local player = source
    local user_id = vRP.getUserId({player})

    TriggerClientEvent("fp-miner:OpenMiner", player, GetMinerExperience(user_id))
end)

RegisterServerEvent("fp-miner:BuyTarnacop", function()
    local player = source
    local user_id = vRP.getUserId({player})

    vRP.request({player, "Cumpara Tarnacop<br> Vrei sa cumperi un Tarnacop pentru 100$?", false, function(_, ok)
        if ok then
            if vRP.tryPayment({user_id, 100}) then
                vRP.giveInventoryItem({user_id, "tarnacop", 1, true})
            else
                vRPclient.notify(player, {"Nu ai destui bani la tine!", "errror"})
            end
        end
    end})
end)

local itemsToSell = {
    ["lingoudeaur"] = 2600000,
    ["lingoudeargint"] = 1000000,
}

RegisterServerEvent("fp-miner:vindelingouri", function()
    local player = source
    local user_id = vRP.getUserId({player})
    local money =  0;

    for item, pret in pairs(itemsToSell) do
        local amount = vRP.getInventoryItemAmount({user_id, item})
        if amount >= 1 and vRP.tryGetInventoryItem({user_id, item, amount, true}) then
            money = money + (tonumber(amount) * pret);
        end
    end

    if money > 0 then
        vRP.giveMoney({user_id, tonumber(money)})
        vRPclient.notify(player,{"Ai primit "..tonumber(money).."$"})
        return;
    end

    vRPclient.notify(player, {"Nu ai lingouri de vandut la noi!", "error"})
end)