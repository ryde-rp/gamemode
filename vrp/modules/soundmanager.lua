RegisterServerEvent("vRP:playAudioInDist", function(radius, sound, sound_volume)
	vRPclient.getPosition(source, {}, function(x, y, z)
		vRPclient.getPlayersInCoords(source, {x, y, z, radius}, function(players)
			if table.notEmpty(players) then
				for playerSrc, _ in pairs(players) do
					TriggerClientEvent("vRP:playAudio", playerSrc, sound, sound_volume)
				end
			end
		end)
	end)
end)

RegisterServerEvent("vRP:playServerAudio", function(sound, sound_volume)
	local user_id = vRP.getUserId(source)
	if not vRP.isUserAdministrator(user_id) then
		CancelEvent()
		return vRP.banPlayer(0, user_id, -1, "Sound injection detected")
	end

	if not WasEventCanceled() then
		TriggerClientEvent("vRP:playAudio", -1, sound, sound_volume)
	end
end)