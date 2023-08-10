

RegisterNetEvent("vrp-deposits:populateLocations", function(allDeposit)

    for i in pairs(allDeposit) do
        
        local blip = AddBlipForCoord(allDeposit[i].pos)
        SetBlipSprite(blip, 568)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 36)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Depozit")
        EndTextCommandSetBlipName(blip)

    end

    Citizen.CreateThread(function()
        local keyActive = false
        while true do

            for k, data in pairs(allDeposit) do
                local dist = #(data.pos - pedPos)
                while dist <= 20.0 do
                    DrawMarker(27, data.pos - vec3(0.0, 0.0, 0.9), 0, 0, 0, 0, 0, 0, 0.501, 0.501, 0.5001, 255, 255, 255, 200, 0, 0, 0, 1)
                    
        
                    if dist <= 1 then
                        
                        if not keyActive then
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Depozit "..data.name.." ($"..data.fare.."/item)"})
                            keyActive = true
                        end
        
                        if IsControlJustPressed(0, 38) then
        
                            if keyActive then
                                TriggerEvent("vRP:requestKey", false)
                                keyActive = false
                            end
        
                            TriggerServerEvent("vrp-deposits:tryPayment", k)
                            Citizen.Wait(5000)
                            break
                        end
                    elseif keyActive then
                        TriggerEvent("vRP:requestKey", false)
                        keyActive = false
                    end
        
        
                    Citizen.Wait(1)
                    dist = #(data.pos - pedPos)
                end
            end
            Citizen.Wait(2000)
        end
    end)


end)