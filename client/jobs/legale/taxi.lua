
local onDuty, taxiParkings, parkingSpot, allBiz = false, {}, {}, {}

local taxiModels = {
	GetHashKey("crowntaxi"),
    GetHashKey("priustaxi"),
    GetHashKey("c63"),
    GetHashKey("trans_mbv250"),
    GetHashKey("velartaxi"),
    GetHashKey("gle450"),
	GetHashKey("xp210"),
}

RegisterNetEvent("vrp-taxi:setMoneyAmount")
AddEventHandler("vrp-taxi:setMoneyAmount", function(amm)
	SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "updateCost", cost = amm})
end)

--- DRIVER Side

local function checkNearestParking()
	for indx, spots in pairs(taxiParkings) do
		for k, pos in pairs(spots) do
			local dist = #(pos - pedPos)
			
			if dist <= 25 then
				-- {parentObj, spot}
				return indx, k
			end
		end
	end

	return false
end

local function isParkedInSpot()
	if parkingSpot[1] then
		return parkingSpot
	end

	return false
end

local function isPlayerInTaxi(veh)
	local inTaxi = false
	if GetPedInVehicleSeat(veh, -1) == tempPed then
		
		local curModel = GetEntityModel(veh)
		for _, model in pairs(taxiModels) do
			if curModel == model then
				inTaxi = true
				break
			end
		end
	end

	return inTaxi
end

local currentCommand = nil
RegisterNetEvent("vrp-taxi:sendCommandData")
AddEventHandler("vrp-taxi:sendCommandData", function(commandData)
	currentCommand = { 
		id = commandData.id,
		pos = commandData.pos,
		fare = commandData.fare,
		step = 1
	}

	currentCommand.blip = AddBlipForCoord(currentCommand.pos)
	SetBlipSprite(currentCommand.blip, 280)
	SetBlipDisplay(currentCommand.blip, 10)
	SetBlipColour(currentCommand.blip, 5)
	SetBlipRoute(currentCommand.blip, true)
	SetBlipRouteColour(currentCommand.blip, 5)

	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Client")
    EndTextCommandSetBlipName(currentCommand.blip)

	Citizen.CreateThread(function()
		while currentCommand.id == commandData.id do
			local pedpos = GetEntityCoords(GetPlayerPed(-1))
			currentCommand.distance = math.floor(#(currentCommand.pos - pedpos))

			TriggerServerEvent("vrp-taxi:sendTaxiCoords", pedpos)

			if currentCommand.distance < 30 then
				if currentCommand.blip then
					RemoveBlip(currentCommand.blip)
					currentCommand.blip = nil
				end

				TriggerServerEvent("vrp-taxi:taxiArrived", NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(-1))))

				break
			end
			Citizen.Wait(1000)
		end

		SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "hide"})
	end)
end)

RegisterNetEvent("vrp-taxi:passangerEntered")
AddEventHandler("vrp-taxi:passangerEntered", function(code)
	currentCommand.step = 2


	Citizen.CreateThread(function()
		local taxiVeh = GetVehiclePedIsIn(GetPlayerPed(-1))
		SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "build"})
		
		while currentCommand and currentCommand.step == 2 and DoesEntityExist(taxiVeh) do
			local speed = math.floor(GetEntitySpeed(taxiVeh) * 3.6)
			if speed > 20 then
				TriggerServerEvent("vrp-taxi:addMoney", currentCommand.fare, code)
			end
			Citizen.Wait(3000)
		end
		currentCommand = nil

		SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "hide"})
	end)
end)

RegisterNetEvent("vrp-taxi:commandDone")
AddEventHandler("vrp-taxi:commandDone", function()
	currentCommand.step = 3
	SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "hide"})
end)

RegisterNetEvent("vrp-taxi:forceCancelCommand")
AddEventHandler("vrp-taxi:forceCancelCommand", function()
	currentCommand.id = 0
	Citizen.Wait(1500)

	if currentCommand.blip then
		RemoveBlip(currentCommand.blip)
		currentCommand.blip = nil
	end
	currentCommand = nil

	SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "hide"})
end)

RegisterNetEvent("vrp-taxi:taxiSpawned")
AddEventHandler("vrp-taxi:taxiSpawned", function(taxiObj)
	taxiObj = NetworkGetEntityFromNetworkId(taxiObj)

	if DoesEntityExist(taxiObj) then
		SetVehicleFuelLevel(taxiObj, 100.0)
	end
end)

