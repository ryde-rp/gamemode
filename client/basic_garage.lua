local cars_cfg = module("cfg/cars")

DecorRegister("FairPlay_Owner", 3)
DecorRegister("FairPlay_vmodel", 3)
DecorRegister("FairPlay_vehkm", 1)
DecorRegister("veh_job", 2)

local vehicles = {}
local veh_models = {}
local hash_models = {}
local distance_handler = nil

local check_interval = 15 -- seconds
local update_inverval = 30 -- seconds
local repair_cost = 1000

-- [LOCAL FUNCTIONS]

local function enumVehicles()
  local vehs = {}
  local it, veh = FindFirstVehicle()
  if veh then table.insert(vehs, veh) end
  local ok
  repeat
    ok, veh = FindNextVehicle(it)
    if ok and veh then table.insert(vehs, veh) end
  until not ok
  EndFindVehicle(it)

  return vehs
end

local function registerModels(models)
  for model in pairs(models) do
    local hash = GetHashKey(model)
    if hash then
      hash_models[hash] = model
    end
  end
end

local function cleanupVehicles()
  for model, veh in pairs(vehicles) do
    if not IsEntityAVehicle(veh[2]) then
      vehicles[model] = nil
    end
  end
end

local function checkVehicle(veh)
  if veh and DecorExistOn(veh, "FairPlay_Owner") then
    local model = hash_models[GetEntityModel(veh)]
    if model then
      return DecorGetInt(veh, "FairPlay_Owner"), model
    end
  end
end

local function tryOwnVehicles()
  for _, veh in pairs(enumVehicles()) do
    local cid, model = checkVehicle(veh)
    if cid and tonumber(Player(GetPlayerServerId(tempPlayer)).state.user_id) == cid then -- owned
      local old_veh = vehicles[model]
      if old_veh and IsEntityAVehicle(old_veh[2]) then -- still valid
        if old_veh[2] ~= veh then -- remove this new one
          SetVehicleHasBeenOwnedByPlayer(veh,false)
          SetEntityAsMissionEntity(veh, false, true)
          SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
          Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        end
      else -- no valid old veh
        vehicles[model] = {model, veh} -- re-own
      end
    end
  end
end

