local hiringLocation = vec3(1446.1256103516,-1486.3522949219,66.619255065918)
local theJob = "Traficant de Etnobotanice"
local inTask = false
local randomMails = { "iwan2drugs", "g1v3medrugs", "sendme3rugs", "want4drug", "need2bedrugged" }

RegisterNetEvent("fp-traficantEtnobotanice:addGroup")
AddEventHandler("fp-traficantEtnobotanice:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Traficant de Etnobotanice")
end)

RegisterNetEvent("fp-traficantEtnobotanice:removeGroup")
AddEventHandler("fp-traficantEtnobotanice:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Traficant de Etnobotanice")
end)

local function traficantEtnobotanice()
	Wait(5000)

	while theJob == "Traficant de Etnobotanice" do

		if not inTask then
			vRPserver.setEtnobotanicsTask({}, function(deliveryData)
				if deliveryData then
					inTask = true

					local deliveryPos = deliveryData.pos
				    local theZone, _ = GetStreetNameAtCoord(deliveryPos.x, deliveryPos.y, deliveryPos.z)
				    local theStreet = GetStreetNameFromHashKey(theZone)

					local mailMessage = "Salut, vreau si eu sa cumpar "
					for k, data in pairs(deliveryData.items) do
						if k > 1 then
							mailMessage = mailMessage.." si "..data.amount.."x "..data.name
						else
							mailMessage = mailMessage..data.amount.."x "..data.name
						end
					end

					mailMessage = mailMessage.."<br><br>"..theStreet.." nr. "..math.random(1, 69)

					TriggerServerEvent("fp-phone:addMail", {
						sender = randomMails[math.random(1, #randomMails)],
						subject = tvRP.randomNumberFromString("DDLLDLLDDDDLDD"):lower(),
						message = mailMessage
					}, false, true)

					Wait(5000)
					if theJob == "Traficant de Etnobotanice" then
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
									text = "🌿 Livrezi etnobotanice...",
								})

		  						local theHash = GetHashKey("prop_drug_package")
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
								vRPserver.finishEtnobotanicsTask({})
							end,

							-- Misc
							waypointColor = 0,
							markerColor = {255, 255, 255},
							areaText = "Livrează etnobotanice",
						})
					end
				end
			end)
		end

		Wait(15000)
	end
end


AddEventHandler("vRP:onJobChange", function(job)
	theJob = job

	if theJob == "Traficant de Etnobotanice" then
		traficantEtnobotanice()
	end
end)

async(function()
	-- angajare: Traficant de Etnobotanice
	tvRP.createPed("vRP_jobs:traficantEtnobotanice", {
		position = hiringLocation,
		rotation = 60,
		model = "ig_chef",
		freeze = true,
		scenario = {
			anim = {dict = "timetable@reunited@ig_10", name = "isthisthebest_jimmy"}
		},
		minDist = 1.5,
		
		name = "Tudorache Vlad",
		description = "Afacerist: Traficant de Etnobotanice",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa ma angajez.", post = "fp-traficantEtnobotanice:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-traficantEtnobotanice:removeGroup"},
		},
	})

	-- cumparare Ingrasamant Chimic
	tvRP.createPed("traficantEtno:ingrasamant", {
		position = vec3(1658.1469726563,4839.0629882813,42.030128479004),
		rotation = 280,
		model = "a_m_m_salton_03",
		freeze = true,
		scenario = {
			anim = {dict = "amb@world_human_drug_dealer_hard@male@base", name = "base"}
		},
		minDist = 3,
		
		name = "Tudorache Dragos",
		description = "Afacerist: Traficant de Etnobotanice",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Cumpara Ingrasamant Chimic.", post = "fp-traficantEtnobotanice:cumparaItem", args={"fp_ingrasamant_chimic"}},
		},
	})

	-- cumparare Otrava de Sobolani
	tvRP.createPed("traficantEtno:otrava", {
		position = vec3(1640.4925537109,4851.2133789063,45.505252838135),
		rotation = 190,
		model = "a_m_m_farmer_01",
		freeze = true,
		scenario = {
			anim = {dict = "amb@world_human_drug_dealer_hard@male@base", name = "base"}
		},
		minDist = 2.5,
		
		name = "Tudorache Ionut",
		description = "Afacerist: Traficant de Etnobotanice",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Cumpara Otrava de Sobolani.", post = "fp-traficantEtnobotanice:cumparaItem", args={"fp_otrava_sobolani"}},
		},
	})

	-- cumparare Acetona
	tvRP.createPed("traficantEtno:acetona", {
		position = vec3(1707.1990966797,4919.0161132813,42.063682556152),
		rotation = 65,
		model = "a_m_m_soucent_01",
		freeze = true,
		scenario = {
			anim = {dict = "amb@world_human_drug_dealer_hard@male@base", name = "base"}
		},
		minDist = 3,
		
		name = "Tudorache Mihai",
		description = "Afacerist: Traficant de Etnobotanice",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa cumpar Acetona.", post = "fp-traficantEtnobotanice:cumparaItem", args={"fp_acetona"}},
		},
	})
end)