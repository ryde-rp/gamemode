
local inAJail = false
local startedJailSession = false

local treeBlip = false
local jailCp = {0,0,0}
local vectoredMarker = vec3(0,0,0)
local jailCps = 0

AddEventHandler("vRP:onComaEntered", function()
	if inAJail then
		tvRP.setHealth(200)
	end
end)

RegisterNetEvent("fp-jail:sendCoords")
AddEventHandler("fp-jail:sendCoords", function(cpData, remainCp)
	if type(cpData) == "table" then
		jailCp = cpData
		jailCps = remainCp
		vectoredMarker = vec3(jailCp[1], jailCp[2], jailCp[3])

		SetBlipCoords(treeBlip, vectoredMarker)
		SetBlipRoute(treeBlip, true)
	end
end)

function tvRP.isAdminJailed()
	return inAJail
end

RegisterNetEvent("fp-adminJail:readRules")
AddEventHandler("fp-adminJail:readRules", function()
	print("ryde-rp.com")
end)

RegisterNetEvent("fp-jail:setState", function(state)
	inAJail = state
	local requests = {}

	if inAJail and not startedJailSession then
		startedJailSession = true

		Citizen.CreateThread(function()
			local rulesPosition = vec3(-791.11053466797,5424.7602539063,35.331836700439)
		    local rulesBlipRadius = tvRP.createBlip("vRP_aJail:rulesRadius", rulesPosition.x, rulesPosition.y, rulesPosition.z, 161, 18, "", 0.450)
		    local rulesBlip = tvRP.createBlip("vRP_aJail:readRules", rulesPosition.x, rulesPosition.y, rulesPosition.z, 381, 0, "Admin Jail", 0.550)

		    SetBlipPriority(rulesBlipRadius, 1)
		    SetBlipPriority(rulesBlip, 2)

			tvRP.createPed("vRP_aJail:rulesPed", {
				position = rulesPosition,
				rotation = 40,
				model = "s_m_o_busker_01",
				freeze = true,
				scenario = {
				  default = true,
				},
				minDist = 3.5,
				
				name = "Valentin Unguru",
				description = "discord.gg/ryde",
				text = "Bine ai venit, rau ai nimerit!",
				fields = {
					{item = "Vreau sa citesc regulamentul.", post = "fp-adminJail:readRules"},
				},
			})

			treeBlip = AddBlipForCoord(vectoredMarker)
			SetBlipSprite(treeBlip, 12)
			SetBlipScale(treeBlip, 0.850)
			SetBlipColour(treeBlip, 5)
			
			SetBlipRoute(treeBlip, true)
			SetBlipRouteColour(treeBlip, 5)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Locatie copac")
			EndTextCommandSetBlipName(treeBlip)

			Citizen.Wait(500)
			local jailVehicle = tvRP.spawnCar("rubble", false, 275)
			SetEntityInvincible(jailVehicle, true)
			tvRP.setHealth(200)				

			while inAJail do
				tvRP.subtitleText("~b~Info: ~w~Mai ai de taiat ~b~"..jailCps.."~w~ copaci pana la eliberare!", false, false, false, false, 0.9265)
				tvRP.subtitleText("~HC_4~Poti sa citesti regulamentul pe ~w~discord.gg/ryde", false, false, false, false, 0.9450)

				if not DoesEntityExist(jailVehicle) then
					jailVehicle = tvRP.spawnCar("rubble", false, 275)
					SetEntityInvincible(jailVehicle, true)
				end

				if #(vectoredMarker - pedPos) <= 5 then
					DrawMarker(6, vectoredMarker, 0, 0, 0, 0, 0, 0, 1.00, 1.00, 1.00, 255, 255, 255, 90, true, true)
					DrawMarker(20, vectoredMarker, 0, 0, 0, 0, 0, 0, 0.60, 0.60, 0.60, 0, 250, 250, 125, true, true)
					
					while #(vectoredMarker - pedPos) <= 1.0 do
						if not requests['destroyTree'] then
							requests['destroyTree'] = true
							TriggerEvent("vRP:requestKey", {key = "E", text = "TAIE COPACUL"})
						end

						if IsControlJustReleased(0, 51) then
							TriggerEvent("vRP:requestKey", false)

							local textTime = GetGameTimer() + 10000
							TriggerEvent("vRP:progressBar", {
								duration = 10000,
								text = "🪓 Tai copacul..",
								anim = {
									dict = "melee@hatchet@streamed_core",
									name = "plyr_rear_takedown_b",
								}
							})

							local toporObj = CreateObject(GetHashKey("prop_w_me_hatchet"), 0, 0, 0, true, true, true) 
				             AttachEntityToEntity(toporObj, tempPed, GetPedBoneIndex(tempPed, 57005), 0.15, -0.02, -0.02, 350.0, 100.00, 280.0, true, true, false, true, 1, true)
							
							while GetGameTimer() < textTime do -- fix IsControlJustReleased() x2 bug
								Wait(1)
							end

							DetachEntity(toporObj, 1, true)
				             DeleteEntity(toporObj)

				             if DoesEntityExist(toporObj) then
				             	DeleteObject(toporObj)
							end

							local hasTree = true
							while hasTree do
								local carCoords = GetEntityCoords(jailVehicle)
								local vehDist = #(carCoords - pedPos)
								SetBlipCoords(treeBlip, carCoords)

								if vehDist <= 2.5 then
									if not requests['detachTree'] then
										requests['detachTree'] = true
										TriggerEvent("vRP:requestKey", {key = "E", text = "Lasa copacul in masina"})
									end

									if IsControlJustReleased(0, 38) then
										TriggerEvent("vRP:requestKey", false)
										
										local gameTimer = GetGameTimer() + 5000
										TriggerEvent("vRP:progressBar", {
											duration = 5000,
											text = "🌳 Urci lemnul in masina..",
											anim = {
												dict = "anim@heists@box_carry@",
												name = "idle",
											}
										})

										while gameTimer > GetGameTimer() do
											Wait(1)
										end

										hasTree = false
									end
								else
									if requests['detachTree'] then
										TriggerEvent("vRP:requestKey", false)
										requests['detachTree'] = nil
									end

									DrawMarker(20, carCoords.x, carCoords.y, carCoords.z + 3.85, 0, 0, 0, 0, 0, 0, 2.60, 2.45,-2.60,0, 250, 250, 155, true, true)
									tvRP.subtitleText("~y~Mergi la masina pentru a depozita lemnul..")
								end

								Wait(1)
							end
						
							TriggerServerEvent("fp-jail:checkCheckpoint", jailCp)
						end

						Citizen.Wait(1)
					end

					if requests['destroyTree'] then
						TriggerEvent("vRP:requestKey", false)
						requests['destroyTree'] = nil
					end
				end

				Citizen.Wait(1)
			end

			RemoveBlip(treeBlip)
			DeleteEntity(jailVehicle)
			tvRP.deleteBlip("vRP_aJail:rulesRadius")
			tvRP.deleteBlip("vRP_ajail:readRules")
			tvRP.deletePed("vRP_aJail:rulesPed")
			startedJailSession = false
		end)
	end
end)