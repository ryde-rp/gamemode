local policeChat = "^5[Statie] [%s] ^7%s ^5(%d)^7: ^7%s"
local emsChat = "^1[Statie] [%s] ^7%s ^1(%d)^7: ^7%s"
local servicesChat = "^1[Servicii de urgenta] %s ^7%s ^1%s)^7: ^7%s"

RegisterCommand("d", function(src, args)
	local user_id = vRP.getUserId(src)
	if not vRP.isUserPolitist(user_id) then
		return vRPclient.denyAcces(src, {})
	end

	if not args[1] then
		return vRPclient.cmdUse(src, {"/d <mesaj>"})
	end
	local dispatchMessage = table.concat(args, " ")

	vRP.executaPentruFactiune("Politia Romana", function(member)
		TriggerClientEvent("chatMessage", member, policeChat:format(vRP.getUserFactionRank(user_id), GetPlayerName(src), user_id, dispatchMessage))
	end)
end)

RegisterCommand("s", function(src, args)
	local user_id = vRP.getUserId(src)
	if vRP.isUserPolitist(user_id) or vRP.isUserMedic(user_id) then

		if not args[1] then
			return vRPclient.cmdUse(src, {"/s <mesaj>"})
		end
		local serviceMessage = table.concat(args, " ")

		local msgColor = "^5"
		if vRP.isUserMedic(user_id) then
			msgColor = "^1"
		end

		vRP.executaPentruFactiune("Politia Romana", function(member)
			TriggerClientEvent("chatMessage", member, servicesChat:format(msgColor.."["..vRP.getUserFactionRank(user_id).."]", GetPlayerName(src), msgColor.."("..user_id, serviceMessage))
		end)

		vRP.executaPentruFactiune("Smurd", function(member)
			TriggerClientEvent("chatMessage", member, servicesChat:format(msgColor.."["..vRP.getUserFactionRank(user_id).."]", GetPlayerName(src), msgColor.."("..user_id, serviceMessage))
		end)
	else
		vRPclient.denyAcces(src, {})
	end
end)

RegisterCommand("m", function(src, args)
	local user_id = vRP.getUserId(src)
	if not vRP.isUserMedic(user_id) then
		return vRPclient.denyAcces(src, {})
	end

	if not args[1] then
		return vRPclient.cmdUse(src, {"/m <mesaj>"})
	end
	local dispatchMessage = table.concat(args, " ")

	vRP.executaPentruFactiune("Smurd", function(member)
		TriggerClientEvent("chatMessage", member, emsChat:format(vRP.getUserFactionRank(user_id), GetPlayerName(src), user_id, dispatchMessage))
	end)
end)