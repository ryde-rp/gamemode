local gymSubscriptions = {}

function tvRP.subscribeToGym()
	local user_id = vRP.getUserId(source)
	local remainingTime = gymSubscriptions[user_id]

	if remainingTime then
		if remainingTime <= os.time() then
			gymSubscriptions[user_id] = nil
			vRPclient.notify(source, {"Vehicul abonamentul la Sala de Forta tocmai ti-a expirat, cumpara altul!", "warning", false, "fa-solid fa-dumbbell"})
			return
		end

		return vRPclient.notify(source, {"Ai un abonament la sala activ, acesta expira la "..os.date("%H:%M", remainingTime), "info", false, "fa-solid fa-dumbbell"})
	end

	if vRP.tryPayment(user_id, 300000, true) then
		local newTime = os.time() + 3600
		gymSubscriptions[user_id] = newTime -- 60 de minute

		vRPclient.notify(source, {"Ai platit $300000", "success"})
		vRPclient.notify(source, {"Ti-ai facut un abonament la Sala de Forta, acesta expira la "..os.date("%H:%M", newTime), "info", false, "fa-solid fa-dumbbell"})
	end
end

function tvRP.canUseGym()
	local user_id = vRP.getUserId(source)
	local remainingTime = gymSubscriptions[user_id]

	if remainingTime then
		if remainingTime <= os.time() then
			gymSubscriptions[user_id] = nil
			vRPclient.notify(source, {"Abonamentul la Sala de Forta ti-a expirat!", "warning", false, "fa-solid fa-dumbbell"})
			return false
		end

		return true
	end

	return false
end

function tvRP.gainGymStrength(oneStrength)
	local user_id = vRP.getUserId(source)
	local currentStrength = vRP.getUserAptitude(user_id, "inventar")

	if vRP.canIncreaseAptitude(user_id, currentStrength, oneStrength) then
		vRP.varyAptitude(user_id, "inventar", oneStrength)
	else
		vRPclient.notify(source, {"Ai atins limita maxima de KG!", "error"})
	end
end