RegisterNetEvent("vrp-taxi:setServiceDuty")
AddEventHandler("vrp-taxi:setServiceDuty", function(tog)
	onDuty = tog

	if onDuty then
		TriggerEvent("vRP:hint", "Te-ai angajat la compania <span style='color: #fbe76e'>"..tog.."</span>, mergi<br>intr-un loc de parcare pentru a prelua comenzi.")
		RegisterKeyMapping("taxiOrdersList", "Deschide lista cu apeluri disponibile", "keyboard", "j")
	end

	Citizen.Wait(500)
	Citizen.CreateThread(function()
		while onDuty do
			local ticks = 1024
			for indx, spots in pairs(taxiParkings) do
				
				for k, pos in pairs(spots) do
					local dist = #(pos - pedPos)
					
					if dist <= 25 then
						DrawMarker(27, pos - vec3(0.0, 0.0, 0.95), 0, 0, 0, 0, 0, 0, 1.65, 1.65, 0.25, 255, 223, 8, 100)
						
						if dist <= 1.5 and not parkingSpot[1] and indx == onDuty then

							local veh = GetVehiclePedIsIn(tempPed, false)
							if veh and IsPedInAnyVehicle(tempPed) and isPlayerInTaxi(veh) then
								parkingSpot = {k, indx}
								TriggerServerEvent("vrp-taxi:enterParkingSpot", parkingSpot)
	
								Citizen.CreateThread(function()
									while #(pos - pedPos) <= 1.5 do
										Citizen.Wait(100)
									end
	
									parkingSpot = {}
									TriggerServerEvent("vrp-taxi:leaveParkingSpot")
								end)
							end
							
						end

						ticks = 1
					end
				end

			end
			Citizen.Wait(ticks)
		end
	end)
end)

RegisterNetEvent("vrp-taxi:alertNewCall", function()
	SendNUIMessage({
		act = "job",
		target = "taxi",
		component = "newCallAlert",
	})
end)

RegisterNetEvent("vrp-taxi:showOrdersList")
AddEventHandler("vrp-taxi:showOrdersList", function(allOds)

	local odsCopy = {} -- n am alte idei pe moment, o sa rezolv mai tz pa
	for key, data in pairs(allOds) do
		data.distance = math.floor(#(data.pos - pedPos))
		table.insert(odsCopy, data)
	end

	TriggerEvent("vRP:interfaceFocus", true)
	SendNUIMessage({
		act = "job",
		target = "taxi",
		component = "commandsList",
		data = {table.len(allOds), odsCopy},
	})
end)

RegisterNetEvent("vrp-taxi:updateOrders")
AddEventHandler("vrp-taxi:updateOrders", function(newOds)

	local odsCopy = {} -- n am alte idei pe moment, o sa rezolv mai tz pa
	for key, data in pairs(newOds) do
		data.distance = math.floor(#(data.pos - pedPos))
		table.insert(odsCopy, data)
	end

	SendNUIMessage({
		act = "job",
		target = "taxi",
		component = "updateCmdsList",
		data = {table.len(newOds), odsCopy},
	})
end)

RegisterCommand("taxiOrdersList", function()
	if onDuty then
		TriggerServerEvent("vrp-taxi:showOrdersList")
	elseif onDuty then
		tvRP.notify("Trebuie sa fi parcat pentru a putea vedea lista de comenzi.", "warning", false, "fas fa-taxi")
	end
end)

-- CUSTOMER Side


RegisterNetEvent("vrp-taxi:notifyThatOrderTaken", function(biz)
	SendNUIMessage({
		act = "job",
		target = "taxi",
		component = "takenCallAlert",
		company = biz,
	})
end)

RegisterNetEvent("vrp-taxi:alertSentCall", function()
	SendNUIMessage({
		act = "job",
		target = "taxi",
		component = "sentCallAlert",
	})
end)

local taxiBlip = nil
RegisterNetEvent("vrp-taxi:notifyTaxiPosition")
AddEventHandler("vrp-taxi:notifyTaxiPosition", function(tpos)
	if taxiBlip then
		RemoveBlip(taxiBlip)
		taxiBlip = nil
	end

	if tpos then
		taxiBlip = AddBlipForCoord(tpos)
		SetBlipSprite(taxiBlip, 198)
		SetBlipDisplay(taxiBlip, 10)
		SetBlipColour(taxiBlip, 5)

		BeginTextCommandSetBlipName("STRING")
	    AddTextComponentString("Taxi")
	    EndTextCommandSetBlipName(taxiBlip)
	end
end)

RegisterNetEvent("vrp-taxi:notifyThatTaxiArrived")
AddEventHandler("vrp-taxi:notifyThatTaxiArrived", function(nid)

	Citizen.Wait(1500)

	if taxiBlip then
		RemoveBlip(taxiBlip)
		taxiBlip = nil
	end
	
	local taxiObj = NetworkGetEntityFromNetworkId(nid)
	if DoesEntityExist(taxiObj) then
		if IsThisModelACar(GetEntityModel(taxiObj)) then

			taxiBlip = AddBlipForEntity(taxiObj)
			SetBlipSprite(taxiBlip, 198)
			SetBlipDisplay(taxiBlip, 10)
			SetBlipColour(taxiBlip, 5)
			SetBlipFlashes(taxiBlip, true)

			BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString("Taxi")
		    EndTextCommandSetBlipName(taxiBlip)

		    while not GetVehiclePedIsIn(GetPlayerPed(-1), false) == taxiObj do
		    	Citizen.Wait(100)
		    end

		    TriggerServerEvent("vrp-taxi:enteredTaxi")
			SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "build"})

		    while not IsPedInVehicle(GetPlayerPed(-1), taxiObj, false) do
		    	Citizen.Wait(100)
		    end
			
		    if taxiBlip then
				RemoveBlip(taxiBlip)
				taxiBlip = nil
			end

		    while GetVehiclePedIsIn(GetPlayerPed(-1)) == taxiObj do
		    	Citizen.Wait(1)
		    end

		    TriggerServerEvent("vrp-taxi:exitedTaxi")
			SendNUIMessage({act = "job", target = "taxi", component = "taximeter", state = "hide"})

		end
	end

end)








