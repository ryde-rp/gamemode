local libraryGet = {["Proxy"] = module("vrp", "lib/Proxy"), ["Tunnel"] = module("vrp", "lib/Tunnel")};
vRP, vRPclient = libraryGet["Proxy"]["getInterface"]('vRP'), libraryGet["Tunnel"]["getInterface"]('vRP', GetCurrentResourceName());

local inPacanele, hasGTM = {}, {};

RegisterServerEvent('slots:server:enterSl', function()
    local user_id = vRP.getUserId({source});
    if not user_id then return end;
    inPacanele[user_id] = true;
end)

RegisterServerEvent('slots:server:checkForMoney', function(bet)
    local user_id = vRP.getUserId({source});
    if not user_id then return end;
    if bet % 10 ~= 0 and bet < 10 then return vRPclient.notify(source,{"Info: Trebuie sa ai o multipla de 10. Ex: 10, 60, 100"}) end;
    if not vRP.tryPayment({user_id, bet}) then return vRPclient.notify(source,{"Info: Nu ai destui bani!"}) end;
    TriggerClientEvent('slots:client:updateSlots', source, bet);
end)

RegisterServerEvent('slots:server:payRewards', function(amount)
    local user_id = vRP.getUserId({source});
    if not user_id then return end; amount = tonumber(amount);
    if amount >= 2148483647 then DropPlayer(source, "Exploit Detected [slots:server:payRewards] [haiperAC]") end;
    if amount == 0 then hasGTM[user_id] = true; return inPacanele[user_id] == false; end;
    if not amount then return vRPclient.notify(source,{"Info: Din nefericire ai pierdut toti banii fii mai atent!.."}) end;
    if not inPacanele[user_id] then return DropPlayer(source, "Exploit Detected [slots:server:payRewards] [haiperAC]") end;
    if hasGTM[user_id] then return DropPlayer(source, "Exploit Detected [slots:server:payRewards] [haiperAC]") end;
    vRP.sendToDis{vRP.getGlobalStateLogs{}['Inventory']['Pacanele'], 'Tropical Burning Hot', user_id..' a castigat '..amount..'$ la pacanele, ai grija sa nu fie din triggere <3'};
    vRP.giveMoney{user_id,amount}; vRPclient.notify(source,{"Info: Ai primit $" .. tostring(amount) .. " din pacanele!"}); hasGTM[user_id] = true; inPacanele[user_id] = false;
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000);
        for user_id in next, vRP.getUsers({}) do
            while hasGTM[user_id] do
                Wait(1000);
                print(hasGTM[user_id]);
                hasGTM[user_id] = false;
            end
        end
    end
end)