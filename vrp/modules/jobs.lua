local inJobs = {}
local outVehicles = {}
local jobHours = {
	["Traficant de Tigari"] = 3,
	["Traficant de Etnobotanice"] = 2,
	["Livrator Glovo"] = 0,
}

local function onJobChange(source, group)
	TriggerClientEvent("vRP:onJobChange", source, group)
end

function vRP.setUserJob(user_id, group)
	exports.oxmysql:execute("UPDATE users SET userJob = @userJob WHERE id = @id",{
		['@id'] = user_id,
		['@userJob'] = group
	})

	inJobs[user_id] = group

	local source = vRP.getUserSource(user_id)
	if source then
		onJobChange(source, group)
	end

	return true
end

function vRP.getUserJob(user_id)
	local theJob = inJobs[user_id]
	if theJob then
		return theJob
	end

	return "Somer"
end

RegisterServerEvent("vRP:addJob", function(theGroup, src)
	local source = source
	if src then
		source = src
	end

	local user_id = vRP.getUserId(source)
	local userJob = inJobs[user_id]
	local userHours = vRP.getUserHoursPlayed(user_id)

	if userJob then
		if userJob == theGroup then
			return vRPclient.notify(source, {"Esti deja angajat ca "..theGroup.."!", "error"})
		end

		return vRPclient.notify(source, {"Esti angajat ca "..userJob..", trebuie sa demisionezi inainte de a te angaja la noi!", "error"})
	end

	if userHours < (jobHours[theGroup] or 0) then
		return vRPclient.notify(source, {"Ai nevoie de "..jobHours[theGroup].." de ore pentru a te angaja!"})
	end

	if vRP.isUserMedic(user_id) or vRP.isUserPolitist(user_id) then
		return vRPclient.notify(source, {"Nu te poti angaja deoarece faci parte dintr-o factiune legala!", "error"})
	end

	if vRP.setUserJob(user_id, theGroup) then
		return vRPclient.notify(source, {"Te-ai angajat ca "..theGroup, "success"})
	end
	
	vRPclient.notify(source, {"A aparut o eroare neasteptata, te rugam sa incerci iar!", "warning"})
end)

RegisterServerEvent("vRP:removeJob", function(theGroup, src)
	local source = source
	if src then
		source = src
	end

	local user_id = vRP.getUserId(source)
	local userJob = vRP.getUserJob(user_id)

	if userJob == theGroup then
		vRP.setUserJob(user_id, "Somer")
		inJobs[user_id] = nil

		return vRPclient.notify(source, {"Ai demisionat de la jobul de "..theGroup})
	end

	if userJob == "Somer" then
		return vRPclient.notify(source, {"Nu ai un job, angajeaza-te!", "error"})
	end

	vRPclient.notify(source, {"Esti angajat ca "..userJob..", mergi la sediu sa demisionezi!", "error"})
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
		local rows = exports.oxmysql:querySync("SELECT userJob FROM users WHERE id = @id", {['@id'] = user_id})
		if #rows > 0 then
			local theJob = rows[1].userJob or "Somer"

			if theJob ~= "Somer" then
				inJobs[user_id] = theJob

				onJobChange(source, theJob)

				Citizen.Wait(1500)
				return vRPclient.notify(source, {"Esti angajat ca "..theJob})
			end

			Citizen.Wait(1500)
			vRPclient.notify(source, {"Nu ai un job, angajeaza-te!", "warning"})
		end
	end
end)

RegisterCommand("job", function(src)
	local user_id = vRP.getUserId(src)
	local userJob = vRP.getUserJob(user_id)

	if userJob == "Somer" then
		return vRPclient.notify(src, {"Nu ai un job, angajeaza-te!", "warning"})
	end

	return vRPclient.notify(src, {"Esti angajat ca "..userJob})
end)

-- Joburi cu angajare din telefon --
RegisterServerEvent("jobs$joinGlovo", function()
	local user_id = vRP.getUserId(source)
	local userJob = vRP.getUserJob(user_id)

	if userJob ~= "Livrator Glovo" then
		return TriggerEvent("vRP:addJob", "Livrator Glovo", source)
	end

	TriggerEvent("vRP:removeJob", "Livrator Glovo", source)
end)

-- Garaje pentru Joburi --
function tvRP.requestJobVehicle(theJob, multipleSpawns)
	local user_id = vRP.getUserId(source)
	local uJob = vRP.getUserJob(user_id)

	if not multipleSpawns then
		if (outVehicles[user_id] or "fakeVehicle") == theJob then
			return false
		end
	end

	if uJob == theJob then
		if not multipleSpawns then
			outVehicles[user_id] = theJob
		end

		return true
	end
end

RegisterServerEvent("jobs$despawnVehicle", function()
	local user_id = vRP.getUserId(source)
	
	if outVehicles[user_id] then
		outVehicles[user_id] = nil
	end
end)