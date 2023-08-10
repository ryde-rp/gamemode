local cfg = module("cfg/garages")
local vipCars = module("cfg/vip")
local carsCfg = module("cfg/cars")
local vehicle_groups = cfg.garage_types
local userVehicles = {}
local VehicleTunning = {}

local state_interval = 30 -- seconds

local garages = {}
local blipFormats = {
  ["elicopter"] = "Hangar %s",
  ["avion"] = "Hangar %s",
}

-- [PRETURI]

local alreadyOutTax = 250

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	exports.oxmysql:query("SELECT * FROM garages", function(result)
		garages = result or {}
	end)
end)

RegisterCommand("loadgarages", function()
	cfg = module("cfg/garages")
	vehicle_groups = cfg.garage_types

	print("^1Load Done")
end, true)

-- [GARAGE LOCAL FUNCTIONS]

local function getUserVehicles(user_id, vtype)
	local vehicles = {}
	for k,v in pairs(userVehicles[user_id]) do
		if v.vtype == vtype then
			local indx = #vehicles + 1
			local cfgData = carsCfg.masiniDealership[v.vehicle]

			vehicles[indx] = {
				name = v.vehicle,
				model = v.vehicle,
				vtype = v.vtype,
				state = v.state,
				km = "0.00",
				fuel = 100,
			}

			if cfgData then
				vehicles[indx].name = cfgData[1] or v.vehicle
			end

			if v.vehStatus then
				local condition = v.vehStatus.condition or {}
				vehicles[indx].km = ("%.2f"):format((condition.km or 0) / 1000)
				vehicles[indx].fuel = condition.fuel_level or 100
			end
			
		end
	end
	return vehicles 
end

local function getFactionVehicles(user_id, player, gtype)
	local data = vehicle_groups[gtype]
	local vehicles = {}
	for k, v in pairs(data) do
		if k ~= "_config" then
			vehicles[#vehicles + 1] = {
				name = v[1],
				model = k,
				state = 1,
				vtype = 'faction',
				fuel = 100,
				km = "0.00",
				image = v[2] or "false",
			}
		end
	end
	return vehicles
end

local function openGarage(user_id,player, vtype, gtype)
	if vtype == 'faction' then
		local userVehs = getFactionVehicles(user_id, player, gtype)
		TriggerClientEvent("vRP:openGarage", player, userVehs, gtype)
	else
		local userVehs = getUserVehicles(user_id, vtype)
		TriggerClientEvent("vRP:openGarage", player, userVehs, gtype)
	end
end

local function build_client_garages(source)
	for i, v in pairs(garages) do
		local x, y, z = v.x, v.y, v.z
		local gtype = v.gtype
		local group = vehicle_groups[gtype]

		if group and x and y and z then
			local gcfg = group._config

			local garage_enter = function(player,area)
				local user_id = vRP.getUserId(player)

				if user_id and vRP.hasPermissions(user_id,gcfg.permissions or {}) and not gcfg.faction then
					openGarage(user_id, player, gcfg.vtype, gtype)
				elseif gcfg.faction then
					if vRP.isUserInFaction(user_id,gcfg.faction) then
						openGarage(user_id, player, gcfg.vtype, gtype)
					else
						vRPclient.notify(player, {"Nu poti accesa acest garaj!", "warning", false, "fas fa-warehouse"})
					end
				end
			end

			local r,g,b,a = table.unpack(gcfg.marker_color or {0, 255, 255, 130})
			
			vRPclient.addMarker(source, {x,y,z-1, 0.45, 0.45, 0.45, r, g, b, a, (gcfg.marker_id or 36), 6})
	        if gcfg.blip_id and not v.hidden then
	          vRPclient.createBlip(source, {"vRP:blip_garaj:"..i, x, y, z, gcfg.blip_id, gcfg.blip_color, (blipFormats[gcfg.vtype] or "Garaj %s"):format(gtype), gcfg.blip_size or 0.6})
	        end

	        vRP.setArea(source, "vRP:garaj_"..i, x, y, z, 3, {
	          key = "E",
	          text = (gcfg.text or "Acceseaza garajul"),
	        }, garage_enter, function() end)
		end
	end
end

-- [GARAGE FUNCTIONS]

function vRP.spawnVehicle(...)
    if GetResourceState("visionac") == "started" then
        return exports["visionac"]:CreateVehicle(...)
    else
        return CreateVehicle(...)
    end
