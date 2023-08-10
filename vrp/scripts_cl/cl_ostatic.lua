local takeHostage = {
	allowedWeapons = {
		"WEAPON_PISTOL",
		"WEAPON_COMBATPISTOL",
		"WEAPON_VINTAGEPISTOL",
		"WEAPON_DOUBLEACTION",
		"WEAPON_PISTOL_MK2",
		"WEAPON_KNIFE",
		"WWEAPON_BOTTLE",
		"WEAPON_SWITCHBLADE",
		"WEAPON_DAGGER",
		"WEAPON_MACHINEPISTOL",
		"WEAPON_GADGETPISTOL",
		"WEAPON_NAVYREVOLVER",
	},

	InProgress = false,
	type = "",
	targetSrc = -1,
	targetPed = -1,
	agressor = {
		animDict = "anim@gangops@hostage@",
		anim = "perp_idle",
		flag = 49,
	},
	
	hostage = {
		animDict = "anim@gangops@hostage@",
		anim = "victim_idle",
		attachX = -0.24,
		attachY = 0.11,
		attachZ = 0.0,
		flag = 49,
	}
}

local foundWeap = false
local function checkIfHostage(oRadius)
    local players = GetActivePlayers()
    local cDist = -1
    local closestPlayer = -1
    local closestPed = -1
    local playerPed = tempPed
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            
            if cDist == -1 or cDist > distance then
                closestPlayer = playerId
                closestPed = targetPed
                cDist = distance
            end
        end
    end

	if cDist ~= -1 and cDist <= oRadius then
		return closestPlayer, closestPed
	end

	return nil
end

RegisterCommand("ostatic", function()
	initOstatic()
end)

RegisterCommand("o", function()
	initOstatic()
end)

local function hostageFuncs()
	while takeHostage.type do 
		local HostageTaken = false

		if takeHostage.type == "agressor" then
			HostageTaken = true
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,21,true) -- disable sprint
			DisablePlayerFiring(tempPed, true)

			local hostageCds = GetEntityCoords(takeHostage.targetPed)
			DrawText3D(hostageCds.x, hostageCds.y, hostageCds.z + 0.250, "~b~G ~w~- Elibereaza~n~~HC_28~H ~w~- Ucide ostatic", 0.8)

			if IsEntityDead(tempPed) then	
				takeHostage.type = false
				takeHostage.InProgress = false
				loadAnimDict("reaction@shove")
				TaskPlayAnim(tempPed, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("fp-hostageTasks:releaseHostage", takeHostage.targetSrc)
			end 

			if IsDisabledControlJustPressed(0,47) then --release	
				takeHostage.type = false
				takeHostage.InProgress = false 
				loadAnimDict("reaction@shove")
				TaskPlayAnim(tempPed, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("fp-hostageTasks:releaseHostage", takeHostage.targetSrc)
			elseif IsDisabledControlJustPressed(0,74) then --kill 			
				takeHostage.type = false
				takeHostage.InProgress = false 		
				loadAnimDict("anim@gangops@hostage@")
				TaskPlayAnim(tempPed, "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("fp-hostageTasks:killHostage", takeHostage.targetSrc)
				TriggerServerEvent("fp-hostageTasks:stop",takeHostage.targetSrc)
				Wait(100)
				SetPedShootsAtCoord(tempPed, 0.0, 0.0, 0.0, 0)
			end
		elseif takeHostage.type == "hostage" then 
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		end

		if takeHostage.type == "agressor" then
			if not IsEntityPlayingAnim(tempPed, takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				TaskPlayAnim(tempPed, takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			end
		elseif takeHostage.type == "hostage" then
			if not IsEntityPlayingAnim(tempPed, takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				TaskPlayAnim(tempPed, takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			end
		end
		
		Wait(1)
	end
end

function initOstatic()
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)

	local canTakeHostage = false
	for _, theWeap in pairs(takeHostage.allowedWeapons) do
		if HasPedGotWeapon(tempPed, theWeap, false) then
			canTakeHostage = true 
			foundWeap = theWeap
			break
		end
	end

	if not canTakeHostage then 
		tvRP.notify("Ai nevoie de un pistol sau un cutit pentru a putea lua ostatic!", "error", false, "fas fa-gun")
		return
	end

	if not takeHostage.InProgress then			
		local closestPlayer, closestPed = checkIfHostage(1)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				if GetEntityHealth(closestPed) < 121 then
					return tvRP.notify("Nu poti lua ostatic un jucator mort!", "error", false, "fas fa-gun")
				end

				SetCurrentPedWeapon(tempPed, foundWeap, true)
				takeHostage.InProgress = true
				takeHostage.targetSrc = targetSrc
				takeHostage.targetPed = closestPed
				TriggerServerEvent("fp-hostageTasks:sync",targetSrc)
				loadAnimDict(takeHostage.agressor.animDict)
				takeHostage.type = "agressor"

				Citizen.CreateThreadNow(hostageFuncs)
			else
				tvRP.notify("Niciun jucator prin preajma!", "error", false, "fas fa-gun")
			end
		else
			tvRP.notify("Niciun jucator prin preajma!", "error", false, "fas fa-gun")
		end
	end
end 

RegisterNetEvent("fp-hostageTasks:syncTarget")
AddEventHandler("fp-hostageTasks:syncTarget", function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	takeHostage.InProgress = true
	loadAnimDict(takeHostage.hostage.animDict)
	AttachEntityToEntity(tempPed, targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	takeHostage.type = "hostage" 
end)

RegisterNetEvent("fp-hostageTasks:releaseHostage")
AddEventHandler("fp-hostageTasks:releaseHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = false
	DetachEntity(tempPed, true, false)
	loadAnimDict("reaction@shove")
	TaskPlayAnim(tempPed, "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	Wait(250)
	ClearPedSecondaryTask(tempPed)
end)

RegisterNetEvent("fp-hostageTasks:killHostage")
AddEventHandler("fp-hostageTasks:killHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = false
	SetEntityHealth(tempPed,0)
	DetachEntity(tempPed, true, false)
	loadAnimDict("anim@gangops@hostage@")
	TaskPlayAnim(tempPed, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("fp-hostageTasks:cl_stop")
AddEventHandler("fp-hostageTasks:cl_stop", function()
	takeHostage.InProgress = false
	takeHostage.type = false
	ClearPedSecondaryTask(tempPed)
	DetachEntity(tempPed, true, false)
end)