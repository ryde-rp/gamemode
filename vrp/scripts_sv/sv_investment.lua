local ActiveInvestments = {}

local InvestitionTime = os.time() + 600

local Investments = {
    {
        invest = 5000,
        time = 1,
    },
    {
        invest = 12500,
        time = 2,
    },
    {
        invest = 20000,
        time = 3,
    },
    {
        invest = 27500,
        time = 4,
    },
    {
        invest = 37500,
        time = 5,
    },
    {
        invest = 50000,
        time = 6,
    },
    {
        invest = 100000,
        time = 7,
    },
    {
        invest = 200000,
        time = 8,
    },
    {
        invest = 225000,
        time = 9,
    },
    {
        invest = 375000,
        time = 10,
    },
    {
        invest = 475000,
        time = 12,
    }
}

RegisterCommand("debuginvest", function(player)
    if player == 0 then
        for user_id, data in pairs(ActiveInvestments) do
            print(user_id, json.encode(data))
        end
    end
end)

RegisterServerEvent("fp-investments:MakeInvest", function(index)
    local player = source
    local user_id = vRP.getUserId(player)

    index = tonumber(index)
    if ActiveInvestments[user_id] then return vRPclient.notify(player, {"Ai deja o investitie activa!", "error"}) end

    local investedMoney = Investments[index].invest
    if vRP.tryPayment(user_id,tonumber(investedMoney)) then
        ActiveInvestments[user_id] = {
            invest = index,
            investMoney = tonumber(investedMoney),
            investTime = tonumber(Investments[index].time),
            currentInvestTime = 0,
            finishTime = os.time() + (1*24*60*60),
        }
        exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
            ['@id'] = user_id,
            ['@investition'] = json.encode(ActiveInvestments[user_id])
        })
        vRP.createLog(user_id, "A inceput o investitie in valoare de "..investedMoney.." care se va termina in "..tonumber(Investments[index].time).." ore jucate.", "Invests", "Made-Invest", "fa-solid fa-file-invoice", 0,"failed")	
        exports["vrp_phone"]:sendPhoneInfo(player, "Ai investit $"..vRP.formatMoney(investedMoney), "Investiții")
    else
        vRPclient.notify(player, {"Nu ai destui bani pentru a putea face investitia!", "error"})
    end
end)

local function InvestitionIncrease()
	Citizen.CreateThread(function()
		SetTimeout(5000, InvestitionIncrease)
	end)

    if os.time() >= InvestitionTime then
        InvestitionTime = os.time() + 600
        -- print("^7FP SYSTEM: ^2Investitiile au fost actualizate^7")
        Citizen.CreateThread(function()
            for user_id, data in pairs(ActiveInvestments) do
                if data.finishTime > os.time() then
                    local player = vRP.getUserSource(user_id)
                    local hasFinishedInvest = (data.investTime - data.currentInvestTime) <= 0
                    if hasFinishedInvest then
                        vRP.giveMoney(user_id,tonumber(tonumber(data.investMoney) * 2))
                        vRPclient.notify(player, {"Ai primit "..vRP.formatMoney(tonumber(tonumber(data.investMoney) * 2)).."$ in urma unei investitii facute", "success"})
    
                        vRP.createLog(user_id, "A primit "..vRP.formatMoney(tonumber(tonumber(data.investMoney) * 2)).."$ in urma unei investitii facute", "Invests", "Receive-Invest", "fa-solid fa-sack-dollar", 0,"success")	
                        ActiveInvestments[user_id] = nil
                        exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
                            ['@id'] = user_id,
                            ['@investition'] = NULL
                        })
                    else
                        data.currentInvestTime = data.currentInvestTime + 0.18
                        local hasFinishedInvest = (data.investTime - data.currentInvestTime) <= 0
                        if hasFinishedInvest then
                            local player = vRP.getUserSource(user_id)
                            vRP.giveMoney(user_id,tonumber(tonumber(data.investMoney) * 2))
                            vRPclient.notify(player, {"Ai primit "..vRP.formatMoney(tonumber(tonumber(data.investMoney) * 2)).."$ in urma unei investitii facute", "success"})
        
                            vRP.createLog(user_id, "A primit "..vRP.formatMoney(tonumber(tonumber(data.investMoney) * 2)).."$ in urma unei investitii facute", "Invests", "Receive-Invest", "fa-solid fa-sack-dollar", 0,"success")	
                            ActiveInvestments[user_id] = nil
                            exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
                                ['@id'] = user_id,
                                ['@investition'] = NULL
                            })
                        end
                    end
                else
                    local player = vRP.getUserSource(user_id)
                    if player then
                        vRP.createLog(user_id, "A pierdut o investitie deoarece nu a fost terminata la timp", "Invests", "Lose-Invest", "fa-solid fa-file-invoice", 0,"failed")
                        vRPclient.notify(player, {"Nu ti-ai terminat investitia la timp! Bani investiti au fost pierduti!", "error"})
                        ActiveInvestments[user_id] = nil
                        exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
                            ['@id'] = user_id,
                            ['@investition'] = NULL
                        })
                    end
                end
            end
        end)
    end
end InvestitionIncrease()

RegisterServerEvent("fp-investments:RequestInvestMenu", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if ActiveInvestments[user_id] then
        TriggerClientEvent("fp-investments:OpenMenu", player, ActiveInvestments[user_id], ActiveInvestments[user_id].currentInvestTime)
    else
        TriggerClientEvent("fp-investments:OpenMenu", player, false, 0)
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        exports.oxmysql:query('SELECT investition FROM users WHERE id = @id', {['@id'] = user_id}, function(investition)
            if investition[1].investition then
                local parsedInvestment = json.decode(investition[1].investition)
                if parsedInvestment.finishTime > os.time() then
                    ActiveInvestments[user_id] = parsedInvestment
                    vRPclient.notify(player, {"Ai o investitie activa care se va termina in "..math.floor((parsedInvestment.investTime - parsedInvestment.currentInvestTime)).." ore", "info"})
                else
                    vRPclient.notify(player, {"Nu ti-ai terminat investitia la timp! Bani investiti au fost pierduti!", "error"})
                    exports.oxmysql:execute('UPDATE users SET investition = NULL WHERE id = ?', {user_id})
                end
            end
        end)
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if ActiveInvestments[user_id] then
        exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
            ['@id'] = user_id,
            ['@investition'] = json.encode(ActiveInvestments[user_id])
        })
        ActiveInvestments[user_id] = nil
    end
end)


RegisterCommand("setInvest", function(player, args)
    if player == 0 then
        local user_id = parseInt(args[1])
        local UserInvest = {
            invest = 1,
            investMoney = tonumber(5000),
            investTime = tonumber(Investments[1].time),
            currentInvestTime = 0,
            finishTime = os.time() + (1*24*60*60),
        }
        exports.oxmysql:execute("UPDATE users SET investition = @investition WHERE id = @id",{
            ['@id'] = user_id,
            ['@investition'] = json.encode(UserInvest)
        })

        print("Investitie setata pentru "..user_id)
    end
end)