function vRP.getPlayerTattoos(user_id)
	if user_id then
	    local uTattoos = {}

	    vRP.getUData(user_id, "userTattoos", function(result)
	        uTattoos = json.decode(result) or {}
	    end)
	    
	    return uTattoos
	end
end

function tvRP.purchaseTattoo(tattooList, price, tattoo, tattooName)
	local user_id = vRP.getUserId(source)
	price = tonumber(price)
	
	if user_id and price then
		if vRP.tryPayment(user_id, price, true) then
			table.insert(tattooList, tattoo)

			vRP.setUData(user_id, "userTattoos", json.encode(tattooList))
			vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(price).." pentru tatuajul "..tattooName})

			return true
		end
	end

	return false
end

RegisterServerEvent('vRPclothes:removeTattoo', function(tattooList)
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.setUData(user_id, "userTattoos", json.encode(tattooList))
	end
end)

function refreshUserTattoos(user_id, player)
	local uTattoos = vRP.getPlayerTattoos(user_id)
	TriggerClientEvent("vRPclothes:setTattoos", player, (uTattoos or {}))
end

AddEventHandler("vRP:playerSpawn", function(user_id, source)
	refreshUserTattoos(user_id, source)
end)

RegisterCommand("fixtattoo", function(source)
	local user_id = vRP.getUserId(source)
	refreshUserTattoos(user_id, source)
end)