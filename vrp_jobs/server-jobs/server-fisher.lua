local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local InFisherPlayers = {}

local function GenerateFisherMission(player, user_id, skill)
    InFisherPlayers[user_id] = math.random(1, #Config.FisherLocations[skill])
    TriggerClientEvent("fp-jobs:fisher:GenerateMission", player, InFisherPlayers[user_id])
end

local function GetFisherExperience(user_id)
    local userExperience = vRP.GetUserJobExperience({user_id, "Pescar"})
    if userExperience > 750 then
        return 3
    elseif userExperience > 250 then
        return 2
    end
    return 1
end


RegisterServerEvent("fp:job-fisher", function(skill)
    local player = source
    local user_id = vRP.getUserId({player})
    if vRP.getUserHoursPlayed{user_id} >= 50 then

            if vRP.getInventoryItemAmount({user_id, "pescar_license"}) >= 1 then
            if GetFisherExperience(user_id) >= skill then
                TriggerClientEvent("FairPlay:JobChange", player, "Pescar", skill)
                SetTimeout(1000, function()
                    GenerateFisherMission(player, user_id, skill)
                end)
            end
        end
    else
        vRPclient.notify(player, {"Nu ai 50 ore !"})
    end
end)

RegisterCommand("testfisher", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserModerator({user_id}) then
        TriggerClientEvent("FairPlay:JobChange", player, "Pescar", tonumber(args[1]))
        SetTimeout(1000, function()
            GenerateFisherMission(player, user_id, tonumber(args[1]))
        end)
    else
        vRPclient.notify(player, {"Nu ai permisiunea sa folosesti aceasta comanda!", "error"})
    end
end)

RegisterServerEvent("fp-fisher:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "pescar_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Pescar pentru $10.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,10000}) then
                        vRPclient.notify(player,{"Ai platit $10.000 pentru Licenta de Pescar"})
                        vRP.giveInventoryItem({user_id,"pescar_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $10.000","error"})
                    end
                end
            end})
        end
    end
end)

local FakeItems = {
    "creanga",
    "papuc",
    "petdeplastic",
    "conserva",
}

local PescarCooldown = {}
RegisterServerEvent("fp-jobs:RewardFisher", function(skill, noReward)
    local player = source
    local user_id = vRP.getUserId({player})

    if noReward then
        GenerateFisherMission(player, user_id, skill)
        return;
    end
    
    vRPclient.calcPositionDist(player, {Config.FisherLocations[skill][InFisherPlayers[user_id]][1]}, function(distance)
        if distance <= 15 then
            if (PescarCooldown[user_id] or 0) < os.time() then
                PescarCooldown[user_id] = os.time() + 15
    
                math.randomseed(os.time() * user_id)
                local fakeOne = math.random(1, 15) <= 5
                local oneFish = table:random(Config.FisherRewards[skill], true)
                local fishAmount = 1
        
                if fakeOne then
                    oneFish = table:random(FakeItems)
                elseif oneFish == "pestisorauriu" then
                    if math.random(1, 15) <= 13 then
                        oneFish = table:random(FakeItems)
                    end
                else
                    local isGuvid = math.random(1, 5) <= 3
                    
                    if isGuvid then
                        oneFish = "guvid"
                    end
                end
        
                if vRP.canCarryItem({user_id, oneFish, fishAmount, true}) then
                    vRP.giveInventoryItem({user_id, oneFish, fishAmount, true})
                end	
    
                vRP.IncreaseUserJobExperience({user_id, "Pescar", 1})
                GenerateFisherMission(player, user_id, skill)
            else
                LogToDiscord("Injection Detected! [Fisher01] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "Pescuieste mult prea repede")
                vRP.kickPlayer({player, "Injection Detected! [Fisher01]"})
            end
        else
            LogToDiscord("Injection Detected! [Fisher02] - "..GetPlayerName(player).." - ["..user_id.."] - "..GetPlayerEndpoint(player), "A terminat pescuitul cu o distanta mai mare decat cea permisa fata de cp \n Distance: "..distance)
            vRP.kickPlayer({player, "Injection Detected! [Fisher02]"})
        end
    end)
end)

RegisterServerEvent("fp-fisher:OpenMenu", function()
    local player = source
    local user_id = vRP.getUserId({player})

    TriggerClientEvent("fp-fisher:openFisher", player, GetFisherExperience(user_id))
end)