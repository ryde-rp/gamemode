local gymLocation = vec3(-1262.4155273438,-360.7312927246,36.994846343994)
local officeLocation = vec3(-1255.207397461,-355.2052307129,36.959602355958)
local flexingPosition = vec3(-1271.4943847656,-358.47592163086,35.959590911866)
local gymObjects = {
	{
		location = vec3(-1268.3404541016,-366.11499023438,36.98369216919),
		type = "Biceps",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1270.0031738282,-362.48083496094,36.983699798584),
		type = "Biceps",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1271.5872802734,-360.09930419922,36.959587097168),
		type = "Tractiuni",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1258.6927490234,-357.79330444336,36.959609985352),
		type = "Flotari",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1263.3516845704,-355.0729675293,36.95959854126),
		type = "Abdomene",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1266.01171875,-356.23614501954,36.959606170654),
		type = "Abdomene",
		workoutDuration = 5500,
	},

	{
		location = vec3(-1260.681640625,-355.88693237304,36.959606170654),
		type = "Yoga",
		workoutDuration = 9500,
	},
}

local gymAnims = {
	["Abdomene"] = "WORLD_HUMAN_SIT_UPS",
	["Yoga"] = "WORLD_HUMAN_YOGA",
	["Biceps"] = "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS",
	["Tractiuni"] = "PROP_HUMAN_MUSCLE_CHIN_UPS",
	["Flotari"] = "WORLD_HUMAN_PUSH_UPS",
}

local isPlayerWorking = false
local armsCooldown = nil
local armsLevel = 0

local function randomFloat()
	math.randomseed(GetGameTimer())
	return string.format("%0.1f", (0.19 + math.random() * (1.0 - 0.19)))
end

local function startWorking(oneObject)
	if isPlayerWorking then
		return false
	end

	if not armsCooldown then
		isPlayerWorking = true
		TriggerEvent("vRP:progressBar", {
			duration = oneObject.workoutDuration,
			text = "🏋🏼‍♂️ Faci "..oneObject.type:lower().."...",
			anim = {
				scenario = gymAnims[oneObject.type],
			},
		}, function()
			math.randomseed(GetGameTimer() + math.random(1, 25))

			local gainStrength = randomFloat()
			local isGaining = math.random(1,150) < 25
			isPlayerWorking = false

			if not isGaining then
				armsLevel = armsLevel + 1
				if armsLevel >= 4 then
					armsLevel = 0

					armsCooldown = GetGameTimer() + 6500
					CreateThread(function()
						while (armsCooldown or 0) > GetGameTimer() do
							Wait(1)
						end

						if armsCooldown then
							tvRP.notify("Bratele tale si-au revenit, acum poti face sport!", "success", false, "fa-solid fa-dumbbell")
							armsCooldown = nil
						end
					end)
				end

				return tvRP.notify("💪🏼 Simti cum ti se umfla muschii iar bratele iti obosesc...", false, "fa-solid fa-dumbbell")
			end

			vRPserver.gainGymStrength({gainStrength})
		end)
	elseif armsCooldown < GetGameTimer() then
		armsCooldown = nil
		startWorking(oneObject)
	else
		tvRP.notify("Bratele ti-au obosit, asteapta putin inainte de a face iar sport..", "warning", false, "fa-solid fa-dumbbell")
	end
end

CreateThread(function()
	RegisterNetEvent("fp-saladeforta:getSubscribe")
	AddEventHandler("fp-saladeforta:getSubscribe", function()
		vRPserver.subscribeToGym({})
	end)

	tvRP.createBlip("vRP_gym", gymLocation.x, gymLocation.y, gymLocation.z, 311, 0, "Sala de Forta", 0.6)
	local isPlayerFlexing = false

	tvRP.createPed("vRPgym:getSubscription", {
		position = officeLocation,
		rotation = 300,
		model = "u_m_y_babyd",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 2.5,
		
		name = "Ciprian Răul",
		description = "Manager Sala de Forta",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau sa-mi fac abonament la sala.", post = "fp-saladeforta:getSubscribe"},
		},
	})

	while true do
		local ticks = 1000
		if #(gymLocation - pedPos) <= 15.5 then
			ticks = 1

			DrawMarker(27, flexingPosition, 0, 0, 0, 0, 0, 0, 1.25, 1.25, 1.25, 255, 219, 46, 120, false, true, false, true)
			DrawMarker(0, flexingPosition, 0, 0, 0, 0, 0, 0, 1.45, 1.45, 1.45, 255, 219, 46, 60, false, true, false, true)
			if #(flexingPosition - pedPos) <= 1.5 then
				if not isPlayerFlexing then
					tvRP.subtitleText("Apasa tasta ~b~E ~w~pentru a-ti flexa muschii")
				else
					tvRP.subtitleText("Apasa ~y~E ~w~pentru a inceta flexarea")
				end

				if IsControlJustReleased(0, 51) then
					isPlayerFlexing = not isPlayerFlexing

					if isPlayerFlexing then
						TaskStartScenarioInPlace(tempPed, "WORLD_HUMAN_MUSCLE_FLEX", 0, true)
					else
						ClearPedTasksImmediately(tempPed)
					end
				end
			end

			for _, objectData in pairs(gymObjects) do
				DrawMarker(20, objectData.location, 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 0, 205, 205, 150, true, true, false, true)

				if #(objectData.location - pedPos) <= 0.5 then
                	DrawText3D(objectData.location.x, objectData.location.y, objectData.location.z + 0.15, "~b~E ~w~- "..objectData.type:gsub("_", " "), 0.55)
					
					if IsControlJustReleased(0, 51) then
						vRPserver.canUseGym({}, function(hasSubscription)
							if not hasSubscription then
								tvRP.notify("Ai nevoie de un abonament activ pentru a putea face sala!", "error")
							else
								startWorking(objectData)
							end
						end)
					end
				end
			end
		end

		Wait(ticks)
	end
end)