RegisterCommand("shop", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        act = "server-shop",
    })
end)

RegisterNUICallback("server-shop:destroy", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("server-shop:buy", function(data, cb)
    TriggerServerEvent("FP:BuyPremiumThing", data.item, data.code)
    cb("ok")
end)

RegisterNUICallback("server-shop:getCoins", function(data, cb)
    vRPserver.GetUserPremiumCoins({}, function(coins)
        cb(coins)
    end)
end)