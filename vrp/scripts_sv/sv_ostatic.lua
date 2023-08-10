local takingHostage = {}
local takenHostage = {}

RegisterServerEvent("fp-hostageTasks:sync")
AddEventHandler("fp-hostageTasks:sync", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	TriggerClientEvent("fp-hostageTasks:syncTarget", targetSrc, source)
	takingHostage[source] = targetSrc
	takenHostage[targetSrc] = source
end)

RegisterServerEvent("fp-hostageTasks:releaseHostage")
AddEventHandler("fp-hostageTasks:releaseHostage", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takenHostage[targetSrc] then 
		TriggerClientEvent("fp-hostageTasks:releaseHostage", targetSrc, source)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	end
end)

RegisterServerEvent("fp-hostageTasks:killHostage")
AddEventHandler("fp-hostageTasks:killHostage", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takenHostage[targetSrc] then 
		TriggerClientEvent("fp-hostageTasks:killHostage", targetSrc, source)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	end
end)

RegisterServerEvent("fp-hostageTasks:stop")
AddEventHandler("fp-hostageTasks:stop", function(targetSrc)
	local source = source

	if targetSrc == -1 then
        return DropPlayer(source, "Injection detected [vrp][hostageTasks]")
    end

	if takingHostage[source] then
		TriggerClientEvent("fp-hostageTasks:cl_stop", targetSrc)
		takingHostage[source] = nil
		takenHostage[targetSrc] = nil
	elseif takenHostage[source] then
		TriggerClientEvent("fp-hostageTasks:cl_stop", targetSrc)
		takenHostage[source] = nil
		takingHostage[targetSrc] = nil
	end
end)

AddEventHandler('vRP:playerLeave', function()
	if takingHostage[source] then
		TriggerClientEvent("fp-hostageTasks:cl_stop", takingHostage[source])

		takenHostage[takingHostage[source]] = nil
		takingHostage[source] = nil
	end

	if takenHostage[source] then
		TriggerClientEvent("fp-hostageTasks:cl_stop", takenHostage[source])
		
		takingHostage[takenHostage[source]] = nil
		takenHostage[source] = nil
	end
end)