local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP','roulette')

local rollPrice = 500000
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		TriggerClientEvent('prizes:setPrice',source,rollPrice)
	end
end)

RegisterServerEvent('prizes:doPayment')
AddEventHandler('prizes:doPayment',function(withDmd)
	local thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	if withDmd then 
		if vRP.tryCoinsPayment({user_id,2}) then
			spinMoneyRoulette(thePlayer,user_id)
		else
			TriggerClientEvent('prizes:exit',thePlayer)
			vRPclient.notify(thePlayer,{"Eroare: Nu ai destui bani!"})
		end
	else
		if vRP.tryFullPayment({user_id,rollPrice}) then
			spinMoneyRoulette(thePlayer,user_id)
		else
			TriggerClientEvent('prizes:exit',thePlayer)
			vRPclient.notify(thePlayer,{"Eroare: Nu ai destui bani!"})
		end

	end
	
end)

local function prim(n)
	local max = n/2
	for i=2,max do
		if n%i == 0 then
			return false
		else
			return true
		end
	end
end
local sanse = {35,25,15}
spinMoneyRoulette = function(thePlayer,user_id)
	sansa = math.random(1,100)
	sansaBani = math.random(1,50)
	sansaMasina = math.random(1,50)
	sansaVip = math.random(1,50)
	sansaDiamant = math.random(1,50)
	sansaMotor = math.random(1,50)
	TriggerClientEvent('ak4y-battlepass:addtaskcount:premium', thePlayer, 1, 1)

	if sansaBani == 30 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"banimulti")
		Wait(10500)
		money2 = math.random(3320000,4330000)
		vRP.sendToDis{
			vRP.getGlobalStateLogs{}['Inventory']['Ruleta'],
			'Ryde Ruleta',
			''..user_id..' a castigat '..money2..'$ la ruleta'
		}
		vRP.giveMoney({user_id,money2})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^0"..GetPlayerName(thePlayer).."^0 a castigat ^2"..vRP.formatMoney({money2}).."$^0!")
	elseif sansaDiamant == 15 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"Diamant")
		Wait(10500)
		coins = math.random(1,2)
		actIPcoins = vRP.getXZCoins({user_id})
		vRP.setdonationCoins({user_id,actIPcoins + coins})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^1"..GetPlayerName(thePlayer).." ^0a castigat ^8"..coins.." ^0de Ryde Coins!")
	elseif sansaVip == 5 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"vip3")
		Wait(10500)
		vRP.setUserVip({user_id,4,tonumber(7)})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^1"..GetPlayerName(thePlayer).." ^0a castigat ^1RYDE GOD ^0pentru ^47 zile^0!")		
	elseif sansaVip == 9 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"vip1")
		Wait(10500)
		vRP.setUserVip({user_id,2,tonumber(7)})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^1"..GetPlayerName(thePlayer).." ^0a castigat ^1Vip Silver ^0pentru ^47 zile^0!")				
	elseif sansaVip == 5 and sansa == 100 then
		if vRP.getInventoryItemAmount({user_id,"cufarmilsugi"}) == 0 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"vip2")
		Wait(10500)
		vRP.setUserVip({user_id,3,tonumber(14)})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^1"..GetPlayerName(thePlayer).." ^0a castigat ^1Vip Gold ^0pentru ^414 zile^0!")
	else
		TriggerClientEvent('prizes:winSomething',thePlayer,"vip1")
		Wait(10500)
		vRP.setUserVip({user_id,2,tonumber(14)})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^1"..GetPlayerName(thePlayer).." ^0a castigat ^1Vip Silver ^0pentru ^414 zile^0!")
	end
	elseif sansaMasina == 2 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"Motocicleta")
		Wait(10500)
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^0Jucatorul ^9"..GetPlayerName(thePlayer).." ^0a castigat motocicleta ^1BMW BS17")
		exports.oxmysql:execute("INSERT IGNORE INTO user_vehicles(user_id,vehicle,vehicle_plate,veh_type) VALUES(@user_id,@vehicle,@vehicle_plate,@veh_type)",{["user_id"] = user_id, ["vehicle"] = "bmws", ["vehicle_plate"] = "B "..math.random(10000,99999), ["veh_type"] = "car"})
	elseif sansaMasina == 1 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"Masina")
		Wait(10500)
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^0Jucatorul ^9"..GetPlayerName(thePlayer).." ^0a castigat masina ^1Lamborghini Aventador LP700")
		exports.oxmysql:execute("INSERT IGNORE INTO user_vehicles(user_id,vehicle,vehicle_plate,veh_type) VALUES(@user_id,@vehicle,@vehicle_plate,@veh_type)",{["user_id"] = user_id, ["vehicle"] = "lp700r", ["vehicle_plate"] = "B "..math.random(10000,99999), ["veh_type"] = "car"})
	elseif sansaDiamant == 10 and sansa == 100 then
		TriggerClientEvent('prizes:winSomething',thePlayer,"Diamant")
		Wait(10500)
		vRP.giveCoins({user_id, 5, true})
		TriggerClientEvent('chatMessage',-1,"^6Roulette: ^0Jucatorul ^1"..GetPlayerName(thePlayer).." ^0a castigat ^85 Ryde Coins!")
	else
		TriggerClientEvent('prizes:winSomething',thePlayer,"baniputini")
		Wait(10500)
		money1 = math.random(20000,25000)
		vRP.sendToDis{
			vRP.getGlobalStateLogs{}['Inventory']['Ruleta'],
			'Tropical Ruleta',
			''..user_id..' a castigat '..money1..'$ la ruleta'
		}
		vRP.giveMoney({user_id,money1})
		vRPclient.notify(thePlayer,{"Succes: Ai castigat "..vRP.formatMoney({money1}).."$"})
	end 
end