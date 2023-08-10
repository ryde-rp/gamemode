local fuelPrice = 15
RegisterServerEvent("uVeh$startRefuel", function(cVehFuel)
    local user_id = vRP.getUserId(source)

    if cVehFuel then
        local canFuel = 100 - tonumber(cVehFuel)

        -- Litri benzina (max. "..math.floor(canFuel).. " L)

        vRP.prompt(source, "REFUEL VEHICLE", {
            {field = "muchFuel", title = "Litri benzina (max. "..math.floor(canFuel).. " L)", number = true}
        }, function(_, res)
            local muchFuel = res["muchFuel"] or 0

            if muchFuel and (muchFuel > 0) then
                if muchFuel <= tonumber(canFuel) then
                    local price = muchFuel * fuelPrice
                    if vRP.tryPayment(user_id, price, true) then
                        vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(price), "success"})
                        TriggerClientEvent("uVeh$fuelVehicle", source, muchFuel)
                    end
                else
                    vRPclient.notify(source, {"Valoare invalida!", "error"})
                end
            end
        end)
    end
end)

function tvRP.cumparaCanistra()
    local user_id = vRP.getUserId(source)
    if vRP.tryPayment(user_id, 1800, true) then
        vRPclient.notify(source, {"Ai platit $1800", "success"})
        vRP.giveInventoryItem(user_id, "fuelcan", 1, true)
        vRPclient.playAnim(source,{true,{{"mp_common","givetake1_a",1}},false})
    end
end