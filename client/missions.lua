local missionData = {}
local taskDisplayed = false

function tvRP.startMission(data)
	missionData = data

	Citizen.CreateThread(function()
		Citizen.Wait(500)
		local missionStep = 1
		local missionCds = missionData.steps[missionStep]
		local blip = AddBlipForCoord(missionCds)

		if missionData.blipId then
			SetBlipSprite(blip, missionData.blipId)
		end

		SetBlipRoute(blip, true)
		SetBlipAsShortRange(blip, true)
		
		SetBlipScale(blip, 0.750)

		SetBlipColour(blip, missionData.waypointColor)
		SetBlipRouteColour(blip, missionData.waypointColor)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Misiune curenta")
		EndTextCommandSetBlipName(blip)

		missionData.blip = blip

		local r, g, b = 255, 219, 46
		if missionData.markerColor then
			r, g, b = missionData.markerColor[1], missionData.markerColor[2], missionData.markerColor[3]
		end

		tvRP.addMarker(missionCds.x, missionCds.y, missionCds.z-1.0, 0.60, 0.45,-0.60, r, g, b, 160, 20, 15.5, "vRP_missionMarker")

		local requestSent = false
		local pressed = false

		while missionData ~= nil do
			local sleepTime = 120
			local stepDist = #(missionCds - pedPos)

			if stepDist < 1 then
				sleepTime = 1

				if not requestSent then
					requestSent = true
					TriggerEvent("vRP:requestKey", {key = "E", text = missionData.areaText})
				end

				if not pressed then
					if IsControlJustReleased(0, 51) and (GVEHICLE == 0) then
						pressed = true
						missionData.onStepEnter(function(onStepPassed)
							missionStep = missionStep + 1
							missionCds = missionData.steps[missionStep] or false
							requestSent = false

							if not missionCds then
								RemoveBlip(missionData.blip)
								tvRP.removeMarker("vRP_missionMarker")

								TriggerEvent("vRP:requestKey", false)
								missionData.onFinish();
								missionData = nil
							else
								SetBlipCoords(blip, missionCds)
								SetBlipRoute(blip, true) -- reinit blip route > gta5 logic

								tvRP.removeMarker("vRP_missionMarker")
								Citizen.Wait(500)

								tvRP.addMarker(missionCds.x, missionCds.y, missionCds.z-1.0, 00.60, 0.45,-0.60, r, g, b, 160, 160, 20, 15.5, "vRP_missionMarker")
								TriggerEvent("vRP:requestKey", false)

								if type(onStepPassed) == "function" then
									onStepPassed();
								end
							end
						end);
						
						pressed = false
					end
				end
			else
				if requestSent then
					requestSent = false
					TriggerEvent("vRP:requestKey", false)
				end
			end

			Citizen.Wait(sleepTime)
		end
	end)
end

function tvRP.stopMission()
	if missionData then
		local theBlip = missionData.blip
		if theBlip then
			RemoveBlip(theBlip)
		end
	end

	missionData = nil
end

function tvRP.isOnMission()
	return missionData ~= nil
end
