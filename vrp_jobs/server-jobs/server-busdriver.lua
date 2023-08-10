local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local finishPos = vector3(471.51501464844,-582.11981201172,28.499822616578)

local function GetBusDriverExperience(user_id)
    local userExperience = vRP.GetUserJobExperience({user_id, "Sofer de Autobuz"})
    if userExperience > 120 then
        return 3
    elseif userExperience > 60 then
        return 2
    end
    return 1
end

local BusDriverCooldown = 0
RegisterServerEvent("fp:job-busdriver", function(userSkill)
    local player = source
    local user_id = vRP.getUserId({player})

    if vRP.getInventoryItemAmount({user_id, "sofer_autobuz_license"}) >= 1 then

    if (BusDriverCooldown or 0) < os.time() then
        BusDriverCooldown = os.time() + 15
        if GetBusDriverExperience(user_id) >= userSkill  then
            TriggerClientEvent("FairPlay:JobChange", player, "Sofer de Autobuz", userSkill)
        end
    else
        vRPclient.notify(player, {"Este cooldown activ, asteapta "..BusDriverCooldown - os.time().." secunde inainte sa incepi o cursa!", "error"})
    end
end
end)

RegisterCommand("testbus", function(player, args)
    local user_id = vRP.getUserId({player})
    if vRP.isUserMod({user_id}) then
        TriggerClientEvent("FairPlay:JobChange", player, "Sofer de Autobuz", parseInt(args[1]))
    else
        vRPclient.notify(player, {"Nu ai acces la aceasta comanda!", "error"})
    end
end)

RegisterServerEvent("fp:job-busdriver:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "sofer_autobuz_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de BusDriver pentru $100.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,100000}) then
                        vRPclient.notify(player,{"Ai platit $100.000 pentru Licenta de BusDriver"})
                        vRP.giveInventoryItem({user_id,"sofer_autobuz_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $100.000","error"})
                    end
                end
            end})
        end
    end
end)

local BusDriverCooldown = {}
RegisterServerEvent("fp:job-busdriver-finish", function(skill)
    local player = source
    local user_id = vRP.getUserId({player})

    vRPclient.calcPositionDist(player, {finishPos}, function(distance)
        if distance <= 15 then
            if (BusDriverCooldown[user_id] or 0) < os.time() then
                BusDriverCooldown[user_id] = os.time() + 60 * 5
                if skill == 1 then
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Sofer de Autobuz"][1])})
                    if GetBusDriverExperience(user_id) <= 1 then
                        vRP.IncreaseUserJobExperience({user_id, "Sofer de Autobuz", 1})
                    end
                elseif skill == 2 then
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Sofer de Autobuz"][2])})
                    vRP.IncreaseUserJobExperience({user_id, "Sofer de Autobuz", 2})
                elseif skill == 3 then
                    vRP.giveMoney({user_id,tonumber(Config.JobMoneys["Sofer de Autobuz"][3])})
                    vRP.IncreaseUserJobExperience({user_id, "Sofer de Autobuz", 2})
                end
            else
                LogToDiscord("Injection Detected! [BusDriver01] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "A terminat cursa mai rapid decat ar fii trebuit sa se intample asta")
                vRP.kickPlayer({player, "Injection Detected! [BusDriver01]"})
            end
        else
            LogToDiscord("Injection Detected! [BusDriver02] - "..GetPlayerName(player).." - "..user_id.." - "..GetPlayerEndpoint(player), "A terminat cursa cu o distanta mai mare decat cea permisa fata de locatia de finish")
            vRP.kickPlayer({player, "Injection Detected! [BusDriver02]"})
        end
    end)
end)

RegisterServerEvent("fp:job-busdriver:openmenu", function()
    local player = source
    local user_id = vRP.getUserId({player})
    TriggerClientEvent("fp-bus:openBus", player, GetBusDriverExperience(user_id))
end)