end

function vRP.setVehicleData(user_id, vehicle, key, data)
	if not user_id then return end
	if not vehicle then return end
	if not key then return end
	if not data then return end

	if tostring(data) ~= "off" and tostring(data) ~= '-1' then
		userVehicles[user_id][vehicle][key] = data
		exports.oxmysql:query("UPDATE userVehicles SET ?? = ? WHERE user_id = ? AND vehicle = ?", {key, json.encode(data), user_id, vehicle})
	else
		userVehicles[user_id][vehicle][key] = nil
		exports.oxmysql:query("UPDATE userVehicles SET ?? = NULL WHERE user_id = ? AND vehicle = ?", {key, user_id, vehicle})
	end
end

function vRP.getUserVehicleData(user_id, vehicle)
	return userVehicles[user_id][vehicle]
end

function vRP.setVehicleTunning(user_id, vehicle, tunning)
	if not user_id then return end
	if not vehicle then return end
	if not tunning then return end

	if VehicleTunning[user_id][vehicle] then
		VehicleTunning[user_id][vehicle].tunning = tunning
		exports.oxmysql:execute("UPDATE vehiclesTunning SET tunning = @tunning WHERE user_id = @user_id AND vehicle = @vehicle",{
			['@user_id'] = user_id,
			['@vehicle'] = vehicle,
			['@tunning'] = tunning
		})
	else
		local data = {
			user_id = user_id,
			vehicle = vehicle,
			tunning = tunning,
		}
		VehicleTunning[user_id][vehicle] = data
		exports.oxmysql:execute("INSERT INTO vehiclesTunning (user_id,vehicle,tunning) VALUES(@user_id,@vehicle,@tunning)",{
			['@user_id'] = data.user_id,
			['@vehicle'] = data.vehicle,
			['@tunning'] = data.tunning
		})
	end
end

function vRP.GetUserVehicles(user_id)
	return userVehicles[user_id]
end

function vRP.getVehicleTunning(user_id, vehicle)
	if VehicleTunning[user_id][vehicle] then
		return json.decode(VehicleTunning[user_id][vehicle].tunning)
	end

	return {}
end

function vRP.countOutVehicles(user_id)
	local number = 0
	for k, v in pairs(userVehicles[user_id]) do
		if v.state == 2 then
			number = number + 1
		end
	end
	return number
end

function vRP.countUserVehicles(user_id)
	local number = 0
	for k, v in pairs(userVehicles[user_id]) do
		number = number + 1
	end
	return number
end

function vRP.hasUserVehicle(user_id, model)
	return userVehicles[user_id][model] ~= nil
end

function vRP.addCacheVehicle(user_id, theVeh)
	if not userVehicles[user_id] then userVehicles[user_id] = {} end
	userVehicles[user_id][theVeh.vehicle] = theVeh
end

local function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.oxmysql:query("SELECT * FROM userVehicles WHERE carPlate = @carPlate",{['@carPlate'] = plate_number}, function(result)
		task({result})
	end)
end

function vRP.UpdateCarPlate(user_id, vehicle, plate)
	if not user_id then return end
	if not vehicle then return end
	if not plate then return end

	if userVehicles[user_id][vehicle] then
		userVehicles[user_id][vehicle].carPlate = plate
		exports.oxmysql:execute("UPDATE userVehicles SET carPlate = @carPlate WHERE user_id = @user_id AND vehicle = @vehicle",{
			['@user_id'] = user_id,
			['@vehicle'] = vehicle,
			['@carPlate'] = plate
		})
	end
end

function vRP.giveUserPackVehicles(user_id, type)
	if not userVehicles[user_id] then userVehicles[user_id] = {} end
	for veh, vehType in pairs(vipCars[type]) do
		if not userVehicles[user_id][veh] then
			local carPlate = "LS 69FRP"
			local function searchOne()
			  carPlate = vRP.generatePlateNumber()
		  
			  getIdentifierByPlateNumber(carPlate, function(onePlate)
				if not onePlate or onePlate ~= 0 then
				  searchOne()
				end
			  end)
			end
			searchOne()
            local cfgData = carsCfg.masiniDealership[veh]
			local newVehicle = {
                user_id = user_id,
                vehicle = veh,
                vtype = vehType,
				name = cfgData[1],
				carPlate = carPlate,
                state = 1,
				premium = 1,
			}
			userVehicles[user_id][veh] = newVehicle;
			exports.oxmysql:execute("INSERT INTO userVehicles (user_id,vehicle,vtype,name,carPlate,state,premium,vip) VALUES(@user_id,@vehicle,@vtype,@name,@carPlate,@state,@premium,@vip)",{
				['@user_id'] = newVehicle.user_id,
				['@vehicle'] = newVehicle.vehicle,
				['@vtype'] = newVehicle.vtype,
				['@name'] = newVehicle.name,
				['@carPlate'] = newVehicle.carPlate,
				['@state'] = newVehicle.state,
				['@premium'] = newVehicle.premium
			})
		end
	end