-- Set tunning function
local function SetVehicleData(vehicle, data)
	if (data == nil) then return end

	SetVehicleModKit(vehicle, 0)
	SetVehicleAutoRepairDisabled(vehicle, false)

	if (data.plateIndex) then
		SetVehicleNumberPlateTextIndex(vehicle, data.plateIndex)
	end

	if (data.fuelLevel) then
		SetVehicleFuelLevel(vehicle, data.fuelLevel + 0.0)
	end

	if (data.dirtLevel) then
		SetVehicleDirtLevel(vehicle, data.dirtLevel + 0.0)
	end

	if (data.color1) then
		ClearVehicleCustomPrimaryColour(vehicle)

		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, data.color1, color2)
	end

	if (data.color1Custom) then
		SetVehicleCustomPrimaryColour(vehicle, data.color1Custom[1], data.color1Custom[2], data.color1Custom[3])
	end

	if (data.color2) then
		ClearVehicleCustomSecondaryColour(vehicle)

		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, color1, data.color2)
	end

	if (data.color2Custom) then
		SetVehicleCustomSecondaryColour(vehicle, data.color2Custom[1], data.color2Custom[2], data.color2Custom[3])
	end

	if (data.color1Type) then
		SetVehicleModColor_1(vehicle, data.color1Type)
	end

	if (data.color2Type) then
		SetVehicleModColor_2(vehicle, data.color2Type)
	end

	if (data.pearlescentColor) then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, data.pearlescentColor, wheelColor)
	end

	if (data.wheelColor) then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, pearlescentColor, data.wheelColor)
	end

	if (data.wheels) then
		SetVehicleWheelType(vehicle, data.wheels)
	end


	if (data.windowTint) then
		SetVehicleWindowTint(vehicle, data.windowTint)
	end

	if (data.extras) then
		for id = 0, 25 do
			if (DoesExtraExist(vehicle, id)) then
				SetVehicleExtra(vehicle, id, data.extras[tostring(id)] and 0 or 1)
			end
		end
	end

	if (data.neonEnabled) then
		SetVehicleNeonLightEnabled(vehicle, 0, data.neonEnabled[1] == true or data.neonEnabled[1] == 1)
		SetVehicleNeonLightEnabled(vehicle, 1, data.neonEnabled[2] == true or data.neonEnabled[2] == 1)
		SetVehicleNeonLightEnabled(vehicle, 2, data.neonEnabled[3] == true or data.neonEnabled[3] == 1)
		SetVehicleNeonLightEnabled(vehicle, 3, data.neonEnabled[4] == true or data.neonEnabled[4] == 1)
	end

	if (data.neonColor) then
		SetVehicleNeonLightsColour(vehicle, data.neonColor[1], data.neonColor[2], data.neonColor[3])
	end

	if (data.modSmokeEnabled) then
		ToggleVehicleMod(vehicle, 20, true)
	end

	if (data.tyreSmokeColor) then
		SetVehicleTyreSmokeColor(vehicle, data.tyreSmokeColor[1], data.tyreSmokeColor[2], data.tyreSmokeColor[3])
	end

	if (data.dashboardColor) then
		SetVehicleDashboardColour(vehicle, data.dashboardColor)
	end

	if (data.interiorColor) then
		SetVehicleInteriorColour(vehicle, data.interiorColor)
	end

	if (data.modSpoilers) then
		SetVehicleMod(vehicle, 0, data.modSpoilers, false)
	end

	if (data.modFrontBumper) then
		SetVehicleMod(vehicle, 1, data.modFrontBumper, false)
	end

	if (data.modRearBumper) then
		SetVehicleMod(vehicle, 2, data.modRearBumper, false)
	end

	if (data.modSideSkirt) then
		SetVehicleMod(vehicle, 3, data.modSideSkirt, false)
	end

	if (data.modExhaust) then
		SetVehicleMod(vehicle, 4, data.modExhaust, false)
	end

	if (data.modFrame) then
		SetVehicleMod(vehicle, 5, data.modFrame, false)
	end

	if (data.modGrille) then
		SetVehicleMod(vehicle, 6, data.modGrille, false)
	end

	if (data.modHood) then
		SetVehicleMod(vehicle, 7, data.modHood, false)
	end

	if (data.modFender) then
		SetVehicleMod(vehicle, 8, data.modFender, false)
	end

	if (data.modRightFender) then
		SetVehicleMod(vehicle, 9, data.modRightFender, false)
	end

	if (data.modRoof) then
		SetVehicleMod(vehicle, 10, data.modRoof, false)
	end

	if (data.modEngine) then
		SetVehicleMod(vehicle, 11, data.modEngine, false)
	end

	if (data.modBrakes) then
		SetVehicleMod(vehicle, 12, data.modBrakes, false)
	end

	if (data.modTransmission) then
		SetVehicleMod(vehicle, 13, data.modTransmission, false)
	end

	if (data.modHorns) then
		SetVehicleMod(vehicle, 14, data.modHorns, false)
	end

	if (data.modSuspension) then
		SetVehicleMod(vehicle, 15, data.modSuspension, false)
	end

	if (data.modArmor) then
		SetVehicleMod(vehicle, 16, data.modArmor, false)
	end

	if (data.modTurbo) then
		ToggleVehicleMod(vehicle,  18, data.modTurbo)
	end

	if (data.modXenon) then
		ToggleVehicleMod(vehicle, 22, true)
		SetVehicleXenonLightsColour(vehicle, data.modXenon)
	end

	if (data.modFrontWheels) then
		SetVehicleMod(vehicle, 23, data.modFrontWheels, false)
	end

	if (data.modBackWheels) then
		SetVehicleMod(vehicle, 24, data.modBackWheels, false)
	end

	if (data.modPlateHolder) then
		SetVehicleMod(vehicle, 25, data.modPlateHolder, false)
	end

	if (data.modVanityPlate) then
		SetVehicleMod(vehicle, 26, data.modVanityPlate, false)
	end

	if (data.modTrimA) then
		SetVehicleMod(vehicle, 27, data.modTrimA, false)
	end

	if (data.modOrnaments) then
		SetVehicleMod(vehicle, 28, data.modOrnaments, false)
	end

	if (data.modDashboard) then
		SetVehicleMod(vehicle, 29, data.modDashboard, false)
	end

	if (data.modDial) then
		SetVehicleMod(vehicle, 30, data.modDial, false)
	end

	if (data.modDoorSpeaker) then
		SetVehicleMod(vehicle, 31, data.modDoorSpeaker, false)
	end

	if (data.modSeats) then
		SetVehicleMod(vehicle, 32, data.modSeats, false)
	end

	if (data.modSteeringWheel) then
		SetVehicleMod(vehicle, 33, data.modSteeringWheel, false)
	end

	if (data.modShifterLeavers) then
		SetVehicleMod(vehicle, 34, data.modShifterLeavers, false)
	end

	if (data.modAPlate) then
		SetVehicleMod(vehicle, 35, data.modAPlate, false)
	end

	if (data.modSpeakers) then
		SetVehicleMod(vehicle, 36, data.modSpeakers, false)
	end

	if (data.modTrunk) then
		SetVehicleMod(vehicle, 37, data.modTrunk, false)
	end

	if (data.modHydrolic) then
		SetVehicleMod(vehicle, 38, data.modHydrolic, false)
	end

	if (data.modEngineBlock) then
		SetVehicleMod(vehicle, 39, data.modEngineBlock, false)
	end

	if (data.modAirFilter) then
		SetVehicleMod(vehicle, 40, data.modAirFilter, false)
	end

	if (data.modStruts) then
		SetVehicleMod(vehicle, 41, data.modStruts, false)
	end

	if (data.modArchCover) then
		SetVehicleMod(vehicle, 42, data.modArchCover, false)
	end

	if (data.modAerials) then
		SetVehicleMod(vehicle, 43, data.modAerials, false)
	end

	if (data.modTrimB) then
		SetVehicleMod(vehicle, 44, data.modTrimB, false)
	end

	if (data.modTank) then
		SetVehicleMod(vehicle, 45, data.modTank, false)
	end

	if (data.modWindows) then
		SetVehicleMod(vehicle, 46, data.modWindows, false)
	end

	if (data.modLivery) then
		SetVehicleMod(vehicle, 48, data.modLivery, false)
	end

	if (data.livery) then
		SetVehicleLivery(vehicle, data.livery)
	end
