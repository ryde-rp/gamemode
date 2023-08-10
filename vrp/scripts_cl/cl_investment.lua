RegisterNetEvent("fp-investments:OpenMenu", function(data, hours)
    TriggerEvent("vRP:interfaceFocus", true)
    SendNUIMessage({
        act = 'interface',
        target = 'investitii',
        investData = data,
        hours = hours,
    })
end)

RegisterNUICallback("closeInvestment", function(data, cb)
    TriggerEvent("vRP:interfaceFocus", false)
    cb("muie dumpere")
end)

RegisterNUICallback("makeInvest", function(data, cb)
    TriggerServerEvent("fp-investments:MakeInvest", data.invest)
    cb("nu mai da dump")
end)

RegisterNUICallback("openInvestMenu", function(data, cb)
    TriggerServerEvent("fp-investments:RequestInvestMenu")
    cb("sugi pula dumpere")
end)