end

function vRP.giveUserPremiumVehicles(user_id, type)
	if not userVehicles[user_id] then userVehicles[user_id] = {} end
	for veh, vehType in pairs(vipCars[type]) do
		if not userVehicles[user_id][veh] then
			local carPlate = "LS 69FRP"
			local function searchOne()
			  carPlate = vRP.generatePlateNumber()
		  
			  getIdentifierByPlateNumber(carPlate, function(onePlate)
				if not onePlate or onePlate ~= 0 then
				  searchOne()
				end
			  end)
			end
			searchOne()
            local cfgData = carsCfg.masiniDealership[veh]
			local newVehicle = {
                user_id = user_id,
                vehicle = veh,
                vtype = vehType,
				name = cfgData[1],
				carPlate = carPlate,
                state = 1,
				premium = 1,
			}
			userVehicles[user_id][veh] = newVehicle;
			exports.oxmysql:execute("INSERT INTO userVehicles (user_id,vehicle,vtype,name,carPlate,state,premium,vip) VALUES(@user_id,@vehicle,@vtype,@name,@carPlate,@state,@premium,@vip)",{
				['@user_id'] = newVehicle.user_id,
				['@vehicle'] = newVehicle.vehicle,
				['@vtype'] = newVehicle.vtype,
				['@name'] = newVehicle.name,
				['@carPlate'] = newVehicle.carPlate,
				['@state'] = newVehicle.state,
				['@premium'] = newVehicle.premium
			})
		end
	end
end

function vRP.removeCacheVehicle(user_id, theVeh)
	userVehicles[user_id][theVeh] = nil
end