end

local function getVehicleState(veh)
	local state = {
		condition = {
			health = GetEntityHealth(veh),
			engine_health = GetVehicleEngineHealth(veh),
			petrol_tank_health = GetVehiclePetrolTankHealth(veh),
			dirt_level = GetVehicleDirtLevel(veh),
			km = DecorGetFloat(veh, "FairPlay_vehkm"),
			fuel_level = math.ceil(GetVehicleFuelLevel(veh)),
		},
	}

	state.condition.windows = {}
	for i = 0, 7 do
		state.condition.windows[i] = IsVehicleWindowIntact(veh, i)
	end

	state.condition.tyres = {}
	for i = 0, 7 do
		local tyre_state = 2 -- 2: fine, 1: burst, 0: completely burst
		if IsVehicleTyreBurst(veh, i, true) then
			tyre_state = 0
		elseif IsVehicleTyreBurst(veh, i, false) then
			tyre_state = 1
		end

		state.condition.tyres[i] = tyre_state
	end

	state.condition.doors = {}
	for i = 0, 5 do
		state.condition.doors[i] = not IsVehicleDoorDamaged(veh, i)
	end

	state.locked = (GetVehicleDoorLockStatus(veh) >= 2)

	return state
end

local function setVehicleState(veh, state)
	if state.condition then
		if state.condition.health then
			SetEntityHealth(veh, state.condition.health + 0.0)
		end

		if state.condition.engine_health then
			SetVehicleEngineHealth(veh, state.condition.engine_health + 0.0)
		end

		if state.condition.petrol_tank_health then
			SetVehiclePetrolTankHealth(veh, state.condition.petrol_tank_health + 0.0)
		end

		if state.condition.km then
			DecorSetFloat(veh, "FairPlay_vehkm", state.condition.km)
		else
			DecorSetFloat(veh, "FairPlay_vehkm", 0.0)
		end

		if state.condition.dirt_level then
			SetVehicleDirtLevel(veh, state.condition.dirt_level)
		end

		if state.condition.windows then
			for i, window_state in pairs(state.condition.windows) do
				if not window_state then
					SmashVehicleWindow(veh, tonumber(i))
				end
			end
		end

		if state.condition.tyres then
			for i, tyre_state in pairs(state.condition.tyres) do
				if tyre_state < 2 then
					SetVehicleTyreBurst(veh, tonumber(i), (tyre_state == 1), 1000.01)
				end
			end
		end

		if state.condition.doors then
			for i, door_state in pairs(state.condition.doors) do
				if not door_state then
					SetVehicleDoorBroken(veh, tonumber(i), true)
				end
			end
		end
	end

	if state.locked ~= nil then
		if state.locked then -- lock
			SetVehicleDoorsLocked(veh, 2)
			SetVehicleDoorsLockedForAllPlayers(veh, true)
		else -- unlock
			SetVehicleDoorsLockedForAllPlayers(veh, false)
			SetVehicleDoorsLocked(veh, 1)
			SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
		end
	end
