local bankLocations = {
    vec3(149.43438720703,-1040.0908203125,29.374090194702),
    vec3(313.83834838867,-278.31970214844,54.170776367188),
    vec3(236.71748352051,217.39555358887,106.28672027588),
    vec3(-1213.4793701172,-330.51791381836,37.786994934082),
    vec3(-2962.8125,482.26232910156,15.70308303833),
    vec3(-112.8743057251,6469.3217773438,31.626703262329),
    vec3(-351.49166870117,-49.317161560059,49.042537689209),
    vec3(1175.7092285156,2706.5112304688,38.09398651123),
}

local atmObjects = {
    -870868698,
    -1126237515,
    -1364697528,
    506770882,
}

local oneAtm = false
local atmPos = false

local function isNearAtm()
    for i = 1, #atmObjects do
        local atm = GetClosestObjectOfType(pedPos, 6.5, atmObjects[i], false, false, false)

        if DoesEntityExist(atm) then
            if atm ~= oneAtm then
                oneAtm = atm
                atmPos = GetEntityCoords(atm)
            end

            local dist = #(atmPos - pedPos)
            
            if dist <= 1.5 then
                return true
            end
        end
    end

    return false
end

local function isNearBank()
    for _, pos in pairs(bankLocations) do
        if #(pos - pedPos) <= 2.5 then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    local requestedUse = false
    while true do

        while isNearAtm() or isNearBank() do
            if not requestedUse then
                requestedUse = true
                TriggerEvent("vRP:requestKey", {key = "E", text = "Acceseaza cont bancar"})
            end

            if IsControlJustReleased(0, 51) then
                vRPserver.getBankingData({}, function(ux)
                    ExecuteCommand("e atm")
                    Wait(850)

                    TriggerEvent("vRP:interfaceFocus", true)
                    SendNUIMessage({
                        act = "interface",
                        target = "bank",

                        money = ux.money,
                        identity = ux.identity,
                        hasFaction = ux.faction,
                        factionLeader = ux.factionLeader,
                        budget = ux.budget,
                    })
                end)
            end

            Wait(1)
        end

        if requestedUse then
            TriggerEvent("vRP:requestKey", false)
            requestedUse = false
        end

        Wait(1000)
    end
end)

for k, v in pairs(bankLocations) do
    tvRP.createBlip("vRPbank:"..k, v.x, v.y, v.z, 108, 82, "Banca", 0.6)
end

RegisterNUICallback("exitBanking", function(data, cb)
    TriggerEvent("vRP:interfaceFocus", false)
    ExecuteCommand("e c")

    cb("ok")
end)

RegisterNUICallback("getBankMoney", function(data, cb)
    vRPserver.getBankMoney({}, function(um)
        cb(um)
    end)
end)

RegisterNUICallback("depositMoney", function(data, cb)
    data.amt = tonumber(data.amt or 0)
    
    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
        return TriggerServerEvent("vRP:disconnect", "Money Exploit detected")
    end
    
    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end -- cancel remote action

    vRPserver.tryBankDeposit({data.amt}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("withdrawMoney", function(data, cb)
    data.amt = tonumber(data.amt or 0)

    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
        return TriggerServerEvent("vRP:disconnect", "Money Exploit detected")
    end
    
    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end -- cancel remote action

    vRPserver.tryBankWithdraw({data.amt}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("transferMoney", function(data, cb)
    data.amt = tonumber(data.amt or 0)
    
    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
        return TriggerServerEvent("vRP:disconnect", "Money Exploit detected")
    end
    
    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end -- cancel remote action

    if (data.iban or ""):len() < 7 then
        return cb({2, "Trebuie sa introduci un IBAN valid pentru a putea efectua tranzactia."})
    end -- cancel remote action

    vRPserver.tryBankTransfer({data.iban:upper(), data.amt}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("exchangeCoins", function(data, cb)
    data.amt = tonumber(data.amt or 0)
    
    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
        return TriggerServerEvent("vRP:disconnect", "Money Exploit detected")
    end
    
    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end -- cancel remote action

    vRPserver.exchangeCoins({data.amt}, function(result)
        cb(result)
    end)
end)


RegisterNUICallback("factionWithdraw", function(data, cb)
    data.amt = tonumber(data.amt or 0)

    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end

    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end

    vRPserver.tryFactionWithdraw({data.amt}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("factionDeposit", function(data, cb)
    data.amt = tonumber(data.amt or 0)

    if data.amt < 0 then
        cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end

    if data.amt == 0 then
        return cb({2, "Trebuie sa introduci o suma valida pentru a putea efectua tranzactia."})
    end

    vRPserver.tryFactionDeposit({data.amt}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("getFactionBudget", function(data, cb)
    vRPserver.getFactionBudget({}, function(amount)
        cb(amount)
    end)
end)