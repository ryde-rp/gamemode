local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

RegisterServerEvent("ServerEmoteRequest")
AddEventHandler("ServerEmoteRequest", function(target, emotename, etype)
	TriggerClientEvent("ClientEmoteRequestReceive", target, emotename, etype)

	local animTbl = DP.Shared[emotename] or {}
    if etype == 'Dances' then
		animTbl = DP.Dances[emotename] or {}
    end

	local player = source
	vRP.request({target, GetPlayerName(player).." te-a invitat sa faceti emote-ul "..(animTbl[3] or "Necunoscut").." impreuna, vrei sa accepti?", false, function(nsrc, ok)

		if ok then
			TriggerClientEvent("vrp-anims:acceptSharedEmote", target)
		else
			TriggerClientEvent("vrp-anims:denySharedEmote", target)
		end
	
	end})

end)

RegisterServerEvent("ServerValidEmote") 
AddEventHandler("ServerValidEmote", function(target, requestedemote, otheremote)
	TriggerClientEvent("SyncPlayEmote", source, otheremote, source)
	TriggerClientEvent("SyncPlayEmoteSource", target, requestedemote)
end)