end

-- [GARAGE FUNCTIONS]

function tvRP.getVehicleInfos(veh)
	if veh and DecorExistOn(veh, "FairPlay_Owner") then
		local model = hash_models[GetEntityModel(veh)]
		if model then
		  return DecorGetInt(veh, "FairPlay_Owner"), model
		end
	end
end

function tvRP.GetVehicleState(vname)
	local veh = vehicles[vname]

	local state = {
		condition = {
			health = GetEntityHealth(veh[2]),
			engine_health = GetVehicleEngineHealth(veh[2]),
			petrol_tank_health = GetVehiclePetrolTankHealth(veh[2]),
			dirt_level = GetVehicleDirtLevel(veh[2]),
			km = DecorGetFloat(veh[2], "FairPlay_vehkm"),
			fuel_level = math.ceil(GetVehicleFuelLevel(veh[2])),
		},
	}

	state.condition.windows = {}
	for i = 0, 7 do
		state.condition.windows[i] = IsVehicleWindowIntact(veh[2], i)
	end

	state.condition.tyres = {}
	for i = 0, 7 do
		local tyre_state = 2 -- 2: fine, 1: burst, 0: completely burst
		if IsVehicleTyreBurst(veh[2], i, true) then
			tyre_state = 0
		elseif IsVehicleTyreBurst(veh[2], i, false) then
			tyre_state = 1
		end

		state.condition.tyres[i] = tyre_state
	end

	state.condition.doors = {}
	for i = 0, 5 do
		state.condition.doors[i] = not IsVehicleDoorDamaged(veh[2], i)
	end

	state.locked = (GetVehicleDoorLockStatus(veh[2]) >= 2)

	return state
end

function tvRP.getNearestVehicles(radius)
	local pedPos = GetEntityCoords(PlayerPedId())
	local vehs = {}
	local handle, vehicle = FindFirstVehicle()
	local finished = false

	repeat
		if DoesEntityExist(vehicle) then
			local dst = #(GetEntityCoords(vehicle) - pedPos)

			if dst < radius then
				table.insert(vehs, NetworkGetNetworkIdFromEntity(vehicle))
			end
		end
		finished, vehicle = FindNextVehicle(handle)
	until not finished
	EndFindVehicle(handle)

	if #vehs == 0 then
		tvRP.notify("Nu exista nici un vehicul langa tine")
	end

	return vehs
end

function tvRP.isMyVehicleUsed(vname)
	local vehicle = vehicles[vname]
	if vehicle then
		if GetPedInVehicleSeat(vehicle[2], -1) == 0 then
			return false
		else
			return true
		end
	end
	return false
end 

function tvRP.GetVehicleModel(veh)
	return hash_models[veh] or false
end

function tvRP.getNearestVehicle(radius, retNetworkId)
	local ped = GetPlayerPed(-1)
	if IsPedSittingInAnyVehicle(ped) then
		if retNetworkId then
			return NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(ped, true))
		else
			return GetVehiclePedIsIn(ped, true)
		end
	else
		local pedPos = GetEntityCoords(ped)
		local veh = GetClosestVehicle(pedPos, radius+0.0001, 0, 7)

		if veh ~= 0 then
			if retNetworkId then
				return NetworkGetNetworkIdFromEntity(veh)
			else
				return veh
			end
		else
			local handle, vehicle = FindFirstVehicle()
			local finished = false
			local minPos = radius + 1

			repeat
				if DoesEntityExist(vehicle) then
					local dst = #(GetEntityCoords(vehicle) - pedPos)

					if dst < radius and dst < minPos then
						minPos, veh = dst, vehicle
					end
				end
				finished, vehicle = FindNextVehicle(handle)
			until not finished
			EndFindVehicle(handle)

			if veh ~= 0 then
				if retNetworkId then
					return NetworkGetNetworkIdFromEntity(veh)
				else
					return veh
				end
			else
				return 0
			end
		end
	end