function vRP.createGarage(thePlayer, x, y, z, gtype)
	Citizen.Wait(500)
	local theGarage = (#garages or 0) + 1
	if theGarage ~= 0 then
	  local group = vehicle_groups[gtype]
	  if group then
		  local gcfg = group._config
		  exports.oxmysql:execute("INSERT INTO garages (x,y,z,gtype) VALUES(@x,@y,@z,@gtype)",{
			['@x'] = x,
			['@y'] = y,
			['@z'] = z,
			['@gtype'] = gtype
		  })

  
		  table.insert(garages, {x = x, y = y, z = z, gtype = gtype})
		  local r,g,b,a = table.unpack(gcfg.marker_color)
  
		  vRPclient.addMarker(-1,{x,y,z-1, 0.45, 0.45, 0.45, r, g, b, a, (gcfg.marker_id or 36), 6})
		  if not gcfg.hide_blip then
			vRPclient.createBlip(-1, {"vRP:blip_garaj:"..theGarage, x, y, z, gcfg.blip_id, gcfg.blip_color, (blipFormats[gcfg.vtype] or "Garaj %s"):format(gtype), gcfg.blip_size or 0.6})
		  end

		  	local garage_enter = function(player,area)
				local user_id = vRP.getUserId(player)

				if user_id and vRP.hasPermissions(user_id,gcfg.permissions or {}) and not gcfg.faction then
					openGarage(user_id, player, gcfg.vtype, gtype)
				elseif gcfg.faction then
					if vRP.isUserInFaction(user_id,gcfg.faction) then
						openGarage(user_id, player, gcfg.vtype, gtype)
					else
						vRPclient.notify(player, {"Nu poti accesa acest garaj!", "warning", false, "fas fa-warehouse"})
					end
				end
			end
	  
		  	local users = vRP.getUsers()
			for _, theSrc in pairs(users) do
				vRP.setArea(theSrc, "vRP:garaj_"..theGarage, x, y, z, 3, {
					key = "E",
					text = (gcfg.text or "Acceseaza garajul"),
				}, garage_enter, function() end)
			end
		  
		  vRPclient.notify(thePlayer, {("Ai creat un garaj de tip: %s"):format(gtype)})
	  else
		vRPclient.notify(thePlayer, {("Nu exista grupa de garaje numita: %s"):format(gtype), "error"})
	  end
	end
  end

-- [GARAGE EVENTS]

RegisterServerEvent("vRP:spawnGarageVehicle", function(model, vtype)
	local player = source
	local user_id = vRP.getUserId(player)
	local vehTunning = vRP.getVehicleTunning(user_id, model)

	if vtype == 'faction' then
		local carNumber = vRP.generatePlateNumber()
		vRPclient.spawnGarageVehicle(player, {'faction', model, vehTunning, 100, false,carNumber, user_id})					
	else
			local vehicleData = vRP.getUserVehicleData(user_id, model)
			local vehsOut = vRP.countOutVehicles(user_id)
			local vehStatus = vehicleData.vehStatus or {}
			local vehCondition = vehStatus.condition or {}

			if vehsOut >= 1 then
				if vRP.isUserVipPlatinum(user_id) then
					if vehicleData.state == 2  then
						vRP.request(player, ("Acest vehicul este deja afara, vrei sa platesti o taxa de $%d pentru a-l prelua?"):format(alreadyOutTax), false, function(_, ok)
							if ok then
								if vRP.tryFullPayment(user_id,alreadyOutTax) then
									if ((vehCondition.engine_health or 1000) / 10 or 100) < 60 then
										vRP.request(player, ("Vehiculul selectat este avariat, vrei sa platesti o taxa de $%d pentru a il repara?"):format(300), "<i class='fas fa-car' />", function(_, ok)
											if ok then
												if vRP.tryFullPayment(user_id, tonumber(300)) then
													vehCondition.engine_health = 1000
													vehCondition.health = 1000
													vehStatus.petrol_tank_health = 1000
													vRPclient.spawnGarageVehicle(player, {vehicleData.vtype,model, vehTunning, (vehCondition.fuel_level or 100), (vehStatus or false), vehicleData.carPlate, user_id})
												else
													vRPclient.notify(player, {"Nu ai destui bani pentru a plati!", "error"})
												end
											end
										end)
									else
										vRPclient.spawnGarageVehicle(player, {vehicleData.vtype,model, vehTunning, (vehCondition.fuel_level or 100), (vehStatus or false), vehicleData.carPlate, user_id})
									end
								else
									vRPclient.notify(player, {"Nu ai destui bani pentru a plati!", "error"})
								end
							end
						end)
					end
					
				else
					vRPclient.notify(player, {"Nu poti avea mai mult de 1 vehicul in acelasi timp afara!", "warning", false, "fas fa-warehouse"})
				end
				
			end
	
			if ((vehCondition.engine_health or 1000) / 10 or 100) < 60 then
				vRP.request(player, ("Vehiculul selectat este avariat, vrei sa platesti o taxa de $%d pentru a il repara?"):format(300), "<i class='fas fa-car' />", function(_, ok)
					if ok then
						if vRP.tryFullPayment(user_id, tonumber(300)) then
							vehCondition.engine_health = 1000
							vehCondition.health = 1000
							vehStatus.petrol_tank_health = 1000
							vRPclient.spawnGarageVehicle(player, {vehicleData.vtype,model, vehTunning, (vehCondition.fuel_level or 100), (vehStatus or false), vehicleData.carPlate, user_id})
						else
							vRPclient.notify(player, {"Nu ai destui bani pentru a plati!", "error"})
						end
					end
				end)
			else
				vRPclient.spawnGarageVehicle(player, {vehicleData.vtype,model, vehTunning, (vehCondition.fuel_level or 100), (vehStatus or false), vehicleData.carPlate, user_id})
			end
			vRP.setVehicleData(user_id, model, "state", 2)
	
	end
end)

RegisterServerEvent("vRP:despawnGarageVehicle", function(gtype)
	local player = source
	local user_id = vRP.getUserId(player)

	vRPclient.getNearestOwnedVehicle(player, {5}, function(veh, vehType)
		if veh then
			local group = vehicle_groups[gtype]
			local gcfg = group._config

			if vehType == gcfg.vtype then
				if vehType == 'faction' then
					vRPclient.despawnGarageVehicle(player, {veh})
				else
					vRPclient.GetVehicleState(player, {veh}, function(vehStatus)
						vRPclient.getRepairCost(player, {veh, vehStatus}, function(price)
							if price >= 25 then
								vRP.request(player, ("Vehiculul selectat este avariat, vrei sa platesti o taxa de $%d pentru a il repara?"):format(price), "<i class='fas fa-car' />", function(_, ok)
									if ok then
										if vRP.tryFullPayment(user_id, tonumber(price)) then
											vRPclient.repairVehicle(player, {veh}, function(finish)
												if finish then
													vRPclient.GetVehicleState(player, {veh}, function(newStatus)
														vRP.setVehicleData(user_id, veh, "vehStatus", newStatus)
													end)
													vRP.setVehicleData(user_id, veh, "state", 1)
													vRPclient.despawnGarageVehicle(player, {veh})
													vRPclient.notify(player, {"Ai parcat vehiculul in garaj!", "success"})
												end
											end)
										else
											vRPclient.notify(player, {"Nu ai destui bani pentru a plati!", "error"})
										end
									end
								end)
							else
								vRPclient.despawnGarageVehicle(player, {veh})
								vRP.setVehicleData(user_id, veh, "state", 1)
								vRP.setVehicleData(user_id, veh, "vehStatus", vehStatus)
								vRPclient.notify(player, {"Ai parcat vehiculul in garaj!", "success"})
							end
						end)
					end)
				end
			else	
				vRPclient.notify(player, {"Nu poti parca acest vehicul in acest garaj!", "error", false, "fas fa-warehouse"})
			end
		else	
			vRPclient.notify(player, {"Nu ai o masina detinuta in apropiere!", "error"})
		end 
	end)
end)

RegisterServerEvent("vRP:saveVehicleStates", function(vehicles)
	local player = source
	local user_id = vRP.getUserId(player)

	for model, data in pairs(vehicles) do
		if userVehicles[user_id][model] then
			userVehicles[user_id][model]["vehStatus"] = data
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	if userVehicles[user_id] then
		local vehicles = 0;
		local money = vRP.formatMoney(vRP.getMoney(user_id))
		local bankMoney = vRP.formatMoney(vRP.getBankMoney(user_id))
		for model, data in pairs(userVehicles[user_id]) do
			vehicles = vehicles + 1
			if data.vehStatus then
				vRP.setVehicleData(user_id, model, "vehStatus", data.vehStatus)
			end
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id,source,first_spawn)
	if first_spawn then
		Citizen.Wait(5500)
		build_client_garages(source)

		local money = vRP.formatMoney(vRP.getMoney(user_id))
		local bankMoney = vRP.formatMoney(vRP.getBankMoney(user_id))
		local vehicles = 0

		userVehicles[user_id] = {}
		VehicleTunning[user_id] = {}
		exports.oxmysql:query("SELECT * FROM userVehicles WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
			for _, data in pairs(result or {}) do
				userVehicles[user_id][data.vehicle] = data
				vehicles = vehicles + 1
			end
		end)

		exports.oxmysql:query("SELECT * FROM vehiclesTunning WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
			for _, data in pairs(result or {}) do
				VehicleTunning[user_id][data.vehicle] = data
			end
		end)
	end
end)

