local cfg = module("cfg/jobs/taxi")

local allBiz, taxiDrivers, taxiOrders, userCalls, taxiParkings, bizCData = {}, {}, {}, {}, {}, {}

local function isBizOwner(bizId, user_id)
	if bizId and allBiz[bizId] then
		return (allBiz[bizId].owner?.user_id or 0) == user_id
	end

	return false
end

local function hasAnyTaxiCompany(user_id)
	local foundOne = false

	for bizId, bizData in pairs(allBiz) do
		if (bizData.owner?.user_id or 0) == user_id then
			foundOne = bizId
			break
		end
	end
	return foundOne
end

local function doTaxiFunction(fnc, exceptId)
	for user_id, data in pairs(taxiDrivers) do
		
		local src = vRP.getUserSource(user_id)
		if src and user_id ~= exceptId then
			fnc(src, user_id)
		end
		
	end
end

local function getTotalCompanyWorkers(bizId)
	local workers = 0

	for user_id, data in pairs(taxiDrivers) do
		if data.company == bizId then
			workers += 1
		end
	end

	return workers
end

local function calculatePercentage(percentage, number)
	return (number * percentage) / 100
end

AddEventHandler("onResourceStart", function(res)
	if res == GetCurrentResourceName() then
		Citizen.Wait(2000)
		exports.oxmysql:query("SELECT * FROM taxiCompanies", function(result)
			for _, bizData in pairs(result) do
				allBiz[bizData.name] = bizData
				local pozitie = json.decode(result[1].pos)
				local pozitiecar = json.decode(result[1].carpos)
				local parcare = json.decode(result[1].parking)
				bizCData[bizData.name] = {
					pos = vector3(pozitie.x, pozitie.y, pozitie.z),
					carpos = vector3(pozitiecar.x, pozitiecar.y, pozitiecar.z),
					car = bizData.car or 1,
					profit = bizData.profit	or 0,
					name = bizData.name,
					owner = json.decode(result[1].owner) or {name = "Primăria Ryde"},
					price = bizData.price,
				}

				taxiParkings[bizData.name] = {}
				for _, spot in pairs(parcare or {}) do
					table.insert(taxiParkings[bizData.name], vector3(parcare.x, parcare.y, parcare.z))
				end

				TriggerClientEvent("vrp-taxi:addBiz", -1, bizData.name, bizCData[bizData.name])
			end
		end)
	end
end)

AddEventHandler("onDatabaseConnect", function()
	exports.oxmysql:query("SELECT * FROM taxiCompanies", function(result)
		for _, bizData in pairs(result) do
			allBiz[bizData.name] = bizData
			local pozitie = json.decode(result[1].pos)
			local pozitiecar = json.decode(result[1].carpos)
			local parcare = json.decode(result[1].parking)
			bizCData[bizData.name] = {
				pos = vector3(pozitie),
				carpos = vector3(pozitiecar),
				car = bizData.car or 1,
				profit = bizData.profit	or 0,
				name = bizData.name,
				owner = json.decode(result[1].owner) or {name = "Primăria Ryde"},
				price = bizData.price,
			}

			taxiParkings[bizData.name] = {}
			for _, spot in pairs(parcare or {}) do
				table.insert(taxiParkings[bizData.name], vector3(spot))
			end

		end
	end)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
		TriggerClientEvent("vrp-taxi:populateParkings", source, taxiParkings)

		for bizId, bizData in pairs(bizCData) do
			TriggerClientEvent("vrp-taxi:addBiz", source, bizId, bizData)
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if taxiDrivers[user_id] then
		if taxiDrivers[user_id].order then
			local target_src = vRP.getUserSource(taxiDrivers[user_id].order)
			
			if target_src then
				TriggerClientEvent("vrp-taxi:forceCancelCommand", target_src)
				vRPclient.notify(target_src, {"Taximetristul s-a deconectat iar comanda a fost anulata automat.", "warning", false, "fas fa-taxi"})
				userCalls[taxiDrivers[user_id].order] = nil
			end
		end

		taxiDrivers[user_id] = nil
	end

	if userCalls[user_id] then
		local target_src = vRP.getUserSource(userCalls[user_id].driver)
		
		if target_src then
			TriggerClientEvent("vrp-taxi:forceCancelCommand", target_src)
			vRPclient.notify(target_src, {"Clientul s-a deconectat iar comanda a fost anulata automat.", "warning", false, "fas fa-taxi"})
			taxiDrivers[userCalls[user_id].driver].order = nil
		end
		
		userCalls[user_id] = nil
	end

	if taxiOrders[user_id] then
		taxiOrders[user_id] = nil
	end
end)

