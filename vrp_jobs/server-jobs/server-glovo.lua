local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "rvd-jobs")

RegisterServerEvent("fade:jobs-Glovo", function()
    local player = source
    TriggerClientEvent("FairPlay:JobChange", player, "Livrator Glovo", 0)
end)

RegisterServerEvent("fadeGlovo:OpenMenu", function()
    local player = source
    TriggerClientEvent("fadeglovo:openGlovo", player)
end)

RegisterServerEvent("fadeGlovo:BuyLicense",function()
    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        if vRP.getInventoryItemAmount({user_id, "glovo_license"}) >= 1 then
            vRPclient.notify(player,{"Ai deja licenta","error"})
        else
            vRP.request({player,"Esti sigur ca vrei sa cumperi Licenta de Glovo pentru $100.000",15,function(pulamea,ok)
                if ok then
                    if vRP.tryPayment({user_id,100000}) then
                        vRPclient.notify(player,{"Ai platit $100.000 pentru Licenta de Glovo"})
                        vRP.giveInventoryItem({user_id,"glovo_license",1,false})
                    else
                        vRPclient.notify(player,{"Nu ai $100.000","error"})
                    end
                end
            end})
        end
    end
end)