RegisterNUICallback("vehmenu$switchSeat", function(data, cb)
	local theSeat = data.seat
	if not theSeat then
		return
	end

	if (theSeat == -1) or (theSeat == 0) then
		local firstSeat = GetPedInVehicleSeat(GVEHICLE, 1)
		local secondSeat = GetPedInVehicleSeat(GVEHICLE, 2)

		if (firstSeat == tempPed) or (secondSeat == tempPed) then
			cb("discord.gg/ryde")
			return tvRP.notify("Nu te poti muta in fata!", "error", false, "fas fa-car")
		end
	elseif (theSeat == 1) or (theSeat == 2) then
		local firstSeat = GetPedInVehicleSeat(GVEHICLE, -1)
		local secondSeat = GetPedInVehicleSeat(GVEHICLE, 0)

		if (firstSeat == tempPed) or (secondSeat == tempPed) then
			cb("discord.gg/ryde")
			return tvRP.notify("Nu te poti muta in spate!", "error", false, "fas fa-car")
		end
	end

	SetPedIntoVehicle(tempPed, GVEHICLE, theSeat)
	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$switchEngine", function(_, cb)
	if (GVEHICLE == 0) or (GetPedInVehicleSeat(GVEHICLE, -1) ~= tempPed) then
		return
	end

    local running = GetIsVehicleEngineRunning(GVEHICLE)
    SetVehicleEngineOn(GVEHICLE, not running, true, true)

    if running then
        SetVehicleUndriveable(GVEHICLE, true)
    else
        SetVehicleUndriveable(GVEHICLE, false)
    end
	
	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$toggleDoor", function(data, cb)
	local theDoor = data.door
	if not theDoor then
		return
	end

    local doorAngle = GetVehicleDoorAngleRatio(GVEHICLE, theDoor)
    local doorOpen = doorAngle > 0.0

    if not doorOpen then
    	SetVehicleDoorOpen(GVEHICLE, theDoor, false, false)
    else
    	SetVehicleDoorShut(GVEHICLE, theDoor, false)
	end
	
	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$toggleAllDoors", function(data, cb)
	for theDoor=0, 3 do
    	local doorAngle = GetVehicleDoorAngleRatio(GVEHICLE, theDoor)
    	local doorOpen = doorAngle > 0.0

    	if not doorOpen then
    		SetVehicleDoorOpen(GVEHICLE, theDoor, false, false)
    	else
    		SetVehicleDoorShut(GVEHICLE, theDoor, false)
		end
	end
	
	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$toggleWindow", function(data, cb)
	local theWindow = data.windowId
	if not theWindow then
		return
	end

    if not IsVehicleWindowIntact(GVEHICLE, theWindow) then
        RollUpWindow(GVEHICLE, theWindow)

        if not IsVehicleWindowIntact(GVEHICLE, theWindow) then
            RollDownWindow(GVEHICLE, theWindow)
        end
    else
        RollDownWindow(GVEHICLE, theWindow)
    end
	
	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$togLights", function(_, cb)
	if (GVEHICLE == 0) or (GetPedInVehicleSeat(GVEHICLE, -1) ~= tempPed) then
		return
	end

	for i=0, 3 do
		local lightsState = IsVehicleNeonLightEnabled(GVEHICLE, i)
	
		SetVehicleNeonLightEnabled(GVEHICLE, i, not lightsState)
	end

	cb("discord.gg/ryde")
end)

RegisterNUICallback("vehmenu$togLocking", function(_, cb)
	ExecuteCommand("togCarLockState")
	cb("discord.gg/ryde")
end)

RegisterCommand("openVehicleMenu", function()
	if GVEHICLE == 0 then
		return
	end

	SendNUIMessage({
		act = "interface",
		target = "vehicleMenu",
	})

	TriggerEvent("vRP:interfaceFocus", true)
end)

RegisterKeyMapping("openVehicleMenu", "Meniu vehicul", "keyboard", "M")