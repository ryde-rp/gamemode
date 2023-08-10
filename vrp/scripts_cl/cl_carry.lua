local piggyback = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personPiggybacking = {
		animDict = "anim@arena@celeb@flat@paired@no_props@",
		anim = "piggyback_c_player_a",
		flag = 49,
	},
	personBeingPiggybacked = {
		animDict = "anim@arena@celeb@flat@paired@no_props@",
		anim = "piggyback_c_player_b",
		attachX = 0.0,
		attachY = -0.07,
		attachZ = 0.45,
		flag = 33,
	}
}


local function checkIfPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local playerPed = tempPed
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestPed = targetPed
                closestDistance = distance
            end
        end
    end

	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer, closestPed
	end

	return nil
end

RegisterCommand("caraprieten",function(source, args)
	if tvRP.isInComa() then return tvRP.notify("Nu poti cara un prieten mort!", "error") end
	
	if not piggyback.InProgress then
		local closestPlayer, closestPed = checkIfPlayer(3)

		if closestPlayer then
			if GetEntityHealth(closestPed) < 121 then
				return tvRP.notify("Nu poti cara un prieten mort!", "error")
			end

			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				piggyback.InProgress = true
				piggyback.targetSrc = targetSrc
				TriggerServerEvent("Piggyback:sync",targetSrc)
				loadAnimDict(piggyback.personPiggybacking.animDict)
				piggyback.type = "piggybacking"

                
                CreateThread(function()
                    while piggyback.InProgress do
                        if piggyback.type == "beingPiggybacked" then
                            if not IsEntityPlayingAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 3) then
                                TaskPlayAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 8.0, -8.0, 100000, piggyback.personBeingPiggybacked.flag, 0, false, false, false)
                            end
                        elseif piggyback.type == "piggybacking" then
                            if not IsEntityPlayingAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 3) then
                                TaskPlayAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 8.0, -8.0, 100000, piggyback.personPiggybacking.flag, 0, false, false, false)
                            end
                        end
                        Wait(0)
                    end
                end)
			else
				tvRP.notify("Nu ai jucatori in jur!")
			end
		else
			tvRP.notify("Nu ai jucatori in jur!")
		end
	else
		piggyback.InProgress = false
		ClearPedSecondaryTask(tempPed)
		DetachEntity(tempPed, true, false)
		TriggerServerEvent("Piggyback:stop",piggyback.targetSrc)
		piggyback.targetSrc = 0
	end
end)

RegisterNetEvent("Piggyback:syncTarget")
AddEventHandler("Piggyback:syncTarget", function(targetSrc)
	local playerPed = tempPed
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	piggyback.InProgress = true
	loadAnimDict(piggyback.personBeingPiggybacked.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, piggyback.personBeingPiggybacked.attachX, piggyback.personBeingPiggybacked.attachY, piggyback.personBeingPiggybacked.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	piggyback.type = "beingPiggybacked"

    CreateThread(function()
        while piggyback.InProgress do
            if piggyback.type == "beingPiggybacked" then
                if not IsEntityPlayingAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 3) then
                    TaskPlayAnim(tempPed, piggyback.personBeingPiggybacked.animDict, piggyback.personBeingPiggybacked.anim, 8.0, -8.0, 100000, piggyback.personBeingPiggybacked.flag, 0, false, false, false)
                end
            elseif piggyback.type == "piggybacking" then
                if not IsEntityPlayingAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 3) then
                    TaskPlayAnim(tempPed, piggyback.personPiggybacking.animDict, piggyback.personPiggybacking.anim, 8.0, -8.0, 100000, piggyback.personPiggybacking.flag, 0, false, false, false)
                end
            end

            Wait(1)
        end
    end)
end)

RegisterNetEvent("Piggyback:cl_stop")
AddEventHandler("Piggyback:cl_stop", function()
	piggyback.InProgress = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)

local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {
		animDict = "missfinale_c2mcs_1",
		anim = "fin_c2_mcs_1_camman",
		flag = 49,
	},
	personCarried = {
		animDict = "nm",
		anim = "firemans_carry",
		attachX = 0.27,
		attachY = 0.15,
		attachZ = 0.63,
		flag = 33,
	}
}

local function carryFuncs()
	while carry.InProgress do
		if carry.type == "beingcarried" then
			if not IsEntityPlayingAnim(tempPed, carry.personCarried.animDict, carry.personCarried.anim, 3) then
				TaskPlayAnim(tempPed, carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
			end
		elseif carry.type == "carrying" then
			if not IsEntityPlayingAnim(tempPed, carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
				TaskPlayAnim(tempPed, carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, 100000, carry.personCarrying.flag, 0, false, false, false)
			end
		end

		Wait(1)
	end
end

RegisterCommand("cara",function(source, args)
	if tvRP.isInComa() then return tvRP.notify("Nu poti cara un om mort!", "error") end
	
	if not carry.InProgress then
		local closestPlayer = checkIfPlayer(3)

		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent("CarryPeople:sync",targetSrc)
				loadAnimDict(carry.personCarrying.animDict)
				carry.type = "carrying"

				Citizen.CreateThreadNow(carryFuncs)
			else
				tvRP.notify("Niciun jucator prin preajma!", "warning")
			end
		else
			tvRP.notify("Niciun jucator prin preajma!", "warning")
		end
	else
		carry.InProgress = false
		ClearPedSecondaryTask(tempPed)
		DetachEntity(tempPed, true, false)
		TriggerServerEvent("CarryPeople:stop",carry.targetSrc)
		carry.targetSrc = 0
	end
end)

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	carry.InProgress = true
	loadAnimDict(carry.personCarried.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	carry.type = "beingcarried"

	Citizen.CreateThreadNow(carryFuncs)
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
	carry.InProgress = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)