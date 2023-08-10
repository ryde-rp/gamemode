local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_biju")
local possibleWins = {}

Citizen.CreateThread(function() -- load wins table
	for key, data in pairs(module("vrp", "cfg/item/jafbiju")) do
		table.insert(possibleWins, {
			item = key,
			price = data.price or 1,
		})
	end
end)

local lastRobbery
local activeRobbery = false
local robSecret = {}

RegisterServerEvent("vrp-biju:startRobbing")
AddEventHandler("vrp-biju:startRobbing", function()
	local player = source
	local user_id = vRP.getUserId({player})

	if (lastRobbery or 0) <= os.time() then

		local copUsers = vRP.getOnlineUsersByFaction({"Politia Romana"})
		if #copUsers < 8 then
			return vRPclient.notify(player, {"Nu sunt suficienti politisti online! Minimul este de 8, iar momentan sunt doar "..#copUsers.. " !", "error", false, "fas fa-gem"})
		end

		lastRobbery = os.time() + 21600 -- 6 ore cooldown
		activeRobbery = true

		TriggerClientEvent("vrp-biju:setState", -1, false)
		local newSecret = math.random(1, user_id) + ((os.time() % 60) + 1)
		robSecret[user_id] = newSecret

		TriggerClientEvent("vrp-biju:sendCoords", player, {newSecret})
	    vRP.doFactionFunction({"Politia Romana", function(src)
	        TriggerClientEvent("vrp-robbing:showAlert", src, "A fost activata alarma bijuteriei Vangelico. Toate unitatile sunt rugate sa se deplaseze de urganta la locatia incidentului.")
	    end})
		return
	end

	local remainingTime = lastRobbery - os.time()
	vRPclient.notify(player, {"Trebuie sa mai astepti "..remainingTime.." (de) secunde inainte de a jefuii iar bijuteria!", "error", false, "fas fa-gem"})
end)

RegisterServerEvent("vrp-biju:cancelRob")
AddEventHandler("vrp-biju:cancelRob", function()
	local player = source
	local user_id = vRP.getUserId({player})

	robSecret[user_id] = nil
	activeRobbery = false
	TriggerClientEvent("vrp-biju:setState", -1, not activeRobbery)
end)

RegisterServerEvent("vrp-biju:robCoords")
AddEventHandler("vrp-biju:robCoords", function(cpData)
	local player = source
	local user_id = vRP.getUserId({player})

	if not robSecret[user_id] or (robSecret[user_id] ~= cpData[1]) then
		return vRP.banPlayer({0, user_id, -1, "Injection detected [vrp_biju]"})
	end

	local rnd = table.rnd(possibleWins)
	local amt = math.random(1, 3)
	
	if vRP.canCarryItem({user_id, rnd.item, amt, true}) then
		vRP.giveInventoryItem({user_id, rnd.item, amt, true})
	end
end)

RegisterServerEvent("vrp-biju:sellJewels")
AddEventHandler("vrp-biju:sellJewels", function()
	local player = source
	local user_id = vRP.getUserId({player})
	local cashWin = 0

	for _, item in pairs(possibleWins) do
		local amt = vRP.getInventoryItemAmount({user_id, item.item})

		if (amt > 0) and vRP.tryGetInventoryItem({user_id, item.item, amt, true}) then
			cashWin = cashWin + (amt * item.price)
		end
	end

	if cashWin > 0 then
		vRP.giveInventoryItem({user_id, "bani_murdari", cashWin, true})
		return
	end

	vRPclient.notify(player, {"Nu ai bijuterii sa-mi vinzi, pleaca de aici mai repede!", "error", false, "fas fa-face-frown"})
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source)
	TriggerClientEvent("vrp-biju:setState", source, not activeRobbery)
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if robSecret[user_id] then
		robSecret[user_id] = nil
	end
end)