end

-- try to re-own the nearest vehicle
function tvRP.tryOwnNearestVehicle(radius)
    local veh = tvRP.getNearestVehicle(radius)
    if veh then
        local source, vname = tvRP.getVehicleInfos(veh)
        if source and source == GetPlayerServerId(PlayerId()) then
            if vehicles[vname] ~= veh then
                vehicles[vname] = veh
            end
        end
    end
end

function tvRP.isPlayerInAnyVehicle(eject)
	local ped = PlayerPedId()
	if IsPedSittingInAnyVehicle(ped) then
		if eject then
			TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, true), 16)
		end
		return true
	else return false end
end

function tvRP.isInOwnedCar(name)
    local vehicle = vehicles[name]
    if vehicle then
        if GVEHICLE ~= 0 then
            if vehicle[2] == GVEHICLE then
                return true
            end
        end
        return false
    end
    return false
end

-- try to get a vehicle at a specific position
function tvRP.getVehicleAtPosition(startVector)
  local foundVehs = EnumerateEntitiesWithinDistance(tvRP.getCVehicles(), startVector, 5.0)
  
  if #foundVehs > 0 then
    return foundVehs
  end

  return false
end

function tvRP.getNearestOwnedVehicle(radius)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local veh = false
	local veh_type = false

	for k, v in pairs(vehicles) do
		print(json.encode(v))
		local vehCoords = GetEntityCoords(v[2])
		local dist = #(playerCoords - vehCoords)

		if dist <= radius + 0.0001 then
			veh = k
			veh_type = v[3]
		end
	end

	return veh, veh_type
end

function tvRP.getNearestOwnedJobVehicle(radius)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local veh = false
	local veh_type = false

	for k, v in pairs(vehicles) do
		local vehCoords = GetEntityCoords(v[2])
		local dist = #(playerCoords - vehCoords)

		if dist <= radius + 0.0001 and DecorExistOn(v[2], "veh_job")  then
			veh = v[2]
			veh_type = v[3]
		end
	end

	return veh, veh_type
end

-- return ok,x,y,z
function tvRP.getAnyOwnedVehiclePosition()
	for k,v in pairs(vehicles) do
		if IsEntityAVehicle(v[2]) then
			local x,y,z = table.unpack(GetEntityCoords(v[2],true))
			return true,x,y,z
		end
	end

	return false,0,0,0
end

function tvRP.getPersonalVehicle()
	for k,v in pairs(vehicles) do
		if IsEntityAVehicle(v[3]) then
			return true,v[3]
		end
	end

	return false, nil
end

-- return x,y,z
function tvRP.getOwnedVehiclePosition(vname)
	local vehicle = vehicles[vname]
	local x,y,z = 0,0,0

	if vehicle then
		x,y,z = table.unpack(GetEntityCoords(vehicle[2],true))
	end

	return x,y,z
end

-- return ok, vehicule network id
function tvRP.getOwnedVehicleId(vname)
	local vehicle = vehicles[vname]
	if vehicle then
		return true, NetworkGetNetworkIdFromEntity(vehicle[2])
	else
		return false, 0
	end
end

-- eject the ped from the vehicle
function tvRP.ejectVehicle()
	local ped = GetPlayerPed(-1)
	if IsPedSittingInAnyVehicle(ped) then
		local veh = GetVehiclePedIsIn(ped,false)
		TaskLeaveVehicle(ped, veh, 4160)
	end
end

