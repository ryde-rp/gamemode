local hiringLocation = vec3(1608.908203125,3574.1662597656,38.775207519531)
local theJob = "Traficant de Tigari"
local inTask = false
local randomMails = { "Advanced Smoker", "Mihnea Tiganu", "Smecheru Vlad", "Jurca Ionut", "Smoking Passion" }

RegisterNetEvent("fp-traficantDeTigari:addGroup")
AddEventHandler("fp-traficantDeTigari:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Traficant de Tigari")
end)

RegisterNetEvent("fp-traficantDeTigari:removeGroup")
AddEventHandler("fp-traficantDeTigari:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Traficant de Tigari")
end)

local function traficantDeTigari()
	Wait(5000)

	while theJob == "Traficant de Tigari" do

		if not inTask then
			vRPserver.setCigarettesTask({}, function(deliveryData)
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
					})

					Wait(5000)
					if theJob == "Traficant de Tigari" then
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
									text = "🚬 Livrezi tigari...",
								})

		  						local theHash = GetHashKey("p_fag_packet_01_s")
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
								vRPserver.finishCigarettesTask({})
							end,

							-- Misc
							waypointColor = 40,
							markerColor = {255, 255, 255},
							areaText = "Livrează țigări",
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

	if theJob == "Traficant de Tigari" then
		traficantDeTigari()
	end
end)

async(function()
	-- angajare: Traficant de Tigari
	tvRP.createPed("vRP_jobs:traficantDeTigari", {
		position = hiringLocation,
		rotation = 120,
		model = "a_m_m_og_boss_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_SMOKING",
		},
		minDist = 1.5,
		
		name = "Jaga",
		description = "Afacerist: Traficant de Tigari",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa ma angajez.", post = "fp-traficantDeTigari:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-traficantDeTigari:removeGroup"},
		},
	})

	--[[
	
	tutun, filtru, foita
	
	]]

	-- -- cumparare Tutun
	tvRP.createPed("traficantDeTigari:tutun", {
		position = vec3(-1172.0378417969,-1575.6475830078,4.3898010253906),
		rotation = 130,
		model = "a_m_m_tourist_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_SMOKING",
		},
		minDist = 3,
		
		name = "Bebi",
		description = "Afacerist: Traficant de Tigari",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa cumpar Tutun.", post = "fp-traficantDeTigari:cumparaItem", args={"fp_tutun_procesat"}},
		},
	})

	-- -- cumparare Filtru
	tvRP.createPed("traficantDeTigari:filtru", {
		position = vec3(-1186.0559082031,-1556.4616699219,4.3614797592163),
		rotation = 150,
		model = "a_m_o_beach_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_SMOKING",
		},
		minDist = 2.5,
		
		name = "Gentimir",
		description = "Afacerist: Traficant de Tigari",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa cumpar Filtre.", post = "fp-traficantDeTigari:cumparaItem", args={"fp_filtre"}},
		},
	})

	-- -- cumparare Foite
	tvRP.createPed("traficantDeTigari:foita", {
		position = vec3(-1150.4788818359,-1520.6529541016,4.3651056289673),
		rotation = 130,
		model = "a_m_y_beach_01",
		freeze = true,
		scenario = {
			anim = {dict = "amb@world_human_drug_dealer_hard@male@base", name = "base"}
		},
		minDist = 3,
		
		name = "Berghiu",
		description = "Afacerist: Traficant de Tigari",
		text = "Te salut amice, ia zi-mi, cu ce ocazie p-aici?",
		fields = {
			{item = "Vreau sa cumpar Foite.", post = "fp-traficantDeTigari:cumparaItem", args={"fp_foite"}},
		},
	})
end)