AddEventHandler("vRP:onPayday", function()
	
	for bizId, bizData in pairs(allBiz) do
		if (bizData.profit or 0) >= 1 then
	
			local percentage = math.max(math.ceil(calculatePercentage(15, bizData.profit)), 1)

			bizData.profit -= percentage
			bizCData[bizId].profit = bizData.profit

			exports.oxmysql:execute("UPDATE taxiCompanies SET profit = @profit WHERE name = @name",{
				['@name'] = bizId,
				['@profit'] = percentage
			})

		end	
	end

end)

RegisterServerEvent("vrp-taxi:enterParkingSpot")
AddEventHandler("vrp-taxi:enterParkingSpot", function(spotData)
	local player = source
	local user_id = vRP.getUserId(player)

	if taxiDrivers[user_id] then
		if not taxiDrivers[user_id].order then
			taxiDrivers[user_id].spot = spotData[1]
			taxiDrivers[user_id].parking = spotData[2]

			TriggerClientEvent("vRP:hint", player, "Stationezi in parcarea <span style='color: yellow'>"..spotData[2].."</span>, foloseste<br>tasta J pentru a vedea comenzile disponibile.")
		else
			vRPclient.notify(player, {"Ai o comanda activa, nu poti stationa in parcare.", "error", false, "fas fa-taxi"})
		end
	end
end)

RegisterServerEvent("vrp-taxi:leaveParkingSpot")
AddEventHandler("vrp-taxi:leaveParkingSpot", function(spotData)
	local player = source
	local user_id = vRP.getUserId(player)

	if taxiDrivers[user_id]?.spot then
		taxiDrivers[user_id].spot = nil
		taxiDrivers[user_id].parking = nil
	end
end)

RegisterServerEvent("vrp-taxi:taxiArrived")
AddEventHandler("vrp-taxi:taxiArrived", function(nid)
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id and taxiDrivers[user_id] then

		if taxiDrivers[user_id].order then
			local target_id = taxiDrivers[user_id].order

			local target_src = vRP.getUserSource(target_id)
			if target_src then

				TriggerClientEvent("vrp-taxi:notifyThatTaxiArrived", target_src, nid)
				vRPclient.notify(player, {"Ai ajuns la destinatie, asteapta ca clientul sa se urce in taxi", "warning", false, "fas fa-taxi"})
				vRPclient.notify(target_src, {"Taximetristul a ajuns la destinatie, urca in masina lui.", "warning", false, "fas fa-taxi"})

				Citizen.CreateThread(function()
					Citizen.Wait(30000)
					
					if userCalls[target_id] and not userCalls[target_id].code then
						vRPclient.notify(player, {"Daca in 30 de secunde clientul nu se urca in taxi comanda va fi anulata automat!", "warning", false, "fas fa-taxi"})
						vRPclient.notify(target_src, {"Daca in 30 de secunde nu te urci in taxi comanda va fi anulata automat!", "warning", false, "fas fa-taxi"})
					end
					
					Citizen.Wait(30000)

					if userCalls[target_id] and not userCalls[target_id].code then
						vRPclient.notify(player, {"Comanda a fost anulata.", "error", false, "fas fa-taxi"})
						vRPclient.notify(target_src, {"Comanda a fost anulata.", "error", false, "fas fa-taxi"})

						TriggerClientEvent("vrp-taxi:forceCancelCommand", player)

						userCalls[target_id] = nil
						taxiDrivers[user_id].order = nil
					end

				end)

			else
				userCalls[target_id] = nil
				taxiDrivers[user_id].order = nil
				vRPclient.notify(player, {"Jucatorul s-a deconectat.", "error"})
			end

		end
	end
end)