function tvRP.fixNearestVeh(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function tvRP.replaceNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    if GetEntitySpeed(veh)*3.6 < 10 then
      SetVehicleOnGroundProperly(veh)
    else
      tvRP.notify("Vehiculul trebuie sa stea pe loc!", "error")
    end
  end
end

function tvRP.getRepairCost(model, state)
	local vehicle = vehicles[model]
	local price = 0

	if vehicle then
		local vehHealth = (GetVehicleBodyHealth(vehicle[2]) / 10) -- 0 - 100
		local engine_health = (state.condition.engine_health / 10) -- 0 - 100
		local petrol_tank_health = (state.condition.petrol_tank_health / 10) -- 0 - 100
		local dmg = 0

		if vehHealth <= 0 then
			vehHealth = 0
		end
		if engine_health <= 0 then
			engine_health = 0
		end
		if petrol_tank_health <= 0 then
			petrol_tank_health = 0
		end

		while dmg + vehHealth + engine_health + petrol_tank_health < 300 do
			dmg = dmg + 1
			Citizen.Wait(0)
		end

		if dmg > 0 then
			price = math.floor((repair_cost / 100) * dmg) -- percententage based on vehHealth
		end
	end

	return price
end

function tvRP.repairVehicle(model)
	local vehicle = vehicles[model]

	if vehicle then
		local veh = vehicle[2]
		local fuel = GetVehicleFuelLevel(veh)
		FreezeEntityPosition(veh, true)
		TriggerEvent("vRP:progressBar", {
			duration = 5000,
			text = "Iti este reparata masina..",
		})
		Citizen.Wait(5000)

		SetVehicleFixed(veh)
		SetVehicleFuelLevel(veh, fuel)
		FreezeEntityPosition(veh, false)
		return true
	end
end

function tvRP.isInAnyCar()
	return (IsPedInAnyVehicle(PlayerPedId(), true) or false)
end

-- [GARAGE THREADS]

local oldpos = 0;
local vehicle_odometer = nil
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		local veh = GetVehiclePedIsIn(ped)
		local seat = 0
		if veh ~= 0 then
			seat = GetPedInVehicleSeat(veh, -1)
		else
			seat = 0
		end
		if IsThisModelACar(GetEntityModel(veh)) then
			if seat == ped then
				if vehicle_odometer then
					if IsVehicleOnAllWheels(veh) then
						local coords = GetEntityCoords(veh)
						if oldpos ~= nil then
							local dist = #(coords - oldpos)
							vehicle_odometer = vehicle_odometer + dist
							DecorSetFloat(veh, "FairPlay_vehkm", vehicle_odometer)
						end
						oldpos = coords
					end
				else
					vehicle_odometer = DecorGetFloat(veh, "FairPlay_vehkm") or 0
				end
			else
				vehicle_odometer = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(update_inverval * 1000)

		local states = {}
		for model, veh in pairs(vehicles) do
			if IsEntityAVehicle(veh[2]) then
				local state = getVehicleState(veh[2])
				
				states[model] = state
			end 
		end

		TriggerServerEvent("vRP:saveVehicleStates", states)
	end 
end)

Citizen.CreateThread(function()
    while true do
      	Citizen.Wait(check_interval*1000)
      	cleanupVehicles()
    	tryOwnVehicles() -- get back network lost vehicles
    end
  end)

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	registerModels(cars_cfg.masiniDealership)
end)

-- Vehicle Spawns

function tvRP.spawnGarageVehicle(vtype,name, tunning, fuelLevel, vehStatus, carPlate, user_id)
    local mhash = GetHashKey(name)
    local i = 0
    while not HasModelLoaded(mhash) and i < 1000 do
        RequestModel(mhash)
        Citizen.Wait(10)
        i = i+1
    end

	if HasModelLoaded(mhash) then
		local x,y,z = tvRP.getPosition()
		local nveh = CreateVehicle(mhash, x,y,z+0.5, GetEntityHeading(PlayerPedId()), true, false)
		NetworkFadeInEntity(nveh, 0)
		
		SetVehicleFuelLevel(nveh, 100.0)
		SetVehicleNumberPlateText(nveh, carPlate)
		SetPedIntoVehicle(PlayerPedId(), nveh, -1)
		SetVehicleOnGroundProperly(nveh)
        SetEntityInvincible(nveh, false)
		TriggerEvent("vrp_garages:setVehicle", GetHashKey(name), {name,nveh,vtype})
		DecorSetInt(nveh, "FairPlay_Owner", tonumber(user_id))
		DecorSetInt(nveh, "FairPlay_vmodel", veh_models[name])
		SetVehicleData(nveh, tunning)
	
		vehicles[name] = {name,nveh,vtype} -- add vehicle to table
		
		if vtype == "remorca" or vtype == "camion" then
			DecorSetBool(nveh, "veh_job", true)
		end
		
		if vehStatus then
			setVehicleState(nveh, vehStatus)
		end
	end