RegisterNetEvent("vrp-taxi:populateParkings")
AddEventHandler("vrp-taxi:populateParkings", function(tbl)
	taxiParkings = tbl
	for indx, data in pairs(taxiParkings) do
		-- add blip
		if data then

			local blip = AddBlipForCoord(data[1])
			SetBlipSprite(blip, 198) /* 641 */
			SetBlipColour(blip, 17)
			SetBlipScale(blip, 0.8)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Parcare Taxi: "..indx)
			EndTextCommandSetBlipName(blip)

		end
	end
end)

local inMenu = false

RegisterNetEvent("vrp-taxi:openCompanyMenu", function(bizId, isOwner, bizCarFare)
	if bizId and allBiz[bizId] then
		TriggerEvent("vRP:interfaceFocus", true)
		inMenu = true

		allBiz[bizId].ownCompany = isOwner
		allBiz[bizId].carFare = bizCarFare
		SendNUIMessage({
			act = "job",
			target = "taxi",
			component = "workerMenu",
			data = allBiz[bizId],
		})
		
		allBiz[bizId].ownCompany = nil
		allBiz[bizId].carFare = nil
	end
end)

RegisterNetEvent("vrp-taxi:openManagerMenu", function(bizId, bizData)
	if bizId and allBiz[bizId] then
		SendNUIMessage({
			act = "job",
			target = "taxi",
			component = "managerMenu",
			data = bizData,
		})
	end
end)

RegisterNUICallback("workAsTaxi", function(data, cb)
	TriggerServerEvent("vrp-taxi:workAsTaxi", data[1])
	cb("ok")
end)

RegisterNUICallback("manageTaxiCompany", function(data, cb)
	TriggerServerEvent("vrp-taxi:openManagerMenu", data[1])
	cb("ok")
end)

RegisterNUICallback("sellTaxiCompany", function(data, cb)
	TriggerServerEvent("vrp-taxi:trySellCompany", data[1], tonumber(data[2]))
	cb("ok")
end)

RegisterNUICallback("buyTaxiCompany", function(data, cb)
	TriggerServerEvent("vrp-taxi:tryBuyCompany", data[1])
	cb("ok")
end)

RegisterNUICallback("upgradeTaxiCar", function(data, cb)
	TriggerServerEvent("vrp-taxi:updateTaxiCar", data[1])
	cb("ok")
end)

RegisterNUICallback("withdrawTaxiProfit", function(data, cb)
	TriggerServerEvent("vrp-taxi:withdrawProfit", data[1])
	cb("ok")
end)

RegisterNUICallback("closeTaxiWork", function(data, cb)
	TriggerEvent("vRP:interfaceFocus", false)
	Citizen.SetTimeout(1500, function()
		inMenu = false
	end)
	
	cb("ok")
end)

RegisterNUICallback("acceptTaxiCommand", function(data, cb)
	TriggerServerEvent("vrp-taxi:getCommand", data[1])
	cb("ok")
end)

Citizen.CreateThread(function()

	RegisterNetEvent("vrp-taxi:addBiz", function(bizId, data)
	
		allBiz[bizId] = {
			pos = data.pos,
			car = data.car or 1,
			profit = data.profit or 0,
			name = data.name,
			owner = data.owner or {name = "Primaria Ryde"},
			price = data.price,
		}

		local blip = AddBlipForCoord(data.pos)
		allBiz[bizId].blip = blip
		SetBlipSprite(blip, 280)
		SetBlipColour(blip, 17)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Companie de Taxi: "..data.name)
		EndTextCommandSetBlipName(blip)

	end)

	RegisterNetEvent("vrp-taxi:setClientTableVar", function(bizId, key, value)

		if bizId and allBiz[bizId] then
			allBiz[bizId][key] = value
		end

	end)

	while true do

		for bizId, data in pairs(allBiz) do
			while #(data.pos - pedPos) <= 25 do
			
				DrawMarker(1, data.pos - vec3(0.0, 0.0, 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.85, 255, 223, 8, 200)
				DrawText3D(data.pos.x, data.pos.y, data.pos.z, data.name.."~n~Companie de Taxi", 1.0)


				local newDst = #(data.pos - pedPos)
				if newDst <= 0.5 and not inMenu then
					TriggerServerEvent("vrp-taxi:openCompanyMenu", data.name)
					break
				end

				Citizen.Wait(1)
			end
		end

		Citizen.Wait(3000)
	end

end)