RegisterServerEvent("vrp-taxi:enteredTaxi")
AddEventHandler("vrp-taxi:enteredTaxi", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		if userCalls[user_id] then
			local target_id = userCalls[user_id].driver
			local target_src = vRP.getUserSource(target_id)

			userCalls[user_id].code = math.random(1, 99999)

			if target_src then
				TriggerClientEvent("vrp-taxi:passangerEntered", target_src, userCalls[user_id].code)
			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:exitedTaxi")
AddEventHandler("vrp-taxi:exitedTaxi", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		if userCalls[user_id] then
			local target_id = userCalls[user_id].driver
			local target_src = vRP.getUserSource(target_id)

			local money = (userCalls[user_id].money or 100)
			local percentage = math.max(math.ceil(calculatePercentage(35, money)), 1)

			if target_src then

				if vRP.tryFullPayment(user_id, money) then
					vRPclient.notify(player, {"Ai platit $"..money.." pentru cursa de taxi!", "warning", false, "fas fa-taxi"})
					
					money = (money - percentage)
					vRP.giveMoney(target_id, money)

					bizCData[taxiDrivers[target_id].company].profit += percentage
					allBiz[taxiDrivers[target_id].company].profit = bizCData[taxiDrivers[target_id].company].profit
					exports.oxmysql:execute("UPDATE taxiCompanies SET profit = @profit WHERE name = @name",{
						['@name'] = taxiDrivers[target_id].company,
						['@profit'] = percentage
					})

					vRPclient.notify(target_src, {"Ai castigat $"..money.." pentru cursa de taxi!", "warning", false, "fas fa-taxi"})
				else
					vRPclient.notify(target_src, {"Pasagerul nu are destui bani pentru a plati cursa!", "error", false, "fas fa-taxi"})
				end

				TriggerClientEvent("vrp-taxi:commandDone", target_src)
				taxiDrivers[target_id].order = nil

			end

			userCalls[user_id] = nil
		end
	end
end)

RegisterServerEvent("vrp-taxi:sendTaxiCoords")
AddEventHandler("vrp-taxi:sendTaxiCoords", function(tpos)
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then

		if taxiDrivers[user_id] and taxiDrivers[user_id].order then
			local target_id = taxiDrivers[user_id].order

			local target_src = vRP.getUserSource(target_id)
			if target_src then
				TriggerClientEvent("vrp-taxi:notifyTaxiPosition", target_src, tpos)
			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:addMoney")
AddEventHandler("vrp-taxi:addMoney", function(amm, code)
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then

		if taxiDrivers[user_id]?.order then
			local target_id = taxiDrivers[user_id].order

			local target_src = vRP.getUserSource(target_id)
			if target_src then
			    if userCalls[target_id] and userCalls[target_id].code ~= nil and code ~= nil  then
					if userCalls[target_id].code == code then 
						local hour = tonumber(os.date("%H"))
						if hour >= 22 and hour <= 10 then
							userCalls[target_id].money = (userCalls[target_id].money or 100) + math.ceil(amm*1.1)
						else
							userCalls[target_id].money = (userCalls[target_id].money or 0) + amm
						end
	
						TriggerClientEvent("vrp-taxi:setMoneyAmount", target_src, userCalls[target_id].money)
						TriggerClientEvent("vrp-taxi:setMoneyAmount", player, userCalls[target_id].money)
					end
				end
			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:getCommand")
AddEventHandler("vrp-taxi:getCommand", function(target_id)
	local player = source
	local user_id = vRP.getUserId(player)

	if taxiDrivers[user_id] then
		if taxiDrivers[user_id].spot then
			if not taxiDrivers[user_id].order then
				if taxiOrders[target_id] then
					
					if not taxiOrders[target_id].taken then
						local target_src = vRP.getUserSource(target_id)
						if target_src then

							taxiOrders[target_id].taken = true
							taxiOrders[target_id].driver = user_id
							
							userCalls[target_id] = taxiOrders[target_id]
							taxiOrders[target_id] = nil
							
							taxiDrivers[user_id].order = target_id
							taxiDrivers[user_id].spot = nil
							taxiDrivers[user_id].parking = nil

							Citizen.CreateThread(function()
								doTaxiFunction(function(driver)
									TriggerClientEvent("vrp-taxi:updateOrders", driver, taxiOrders)
								end)
							end)

							TriggerClientEvent("vrp-taxi:notifyThatOrderTaken", target_src, taxiDrivers[user_id].company)
							TriggerClientEvent("vrp-taxi:sendCommandData", player, {id = target_id, pos = userCalls[target_id].pos, fare = cfg.distFares[allBiz[taxiDrivers[user_id].company].car or 1] })
						else
							vRPclient.notify(player, {"Clientul nu mai este disponibil.", "error", false, "fas fa-taxi"})
						end
					else
						vRPclient.notify(player, {"Comanda a fost deja preluata de altcineva!", "warning", false, "fas fa-taxi"})
					end
				else
					vRPclient.notify(player, {"Comanda a fost deja preluata de altcineva!", "warning", false, "fas fa-taxi"})
				end
			else
				vRPclient.notify(player, {"Ai deja o comanda activa!", "error", false, "fas fa-taxi"})
			end
		else
			vRPclient.notify(player, {"Trebuie sa fi parcat pentru a putea prelua o comanda!", "warning", false, "fas fa-taxi"})
		end
	else
		vRPclient.notify(player, {"Nu esti taximetrist!", "error"})
	end
end)

RegisterServerEvent("vrp-taxi:showOrdersList")
AddEventHandler("vrp-taxi:showOrdersList", function()
	local player = source
	local user_id = vRP.getUserId(player)

	if taxiDrivers[user_id]?.spot then
		TriggerClientEvent("vrp-taxi:showOrdersList", player, taxiOrders)
	end
end)

local function spawnTaxiVeh(theBiz, player)
	
	local ped = GetPlayerPed(player)
	local veh = vRP.spawnVehicle(GetHashKey(cfg.taxiModels[allBiz[theBiz].car or 1]), bizCData[theBiz].carpos, GetEntityHeading(ped), true, true)

	Citizen.SetTimeout(500, function()
		SetEntityHeading(veh, 220.0)
		SetPedIntoVehicle(ped, veh, -1)
		SetEntityRoutingBucket(veh, tonumber(GetPlayerRoutingBucket(player)))

		TriggerClientEvent("vrp-taxi:taxiSpawned", player, NetworkGetNetworkIdFromEntity(veh))
	end)
	
	return veh
end

RegisterServerEvent("vrp-taxi:workAsTaxi")
AddEventHandler("vrp-taxi:workAsTaxi", function(theBiz)
	local player = source
	local user_id = vRP.getUserId(player)

	if theBiz and allBiz[theBiz] then
		if taxiDrivers[user_id] then
			if taxiDrivers[user_id].company ~= theBiz then
				if not taxiDrivers[user_id].order then
					taxiDrivers[user_id].company = theBiz
					taxiDrivers[user_id].parking = nil
					taxiDrivers[user_id].spot = nil
				else
					return vRPclient.notify(player, {"Ai o comanda activa, trebuie sa o termini pentru a te putea angaja la o alta firma!", "error", false, "fas fa-taxi"})
				end
			else
				if not DoesEntityExist(taxiDrivers[user_id]?.veh or 0) then
					spawnTaxiVeh(theBiz, player)
				else
					vRPclient.notify(player, {"Lucrezi deja pentru compania de taxi "..theBiz, "error"})
				end
				
				return false
			end
		end

		local nveh = spawnTaxiVeh(theBiz, player)

		taxiDrivers[user_id] = {
			company = theBiz,
			veh = nveh,
		}

		TriggerClientEvent("vrp-taxi:setServiceDuty", player, theBiz)
	end
end)





RegisterServerEvent("vrp-taxi:openCompanyMenu")
AddEventHandler("vrp-taxi:openCompanyMenu", function(bizId)
	local player = source
	local user_id = vRP.getUserId(player)

	if bizId and allBiz[bizId] then
		TriggerClientEvent("vrp-taxi:openCompanyMenu", player, bizId, isBizOwner(bizId, user_id), cfg.distFares[allBiz[bizId].car or 1])
	end
end)

RegisterServerEvent("vrp-taxi:openManagerMenu")
AddEventHandler("vrp-taxi:openManagerMenu", function(bizId)
	local player = source
	local user_id = vRP.getUserId(player)
	local bizData = allBiz[bizId]

	if bizId and bizData then
		TriggerClientEvent("vrp-taxi:openManagerMenu", player, bizId, {
			name = bizId,
			car = cfg.taxiCars[bizData.car or 1],
			carLvl = bizData.car or 1,
			profit = bizData.profit or 0,
			distanceFare = cfg.distFares[bizData.car or 1],
			workers = getTotalCompanyWorkers(bizId),
		})
	end
end)

RegisterServerEvent("vrp-taxi:trySellCompany")
AddEventHandler("vrp-taxi:trySellCompany", function(bizId, price)
	local player = source
	local user_id = vRP.getUserId(player)
	
	if bizId and allBiz[bizId] and price > 0 then
		if isBizOwner(bizId, user_id) then

			allBiz[bizId].price = price
			bizCData[bizId].price = price
			vRPclient.notify(player, {"Ai scos compania "..bizId.." la vanzare pentru suma de $"..vRP.formatMoney(price), "warning", false, "fas fa-taxi"})

			exports.oxmysql:execute("UPDATE taxiCompanies SET price = @price WHERE name = @name",{
				['@name'] = bizId,
				['@price'] = price
			})
			
			TriggerClientEvent("vrp-taxi:setClientTableVar", -1, bizId, "price", price)
		end
	end
end)

RegisterServerEvent("vrp-taxi:tryBuyCompany")
AddEventHandler("vrp-taxi:tryBuyCompany", function(bizId)
	local player = source
	local user_id = vRP.getUserId(player)
	local userIdentity = vRP.getIdentity(user_id)
	
	if bizId and allBiz[bizId] and allBiz[bizId].price then
		if not isBizOwner(bizId, user_id) and not hasAnyTaxiCompany(user_id) then
			if vRP.tryPayment(user_id, allBiz[bizId].price, true) then

				if (allBiz[bizId].owner?.user_id or 0) ~= 0 then
					local ownerSrc = vRP.getUserSource(allBiz[bizId].owner.user_id)
					
					if ownerSrc then
						vRP.giveBankMoney(allBiz[bizId].owner.user_id, allBiz[bizId].price)
						vRPclient.notify(ownerSrc, {"Compania de taxi detinuta de tine a fost cumparata si ai primit $"..vRP.formatMoney(allBiz[bizId].price)})
					else
						exports.oxmysql:execute("UPDATE users SET walletMoney = @walletMoney WHERE id = @id",{
							['@id'] = allBiz[bizId].owner.user_id,
							['@walletMoney'] = allBiz[bizId].price
						})
					end

				end

				vRPclient.notify(player, {"Ai cumparat compania "..bizId.." pentru suma de $"..vRP.formatMoney(allBiz[bizId].price), "info", false, "fas fa-taxi"})
				allBiz[bizId].price = nil
				bizCData[bizId].price = nil

				exports.oxmysql:execute("UPDATE taxiCompanies SET price = @price WHERE name = @name",{
					['@name'] = bizId,
					['@price'] = 0
				})

				local newOwner = {
					user_id = user_id,
					name = userIdentity.firstname.." "..userIdentity.name,
				}

				if taxiDrivers[user_id] then
					taxiDrivers[user_id] = nil
					TriggerClientEvent("vrp-taxi:setServiceDuty", player, false)
				end

				allBiz[bizId].owner = newOwner
				bizCData[bizId].owner = newOwner

				exports.oxmysql:execute("UPDATE taxiCompanies SET owner = @owner WHERE name = @name",{
					['@name'] = bizId,
					['@owner'] = json.encode(newOwner)
				})
				
				TriggerClientEvent("vrp-taxi:setClientTableVar", -1, bizId, "price", allBiz[bizId].price)
				TriggerClientEvent("vrp-taxi:setClientTableVar", -1, bizId, "owner", newOwner)
			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:updateTaxiCar")
AddEventHandler("vrp-taxi:updateTaxiCar", function(bizId)
	local player = source
	local user_id = vRP.getUserId(player)

	if bizId and allBiz[bizId] then
		if isBizOwner(bizId, user_id) then
			local carLvl = allBiz[bizId].car or 1
			
			if carLvl >= #cfg.taxiCars then
				return vRPclient.notify(player, {"Compania ta detine deja cea mai performanta masina!", "error", false, "fas fa-taxi"})
			end

			carLvl += 1
			local cost = cfg.carPrices[carLvl]
			if vRP.tryFullPayment(user_id, cost, true) then
				allBiz[bizId].car = carLvl
				bizCData[bizId].car = carLvl
				vRPclient.notify(player, {"Ai upgradat masina companiei "..bizId.." la "..cfg.taxiCars[carLvl].." pentru suma de $"..vRP.formatMoney(cost), "info", false, "fas fa-taxi"})

				exports.oxmysql:execute("UPDATE taxiCompanies SET car = @car WHERE name = @name",{
					['@name'] = bizId,
					['@car'] = carLvl
				})

				TriggerClientEvent("vrp-taxi:setClientTableVar", -1, bizId, "car", carLvl)
			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:withdrawProfit")
AddEventHandler("vrp-taxi:withdrawProfit", function(bizId)
	local player = source
	local user_id = vRP.getUserId(player)

	if bizId and allBiz[bizId] then
		
		if isBizOwner(bizId, user_id) then
			if (allBiz[bizId].profit or 0) > 0 then
				
				vRPclient.notify(player, {"Ai retras $"..vRP.formatMoney(allBiz[bizId].profit), "warning", false, "fas fa-taxi"})
				vRP.giveMoney(user_id, allBiz[bizId].profit)
				
				allBiz[bizId].profit = 0
				bizCData[bizId].profit = allBiz[bizId].profit

				exports.oxmysql:execute("UPDATE taxiCompanies SET profit = @profit WHERE name = @name",{
					['@name'] = bizId,
					['@profit'] = 0
				})

			end
		end
	end
end)

RegisterServerEvent("vrp-taxi:addServiceCall", function(notesForDriver)
	local player = source
	local user_id = vRP.getUserId(player)
	local userIdentity = vRP.getIdentity(user_id)
	local pos = GetEntityCoords(GetPlayerPed(player))

	if taxiOrders[user_id] or userCalls[user_id] then
		return vRPclient.notify(player, {"Ai deja o comanda in asteptare!", "warning", false, "fas fa-taxi"})
	end

	if notesForDriver:len() < 2 then
		notesForDriver = false
	end

	TriggerClientEvent("vrp-taxi:alertSentCall", player)

	taxiOrders[user_id] = {
		id = user_id,
		customer = userIdentity.name,
		note = notesForDriver or "Fara notite",
		pos = pos,
	}

	doTaxiFunction(function(driver)
		TriggerClientEvent("vrp-taxi:alertNewCall", driver)
		TriggerClientEvent("vrp-taxi:updateOrders", driver, taxiOrders)
	end)

	
end)