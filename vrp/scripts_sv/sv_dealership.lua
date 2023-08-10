local cfg = module("cfg/dealership")

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
		TriggerClientEvent("vRP:setDealershipConfig", source, cfg)
	end
end)

local function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.oxmysql:query("SELECT * FROM userVehicles WHERE carPlate = @carPlate",{['@carPlate'] = plate_number}, function(result)
		task({result})
	end)
end

RegisterServerEvent("fp-dealership:buyVehicle", function(model, category)
	local user_id = vRP.getUserId(source)
	local vtype = cfg.vehicle_types[category] or "ds"
	local vx = cfg.vehicles[category][model]
	local boughtOne = false

	if vx then
		if vRP.hasUserVehicle(user_id, model) then
			return vRPclient.notify(source, {"Detii deja aceast vehicul intr-un garaj.", "error", false, "fas fa-warehouse"})
		end

		if category == "premium" or vx.fpc then
			boughtOne = vRP.tryCoinsPayment(user_id, vx.price or 1, true)
		else
			boughtOne = vRP.tryPayment(user_id, vx.price, true)
			if boughtOne then
				vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(vx.price), "success"})
			end
		end
	
		if boughtOne then
			vRPclient.notify(source, {"Ai achizitionat "..vx.name, "info", false, "fas fa-warehouse"})

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
            
			local newVehicle = {
                user_id = user_id,
                vehicle = model,
                vtype = vtype,
				name = vx.name,
				carPlate = carPlate,
                state = 1,
			}

			if category == "premium" then
				newVehicle.premium = true
			end


			exports.oxmysql:execute("INSERT INTO userVehicles (user_id,vehicle,vtype,name,carPlate,state) VALUES(@user_id,@vehicle,@vtype,@name,@carPlate,@state)",{
				['@user_id'] = newVehicle.user_id,
				['@vehicle'] = newVehicle.vehicle,
				['@vtype'] = newVehicle.vtype,
				['@name'] = newVehicle.name,
				['@carPlate'] = newVehicle.carPlate,
				['@state'] = newVehicle.state
			})
            vRP.addCacheVehicle(user_id, newVehicle)
		end

	end
end)


RegisterCommand("addvehplates", function(player)
	if player == 0 then
		local vehUpdated = 0
		exports.oxmysql:query("SELECT * FROM userVehicles", function(result)
			for k, v in pairs(result) do
				if v.name then
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
	
					vehUpdated = vehUpdated + 1
					print("A fost adaugat numarul de inmatriculare "..carPlate.." pentru masina "..v.name.. " jucatorului cu id-ul "..v.user_id..". ^1TOTAL MASINI ACTUALIZATE: "..vehUpdated..".")
					exports.oxmysql:execute("UPDATE userVehicles SET carPlate = @carPlate WHERE user_id = @user_id AND vehicle = @vehicle",{
						['@user_id'] = v.user_id,
						['@vehicle'] = v.vehicle,
						['@carPlate'] = carPlate
					})
					Wait(100)
				end
			end
		end)
	end
end)


function vRP.isUserDealershipManager(user_id)
	return vRP.isUserDeveloper(user_id)
end

function tvRP.isUserDealershipManager()
	local user_id = vRP.getUserId(source)
	return vRP.isUserDealershipManager(user_id)
end