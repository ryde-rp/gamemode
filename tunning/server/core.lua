
local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "fairplay-tunning")

RegisterServerEvent('FairPlay:Tunning:removeMoney')
AddEventHandler('FairPlay:Tunning:removeMoney', function(amount, vehicleProps)
    local player = source
    local user_id = vRP.getUserId({player})

    vRPclient.getNearestOwnedVehicle(player, {15}, function(veh)
        if veh then
            if amount > 0 and vRP.tryPayment({user_id,amount, true}) then
                vRP.setVehicleTunning({user_id, veh, json.encode(vehicleProps)})
            end
        else
            vRPclient.notify(player, {"Nu ai o masina personala in apropiere! \n Tunning-ul nu iti va fii salvat!", "error"})
        end
    end)
end)


