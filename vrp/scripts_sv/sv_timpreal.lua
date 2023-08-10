local randomNightMessages = {}
Citizen.CreateThread(function()
	while true do
		Wait(10 * 60 * 1000)
		local ora = parseInt(os.date("%H"))
		if ora == 22 or ora == 23 or ora == 0 or ora == 1 or ora == 2 or ora == 3 or ora == 4 or ora == 5 or ora == 6 then
			TriggerClientEvent('trimiteTimp',-1,'Night')
		elseif ora >= 7 and ora <= 18 then
			TriggerClientEvent('trimiteTimp',-1,'Day')
		elseif ora >= 19 and ora <= 21 then
			TriggerClientEvent('trimiteTimp',-1,'Noon')
		end
	end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		local ora = parseInt(os.date("%H"))
		if ora == 22 or ora == 23 or ora == 0 or ora == 1 or ora == 2 or ora == 3 or ora == 4 or ora == 5 or ora == 6 then
			TriggerClientEvent('trimiteTimp',source,'Night')
		elseif ora >= 7 and ora <= 18 then
			TriggerClientEvent('trimiteTimp',source,'Day')
		elseif ora >= 19 and ora <= 21 then
			TriggerClientEvent('trimiteTimp',source,'Noon')
		end
	end
end)