-- [GARGE VEHICLE ACTIONS]

local veh_actions = {}

local function ch_vehicleActions(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
	    vRP.buildMenu("vehicle", {user_id = user_id, player = player, 0}, function(menu)
			menu.name="Actiuni Vehicul"
			menu.css={top="75px",header_color="rgba(255,125,0,0.75)"}

			for k, v in pairs(veh_actions) do
				menu[k] = {function(player,choice) v[1](user_id,player) end, v[2]}
			end

			if menu then vRP.openMenu(player,menu) end
		end)
	end
end

veh_actions["Vinde Vehicul"] = {
    function(user_id, player)
        vRPclient.getNearestPlayer(player, {5}, function(targetSrc)
            if targetSrc then
                local target_id = vRP.getUserId(targetSrc)
                vRPclient.getNearestOwnedVehicle(player, {10}, function(veh, vehType)
                    if veh then
                        print("veh:", veh)

                        if vehType == "faction" then
                            vRPclient.notify(player, {"Nu poți vinde un vehicul de serviciu!", "error"})
                        else
                            local isPremium = 0
                            local isVIP = 0

                            exports.oxmysql:execute('SELECT premium, vip FROM userVehicles WHERE user_id = @user_id AND vehicle = @vehicle', {
                                ['@user_id'] = user_id,
                                ['@vehicle'] = veh
                            }, function(result)
                                if result[1] then
                                    isPremium = result[1].premium
                                    isVIP = result[1].vip

                                    if isPremium == 1 then
                                        vRPclient.notify(player, {"Nu poți vinde vehicule premium!", "error"})
                                    elseif isVIP == 1 then
                                        vRPclient.notify(player, {"Nu poți vinde vehicule VIP!", "error"})
                                    else
                                        vRP.prompt(player, "SELL VEHICLE", {
                                            {field = "amount", title = "PRETUL CERUT", number = true}
                                        }, function(_, res)
                                            local amount = res["amount"] or 0

                                            if amount then
                                                if amount < 0 then
                                                    return vRPclient.notify(player, {"Pretul nu poate fi negativ!", "error"})
                                                end

                                                if userVehicles[target_id][veh] ~= nil then
                                                    return vRPclient.notify(player, {"Acest jucator are deja acest vehicul!", "error"})
                                                end

                                                vRP.request(player, ("Vrei să vinzi vehiculul pentru $%d?"):format(amount), '<span style="color: #5DA7DB;">SELL</span> VEHICLE', function(_, ok)
                                                    if ok then
                                                        vRP.request(targetSrc, GetPlayerName(player).." vrea să îți vândă "..carsCfg.masiniDealership[veh][1].." pentru $"..amount..". Accepti?", '<span style="color: #5DA7DB;">BUY</span> VEHICLE', function(_, ok)
                                                            if ok then
                                                                if vRP.tryFullPayment(target_id, amount) then
                                                                    vRP.giveMoney(user_id, amount)
                                                                    exports.oxmysql:execute("UPDATE userVehicles SET user_id = @target_id WHERE user_id = @user_id AND vehicle = @vehicle", {
                                                                        ['@target_id'] = target_id,
                                                                        ['@user_id'] = user_id,
                                                                        ['@vehicle'] = veh
                                                                    })
                                                                    local vehData = userVehicles[user_id][veh]
                                                                    userVehicles[user_id][veh] = nil
                                                                    userVehicles[target_id][veh] = vehData

                                                                    local vehTunning = vRP.getVehicleTunning(user_id, veh)
                                                                    if vehTunning ~= nil then
                                                                        exports.oxmysql:execute("UPDATE vehiclesTunning SET user_id = @target_id WHERE user_id = @user_id AND vehicle = @vehicle", {
                                                                            ['@target_id'] = target_id,
                                                                            ['@user_id'] = user_id,
                                                                            ['@vehicle'] = veh
                                                                        })
                                                                        if VehicleTunning[target_id] then
                                                                            VehicleTunning[target_id][veh] = {}
                                                                            VehicleTunning[target_id][veh].tunning = json.encode(vehTunning);
                                                                            VehicleTunning[user_id][veh] = nil
                                                                        else
                                                                            VehicleTunning[target_id] = {}
                                                                            VehicleTunning[target_id][veh] = {}
                                                                            VehicleTunning[target_id][veh].tunning = json.encode(vehTunning);
                                                                            VehicleTunning[user_id][veh] = nil
                                                                        end
                                                                    end
                                                                    vRP.createLog(user_id, "A vândut mașina "..carsCfg.masiniDealership[veh][1].." jucătorului "..GetPlayerName(targetSrc).."("..target_id..") pentru suma de "..vRP.formatMoney(amount).."$", "Vehicles", "Sell-Vehicle", "fa-solid fa-car-rear", 0, "success");
                                                                    vRP.createLog(target_id, "A cumpărat mașina "..carsCfg.masiniDealership[veh][1].." de la jucătorul "..GetPlayerName(player).."("..user_id..") pentru suma de "..vRP.formatMoney(amount).."$", "Vehicles", "Buy-Vehicle", "fa-solid fa-car", 0, "info");
                                                                    vRPclient.despawnGarageVehicle(player, {veh})
                                                                    vRPclient.notify(player, {"Ai vândut vehiculul!", "success"})
                                                                    vRPclient.notify(targetSrc, {"Ai cumpărat vehiculul!", "success"})
                                                                else
                                                                    vRPclient.notify(targetSrc, {"Nu ai destui bani!", "error"})
                                                                    vRPclient.notify(player, {GetPlayerName(targetSrc).." nu are destui bani pentru a cumpăra vehiculul!", "error"})
                                                                end
                                                            else
                                                                vRPclient.notify(player, {"Jucătorul a refuzat oferta!", "error"})
                                                            end
                                                        end)
                                                    end
                                                end)
                                            else
                                                vRPclient.notify(player, {"Pretul nu este valid!", "error"})
                                            end
                                        end)
                                    end
                                else
                                    vRPclient.notify(player, {"Nu ai acest vehicul!", "error"})
                                end
                            end)
                        end
                    else
                        vRPclient.notify(player, {"Nu ai o mașină deținută în apropiere!", "error"})
                    end
                end)
            else
                vRPclient.notify(player, {"Nu ai niciun jucător în apropiere!", "error"})
            end
        end)
    end,
    "Vinde vehiculul celui mai apropiat jucător"
}














veh_actions["🔒 Incuie / Descuie Vehiculul"] = {function(user_id,player)
	vRPclient.getNearestOwnedVehicle(player, {5}, function(vname)
	  if vname then
		vRPclient.vc_toggleLock(player, {vname})
	  else
		vRPclient.notify(player,{"Nu ai un vehicul detinut in apropiere.", "error"})
	  end
	end)
  end, "Incuie / Descuie cel mai apropiat vehicul"}

  function vRP.getVehicleByPlate(plate, callback)
    for user_id, vehicles in pairs(userVehicles) do
        for vehicle, data in pairs(vehicles) do
            if data.carPlate == plate then
                callback(true) -- Plăcuța de înmatriculare există deja
                return
            end
        end
    end

    callback(false) -- Plăcuța de înmatriculare nu există
end


  function sanitizeString(str)
    local sanitizedStr = ""
    local allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

    for i = 1, #str do
        local char = string.sub(str, i, i)
        if string.find(allowedChars, char, 1, true) then
            sanitizedStr = sanitizedStr .. char
        end
    end

    return sanitizedStr
end

veh_actions["Schimba Placuta de Inmatriculare"] = {
    function(user_id, player)
        vRPclient.getNearestOwnedVehicle(player, {5}, function(name)
            if name then
                local plateVouchers = vRP.getPlateVouchers(user_id)
                if plateVouchers >= 1 then
                    vRP.prompt(player, "NUMBER PLATE", {{field = "plate", title = "PLATE NUMBER"},}, function(_, res)
                        local vehPlate = res["plate"]
                        if vehPlate and vehPlate ~= "" then
                            local formattedPlate = vehPlate:upper()
                            if string.match(formattedPlate, "^%d%d%u%u%u$") then
                                local vehicle_plate = "LS " .. formattedPlate
                                if string.len(vehicle_plate) <= 8 and string.len(vehicle_plate) > 0 then
                                    local cleanPlate = sanitizeString(vehicle_plate)
                                    vRP.getVehicleByPlate(vehicle_plate, function(existingPlate)
                                        if existingPlate then
                                            vRPclient.notify(player, {"Aceasta placuta de inmatriculare este detinuta deja de cineva!"})
                                        else
                                            vRPclient.notify(player, {"Placuta de inmatriculare a fost schimbata in: " .. vehicle_plate})
                                            vRP.setPlateVouchers(user_id, plateVouchers - 1)
                                            vRP.UpdateCarPlate(user_id, name, vehicle_plate)
                                            vRPclient.despawnGarageVehicle(player, {name, 15})
                                        end
                                    end)
                                else
                                    vRPclient.notify(player, {"Placuta de inmatriculare nu poate avea mai mult de 8 caractere!"})
                                end
                            else
                                vRPclient.notify(player, {"Formatul nu a fost respectat! Format: 2 cifre + 3 litere la alegere (ex: 43RBY)"})
                            end
                        else
                            vRPclient.notify(player, {"Te rog introdu o valoare pentru plăcuța de înmatriculare!"})
                        end
                    end)
                else
                    vRPclient.notify(player, {"Nu ai un Number plate voucher pentru a-ți putea schimba numărul!"})
                end
            else
                vRPclient.notify(player, {"Nu ai un vehicul deținut în apropiere.", "error"})
            end
        end)
    end,
    "Folosește un Number Plate Voucher pentru a-ți schimba numărul de înmatriculare la mașină."
}



  
  vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
	  -- add vehicle entry
	  local choices = {}

	  choices["🚗 Masina mea"] = {ch_vehicleActions}
  
	  add(choices)
	end
  end)
