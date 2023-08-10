local isJoiningBed = false
local inTreatment = false
local documentLocations = {}

local hospitalBeds = {}
RegisterNetEvent("vRP:setHospitalBeds", function(x, y)
	hospitalBeds = x
	documentLocations = y
end)

function tvRP.isHospitalTreated()
	return inTreatment
end

local function disableControls()
	DisableControlAction(0, 24, true) 
	DisableControlAction(0, 257, true)
	DisableControlAction(0, 25, true)
	DisableControlAction(0, 263, true)
	DisableControlAction(0, 32, true)
	DisableControlAction(0, 34, true)
	DisableControlAction(0, 31, true)
	DisableControlAction(0, 30, true)
	DisableControlAction(0, 45, true)
	DisableControlAction(0, 44, true)
	DisableControlAction(0, 37, true)
	DisableControlAction(0, 23, true)
	DisableControlAction(0, 289, true)
	DisableControlAction(0, 170, true)
	DisableControlAction(0, 167, true)
	DisableControlAction(0, 0, true)
	DisableControlAction(0, 26, true)
	DisableControlAction(0, 73, true)
	DisableControlAction(2, 199, true)
	DisableControlAction(0, 59, true)
	DisableControlAction(0, 71, true)
	DisableControlAction(0, 72, true)
	DisableControlAction(2, 36, true)
	DisableControlAction(0, 47, true)
	DisableControlAction(0, 264, true)
	DisableControlAction(0, 257, true)
	DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)
	DisableControlAction(0, 143, true)
	DisableControlAction(0, 75, true)
	DisableControlAction(27, 75, true)
end

local function joinBed(theBed, htype)
	inTreatment = true
	local bedData = hospitalBeds[htype][theBed]
	loadAnimDict("amb@lo_res_idles@")

	SetEntityCoordsNoOffset(tempPed, bedData.pos, false, false, false, true)
	SetEntityHeading(tempPed, bedData.pos.h)

	tvRP.notify("Ai fost internat in spital iar un medic te va ajuta cat de curand!", "error", false, "fas fa-user-nurse")

	CreateThread(function()
		math.randomseed(GetGameTimer())
		local addedTime = math.min(1, math.random(1, 2))
		local donePercent = 0
		tvRP.setHealth(200)

		CreateThread(function()
			while inTreatment do
				donePercent = donePercent + 1
				Wait(2000 * addedTime)
			end
		end)

		while inTreatment do
			if donePercent >= 100 then
				inTreatment = false
			end

			disableControls()

			if IsEntityPlayingAnim(tempPed, 'amb@lo_res_idles@', 'world_human_bum_slumped_left_lo_res_base', 3) ~= 1 then
				TaskPlayAnim(tempPed, "amb@lo_res_idles@", "world_human_bum_slumped_left_lo_res_base", 5.0, 1.0, -1, 33, 0, 0, 0, 0)
			end

			DrawRectText(pedPos.x, pedPos.y, pedPos.z + 0.2, "~w~ Te afli sub tratament...  ~b~"..donePercent.."%")
			if addedTime > 1 then
				DrawRectText(pedPos.x, pedPos.y, pedPos.z + 0.1, "~HC_28~Ranile sunt destul de grave, vei sta mai mult...")
			end

			DisablePlayerFiring(tempPlayer, true)
			Wait(1)
		end

		DisablePlayerFiring(tempPlayer, false)
		ClearPedTasks(tempPed)
		tvRP.playAnim(false, {{"switch@franklin@bed", "sleep_getup_rubeyes"}})
		tvRP.notify("Un medic te-a ingrijit si ai fost externat!", "info", false, "fas fa-user-nurse")
		TriggerServerEvent("hospital$leaveLastBed")
	end)
end

CreateThread(function()
	while true do
		for _, v in pairs(documentLocations) do
			local enterPos = v[1]

			while #(enterPos - pedPos) <= 12.5 do
				local recalcDist = #(enterPos - pedPos)
				DrawMarker(20, enterPos.x, enterPos.y, enterPos.z - 0.250, 0, 0, 0, 0, 0, 0, 0.40, 0.40, -0.40, 255, 0, 0, 100, true, true, false, true)
				
				if recalcDist <= 1.5 then
					DrawText3D(enterPos.x, enterPos.y, enterPos.z + 0.150, "~b~E ~w~- Interneaza-te in spital", 0.5)

					while recalcDist <= 1.0 do
						recalcDist = #(enterPos - pedPos)
						DrawText3D(enterPos.x, enterPos.y, enterPos.z + 0.150, "~b~E ~w~- Interneaza-te in spital", 0.5)

						while isJoiningBed do
							Wait(100)
						end

						if IsControlJustReleased(0, 51) then
							if not isJoiningBed then
								isJoiningBed = true

								vRPserver.getHospitalBed({v[2]}, function(theBed)
									if theBed then
										vRPserver.canReviveAtHospital({}, function(canRevive)
											if canRevive then
												FreezeEntityPosition(tempPed, true)
												TriggerEvent("vRP:progressBar", {
													duration = 5000,
													text = "📋 Analizam fisa medicala..",
												}, function()
													FreezeEntityPosition(tempPed, false)
													TriggerServerEvent("hospital$joinBed")
													isJoiningBed = false

													tvRP.notify("Ai platit $200", "success", false, "fas fa-hospital")
													joinBed(theBed, v[2])
												end)
											end
										end)
									else
										tvRP.notify("Nu sunt locuri libere pentru internare!", "error", false, "fas fa-bed")
									end
								end)
							end
						end

						Wait(1)
					end
				end

				Wait(1)
			end
		end

		Wait(500)
	end
end)
