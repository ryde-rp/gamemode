RegisterNetEvent("fp-identity:createCharacter", function()
	SetNuiFocus(true, true)
	SendNUIMessage{
		act = "createIdentity"
	}
end)

RegisterNUICallback("createIdentity", function(data, cb)
	TriggerServerEvent("fp-identity:createCharacter", data or {})
	SetNuiFocus(false, false)

	cb("discord.gg/ryde")
end)