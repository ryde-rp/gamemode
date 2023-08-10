RegisterNetEvent("vrp-markets:openShop", function(gtype, items, money, name)
    TriggerEvent("vRP:interfaceFocus", true)
    SendNUIMessage({
        act = "interface",
        target = "market",
        data = {gtype, items, money, name}
    })
end)

RegisterNUICallback("exitMarket", function(data, cb)
    TriggerEvent("vRP:interfaceFocus", false)

    if data[1] then
        TriggerServerEvent("vrp-markets:payBasket", data[1], (data[2] or "cash"), data[3])
    end

    cb("ok")
end)