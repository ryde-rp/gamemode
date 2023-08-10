local theJob = "Livrator Glovo"
local inTask = false

function tvRP.isInGlovoTask()
	return inTask
end

exports("HasGlovoJobActive", function()
	return inTask
end)

local function livratorGlovo()
	Wait(5000)

	while theJob == "Livrator Glovo" do
		if not inTask then
			vRPserver.pickGlovoRestaurant({}, function(restaurantData)
				if restaurantData then
					inTask = true

					local collectedBag = false
					local restaurantPos = restaurantData.pos
					local deliveryPos = restaurantData.delivery

				    local theZone, _ = GetStreetNameAtCoord(deliveryPos.x, deliveryPos.y, deliveryPos.z)
				    local theStreet = GetStreetNameFromHashKey(theZone)

					TriggerServerEvent("fp-phone:addMail", {
					  sender = "Glovo Deliveries",
					  subject = "Comanda noua",
					  message = [[
					      Avem o comanda noua pt. dvs.
					      <br>
					      <span style="padding: .450vh .5vw; font-size: .7em; background-color: #ffffff10; border-radius: .10vw;"><i class="fas fa-map-marker-alt" style="font-size: .9em;"></i> &nbsp; ]]..theStreet..[[</span>&nbsp;<span style="padding: .450vh .5vw; font-size: .7em; background-color: #ffffff10; border-radius: .10vw;"><i class="fas fa-map" style="font-size: .9em;"></i> &nbsp; ]]..("%.2f"):format(#(deliveryPos - pedPos) / 1000)..[[KM</span>
					      <br>
					      <br>
					      <div style="display: inline-flex !important; align-items: center; justify-content: center; padding: 1.5vh 1.5vh; padding-bottom: 0vh; width: 100%; background: #ffffff20; border-radius: .25vw;">
					          <p style="font-size: .750em;">]]..restaurantData.item..[[</p>
					          <p style="font-size: .7em; margin-left: auto; padding: .5vh 1vw; background-color: #53996950; border-radius: .30vw;">$]]..restaurantData.reward..[[</p>
					      </div>
					      <br>
					      <br>
					      <span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">no-reply@glovo.deliveries</span>
					      <span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">Glovo Deliveries B.M.B</span>
					  ]],
					}, false, true)

					tvRP.createBlip("vRP_glovoRestaurant", restaurantPos.x, restaurantPos.y, restaurantPos.z, 628, 11, "Restaurant Livrare", 0.650)
					tvRP.setBlipRoute("vRP_glovoRestaurant", true, true)

					while not collectedBag do
						if theJob ~= "Livrator Glovo" then
							break
						end

						while #(restaurantPos - pedPos) <= 12 do
							if theJob ~= "Livrator Glovo" then
								break
							end

							local newDst = #(restaurantPos - pedPos)
							DrawMarker(20, restaurantPos, 0, 0, 0, 0, 0, 0, 0.50, 0.50, -0.50, 159, 201, 166, 160, true, true)

							if newDst <= 3 then
								DrawText3D(restaurantPos.x, restaurantPos.y, restaurantPos.z+0.2, "~g~G ~w~- Ridica comanda", 0.5)

								if newDst <= 0.5 then
									if IsControlJustReleased(0, 47) then
										collectedBag = true
										vRPserver.pickupGlovoItem({})
										tvRP.playAnim(true,{{"mp_common","givetake1_a",1}},false)
										tvRP.deleteBlip("vRP_glovoRestaurant")

										break
									end
								end
							end

							Wait(1)
						end

						Wait(500)
					end

					Wait(5000)
					if theJob == "Livrator Glovo" then
						if tvRP.isOnMission() then
							tvRP.stopMission()
							Wait(1000)
						end

						tvRP.startMission({
							steps = {
								deliveryPos,
							},

							onStepEnter = function(nextStep)
								nextStep();
							end,

							onFinish = function()
								tvRP.stopMission();
								TriggerEvent("vRP:progressBar", {
									duration = 8000,
									text = "🤙🏻 Livrezi comanda...",
								})

		  						local theHash = GetHashKey("prop_paper_bag_small")
		  						RequestModel(theHash)
		  						while not HasModelLoaded(theHash) do
		  							Wait(1)
		  						end

		  						loadAnimDict("timetable@jimmy@doorknock@")
		  						loadAnimDict("anim@mugging@victim@toss_ped@")

		  						FreezeEntityPosition(tempPed, true)
		  						TaskPlayAnim(tempPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 2.0, 2.0, 5000, 51, 0, false, false, false)
		  						Wait(5000)

		  						TaskPlayAnim(tempPed, "anim@mugging@victim@toss_ped@", "throw_object_right_pocket_male", 2.0, 2.0, 2000, 51, 0, false, false, false)
		  						Wait(300)
		  						
		  						local theObj = CreateObject(theHash, pedPos, true, true, true)
		  						AttachEntityToEntity(theObj, tempPed, GetPedBoneIndex(tempPed, 64016), 0.07, -0.01, -0.04, 0.0, 0.0, 190.0, true, true, false, false, 1, true)
		  						
		  						Wait(1700)
		  						DeleteObject(theObj)
		  						ClearPedTasks(tempPed)
		  						FreezeEntityPosition(tempPed, false)

								inTask = false
								vRPserver.finishGlovoTask({})
							end,

							-- Misc
							waypointColor = 66,
							areaText = "Livreaza comanda",
						})
					end
				end
			end)
		end

		Wait(15000)
	end
end

RegisterNetEvent("FairPlay:JobChange")
AddEventHandler("FairPlay:JobChange", function(job, skill)
	theJob = job
	if theJob == "Livrator Glovo" then
		livratorGlovo()
	elseif inTask then
		inTask = false
		tvRP.deleteBlip("vRP_glovoRestaurant")
	end
end)