end

function tvRP.despawnGarageVehicle(vname,max_range)
	local vehicle = vehicles[vname]
		if vehicle then
			SetVehicleHasBeenOwnedByPlayer(vehicle[2],false)
			Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[2], false, true) -- set not as mission entity
			SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[2]))
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[2]))

			if DoesEntityExist(vehicle[2]) then
				tvRP.notify("A aparut o problema la despawnarea masinii.")
				return false
			else
				vehicles[vname] = nil
				return true
			end
		end
	return false
end

-- [VEHCILE COMMANDS FUNCTIONS]

function tvRP.vc_toggleLock(vname)
	local vehicle = vehicles[vname]
	if vehicle then

		local veh = vehicle[2]
		local locked = GetVehicleDoorLockStatus(veh) >= 2

		Citizen.CreateThread(function()
			if locked then
				SetVehicleDoorsLockedForAllPlayers(veh, false)
				SetVehicleDoorsLocked(veh,1)
				SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
				Citizen.Wait(300)
				tvRP.notify("Vehiculul a fost descuiat.", "info")
			else
				SetVehicleDoorsLocked(veh,2)
				SetVehicleDoorsLockedForAllPlayers(veh, true)
				Citizen.Wait(300)
				tvRP.notify("Vehiculul a fost incuiat.", "info")
			end
		end)
		
		local dict = "anim@mp_player_intmenu@key_fob@"
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end

		if not IsPedInAnyVehicle(PlayerPedId(), true) then
			TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
		end
		
		SetVehicleLights(veh, 2)
		Citizen.Wait(150)
		SetVehicleLights(veh, 0)
		
		local activePly = GetActivePlayers()
		local activeSrc = {}
		for _, ply in ipairs(activePly) do
			table.insert(activeSrc, GetPlayerServerId(ply))
		end
		
		TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10.0, "carLock", 0.8, activeSrc)
		Citizen.Wait(150)
		SetVehicleLights(veh, 2)
		Citizen.Wait(150)
		SetVehicleLights(veh, 0)
	end
end

function tvRP.vc_openDoor(vname, door_index)
	local vehicle = vehicles[vname]
	if vehicle then
		SetVehicleDoorOpen(vehicle[2],door_index,0,false)
	end
end

function tvRP.vc_closeDoor(vname, door_index)
	local vehicle = vehicles[vname]
	if vehicle then
		SetVehicleDoorShut(vehicle[2],door_index)
	end
end

-- [EVENTS]

RegisterNetEvent("vRP:openGarage")
AddEventHandler("vRP:openGarage", function(userVehs, name, id)
	if #userVehs < 1 then
		return tvRP.notify("Nu detii vehicule in acest garaj!", "error", false, "fas fa-warehouse")
	end

	SendNUIMessage({
		act = "interface",
		target = "garage",
		event = "show",

		vehicles = userVehs,
		garageName = name,
	})

	TriggerEvent("vRP:interfaceFocus", true)
	PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
end)


RegisterNUICallback("spawnGarageVehicle", function(data, cb)
	TriggerEvent("vRP:interfaceFocus", false)
	TriggerServerEvent("vRP:spawnGarageVehicle", data.model, data.vtype)
	cb("ok")
end)

RegisterNUICallback("despawnGarageVehicle", function(data, cb)
	TriggerEvent("vRP:interfaceFocus", false)
	TriggerServerEvent("vRP:despawnGarageVehicle", data.garage)
	cb("ok")
end)

-- [GARAGE VEH ACTIONS]

RegisterCommand("togCarLockState", function()
	if tvRP.isHandcuffed() then return end
  
	local theCar = tvRP.getNearestOwnedVehicle(10)
	if not theCar then
	  return tvRP.notify("Vehiculul este prea departe!", "error")
	end
	 
	tvRP.vc_toggleLock(theCar)
  end)
  
  RegisterKeyMapping("togCarLockState", "Incuie/descuie un vehicul personal", "keyboard", "F3")