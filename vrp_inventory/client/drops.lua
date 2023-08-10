-- local droppedItems = {}

-- local function DrawText3D(x,y,z, text, scl) 
--     local onScreen,_x,_y = World3dToScreen2d(x,y,z)
--     local px,py,pz = table.unpack(GetGameplayCamCoords())
--     local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)
--     local scale = (1/dist*scl)*(1/GetGameplayCamFov()*100);
   
--     if onScreen then
--         SetTextScale(0.0*scale, 1.1*scale)
--         SetTextFont(0)
--         SetTextProportional(1)
--         SetTextColour(255, 255, 255, 255)
--         SetTextDropshadow(0, 0, 0, 0, 255)
--         SetTextEdge(2, 0, 0, 0, 150)
--         SetTextDropShadow()
--         SetTextOutline()
--         SetTextEntry("STRING")
--         SetTextCentre(1)
--         AddTextComponentString(text)
--         DrawText(_x,_y)
--     end
--   end

-- RegisterNetEvent("ad-inventory:refreshDrops")
-- AddEventHandler("ad-inventory:refreshDrops", function(x)
--     droppedItems = x
-- end)


-- Citizen.CreateThread(function()
--     while true do
--         local ticks = 1024

--         for _, dropData in pairs(droppedItems) do
--             local pos = dropData.position
--             local dist = #(pos - GetEntityCoords(PlayerPedId()))
            
--             if dist <= 8 then
--                 dist = #(pos - GetEntityCoords(PlayerPedId()))

--                 if dist <= 2 then
--                     DrawText3D(pos.x, pos.y, pos.z + 0.01, "~r~E ~w~- "..dropData.label.." ~w~[~r~"..dropData.amount.."~w~]", 0.55)

--                     if IsControlJustReleased(0, 51) then
--                         TriggerServerEvent("ad-inventory:collectDrop", _)
--                         vRP.playAnim{true,{{"pickup_object","pickup_low",1}}}
--                     end
--                 end

--                 DrawMarker(20, pos.x, pos.y, pos.z - 0.30, 0, 0, 0, 0, 0, 0, 0.30, 0.30, -0.30, 0, 250, 250, 125, false, true, false, true)
--                 ticks = 1
--             end
--         end

--         Wait(ticks)
--     end
-- end)