local usingOne = false
local dMachines = {
	992069095, -- prop_vend_soda (1),
	1114264700, -- prop_vend_soda (2),
	1099892058, -- prop_vend_water,
}

local fMachines = {
	-654402915, -- prop_vend_snak,
	-1034034125, -- prop_vend_snak_tu,
}

Citizen.CreateThread(function()
	while true do
		    
		for _, theMachine in pairs(dMachines) do
            local drinkObj = GetClosestObjectOfType(pedPos, 1.0, theMachine, false, false)
            
            if drinkObj ~= 0 then
            	local drinkPos = GetEntityCoords(drinkObj)

            	while #(drinkPos - pedPos) <= 1.5 do
            		DrawText3D(drinkPos.x, drinkPos.y, drinkPos.z, "~b~E ~w~- Cumpara Apa (~b~$5~w~)", 0.5)

            		if IsControlJustReleased(0, 51) then
            			if not usingOne then
	            			CreateThread(function()
	            				usingOne = true
								TaskTurnPedToFaceEntity(tempPed, drinkObj, -1)

								loadAnimDict("mini@sprunk")
								RequestAmbientAudioBank("VENDING_MACHINE")
								HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
								SetPedCurrentWeaponVisible(tempPed, false, true, 1, 0)
								
								RequestModel("prop_ld_flow_bottle")
								while not HasModelLoaded("prop_ld_flow_bottle") do
									Wait(1)
								end

								SetPedResetFlag(tempPed, 322, true)
								TaskTurnPedToFaceEntity(tempPed, drinkObj, -1)
								Wait(1000)

								TaskPlayAnim(tempPed, "mini@sprunk", "plyr_buy_drink_pt1", 8.0, 5.0, -1, true, 1, 0, 0, 0)
								Wait(2500)

								local cModel = CreateObjectNoOffset("prop_ld_flow_bottle", drinkPos, true, false, false)
								SetEntityAsMissionEntity(cModel, true, true)
								SetEntityProofs(cModel, false, true, false, false, false, false, 0, false)
								AttachEntityToEntity(cModel, tempPed, GetPedBoneIndex(tempPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)

								TriggerServerEvent("vendingMachines$getWater")

								Wait(1700)
								loadAnimDict("mp_common_miss")
								TaskPlayAnim(tempPed, "mp_common_miss", "put_away_coke", 8.0, 5.0, -1, true, 1, 0, 0, 0)

								Wait(1000)
								ClearPedTasks(tempPed)
								ReleaseAmbientAudioBank()

								if DoesEntityExist(cModel) then
									DetachEntity(cModel, true, true)
									DeleteEntity(cModel)
								end

								usingOne = false
							end)
	            		end
            		end

            		Wait(1)
            	end
            end
        end

		for _, theMachine in pairs(fMachines) do
            local foodObj = GetClosestObjectOfType(pedPos, 1.0, theMachine, false, false)
            
            if foodObj ~= 0 then
            	local foodPos = GetEntityCoords(foodObj)

            	while #(foodPos - pedPos) <= 1.0 do
            		DrawText3D(foodPos.x, foodPos.y, foodPos.z, "~y~E ~w~- Cumpara Sandwich (~y~$10~w~)", 0.5)

            		if IsControlJustReleased(0, 51) then
            			if not usingOne then
	            			CreateThread(function()
	            				usingOne = true
								TaskTurnPedToFaceEntity(tempPed, foodObj, -1)

								loadAnimDict("mini@sprunk")
								RequestAmbientAudioBank("VENDING_MACHINE")
								HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
								SetPedCurrentWeaponVisible(tempPed, false, true, 1, 0)
								
								RequestModel("prop_sandwich_01")
								while not HasModelLoaded("prop_sandwich_01") do
									Wait(1)
								end

								SetPedResetFlag(tempPed, 322, true)
								TaskTurnPedToFaceEntity(tempPed, foodObj, -1)
								Wait(1000)

								TaskPlayAnim(tempPed, "mini@sprunk", "plyr_buy_drink_pt1", 8.0, 5.0, -1, true, 1, 0, 0, 0)
								Wait(2500)

								local cModel = CreateObjectNoOffset("prop_sandwich_01", foodPos, true, false, false)
								SetEntityAsMissionEntity(cModel, true, true)
								SetEntityProofs(cModel, false, true, false, false, false, false, 0, false)
								AttachEntityToEntity(cModel, tempPed, GetPedBoneIndex(tempPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)

								TriggerServerEvent("vendingMachines$getSandwich")

								Wait(1700)
								loadAnimDict("mp_common_miss")
								TaskPlayAnim(tempPed, "mp_common_miss", "put_away_coke", 8.0, 5.0, -1, true, 1, 0, 0, 0)

								Wait(1000)
								ClearPedTasks(tempPed)
								ReleaseAmbientAudioBank()

								if DoesEntityExist(cModel) then
									DetachEntity(cModel, true, true)
									DeleteEntity(cModel)
								end

								usingOne = false
							end)
            			end
            		end

            		Wait(1)
            	end
            end
        end

		Wait(800)
	end
end)

RegisterNetEvent("vRP:useRedbullOrCoffee", function()
	ResetPlayerStamina(PlayerId())
end)