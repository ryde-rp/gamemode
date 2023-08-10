local restrictedRadios = {
	[1] = {
		faction = "Politia Romana",
	},
}

function tvRP.canJoinRadio(channel)
	local user_id = vRP.getUserId(source)
	local cfg = restrictedRadios[channel]
	if cfg then

		if cfg.faction then
			return vRP.isUserInFaction(user_id, cfg.faction)
		elseif cfg.job then
			return vRP.getUserJob(user_id) == cfg.job
		end
	
	end

	return true
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		TriggerClientEvent("fp-radio:restrictChannels", player, restrictedRadios)
	end
end)