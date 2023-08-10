local rentLocation = vec3(-534.23858642578,-222.94473266602,37.649806976318)
local spawnPos = vec3(-508.95568847656,-261.23751831055,35.479434967041)
local rentData = false

local function rentBike()
	vRPserver.rentOneBike({}, function(canRent)
		if canRent then
			if not rentData then
				rentData = {
					time = GetGameTimer() + 1800000, -- 30 de minute
					veh = tvRP.spawnCar("faggio", spawnPos),
				}

				CreateThread(function()
					while rentData do
						if rentData.time < GetGameTimer() then
							break
						end

						Wait(100)
					end

					if DoesEntityExist(rentData.veh) then
						DeleteEntity(rentData.veh)
						tvRP.notify("Timpul a expirat iar scuterul a fost sters!", "warning", false, "fas fa-motorcycle")
					end

					rentData = false
				end)

				tvRP.notify("Ai inchiriat un scuter pentru 30 de minute!", "info", false, "fas fa-motorcycle")
			else
				rentData.time = rentData.time + 1800000
				tvRP.notify("Ai inchiriat scuterul pentru inca 30 de minute de acum!", "info", false, "fas fa-motorcycle")
			end
		end
	end)
end

RegisterNetEvent("fp-spawn:rentBike", function()
	rentBike()
end)

RegisterCommand("rent", function()
	if not rentData then
		return
	end
	
	tvRP.notify("Ti-au mai ramas "..math.floor(rentData.time / 60).." minute si "..(rentData.time % 60).." secunde in care poti folosi scuterul inchiriat!", "info", false, "far fa-clock")
end)

CreateThread(function()
	tvRP.createPed("vRP:rentPed", {
		position = rentLocation,
		rotation = 360,
		model = "player_two",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Trevor",
		description = "Închirieri Ryde",
		text = "Wăi! Ia zi, ce vrei?",
		fields = {
			{item = "Vreau sa inchiriez un scuter.", post = "fp-spawn:rentBike"},
		},
	})

	local spawnPos = vec3(-540.79876708984,-210.88777160645,37.649787902832)
	while true do
		while #(spawnPos - pedPos) <= 35.5 do
			DrawMarker(30, spawnPos, 0, 0, 0, 0, 0, 0, 0.65, 0.65, 0.65, 116, 193, 255, 95, false, false, false, true)

			if #(spawnPos - pedPos) <= 5.5 then
				DrawText3D(spawnPos.x, spawnPos.y, (spawnPos.z + 0.150), "Bun venit pe ~b~Ryde ~w~Romania", 0.650)
				DrawText3D(spawnPos.x, spawnPos.y, (spawnPos.z + 0.150) - 0.085, "Iti uram distractie placuta alaturi de noi!", 0.450)
				DrawText3D(spawnPos.x, spawnPos.y, (spawnPos.z + 0.150) - 0.185, "Pentru informatii utile acceseaza:~n~~HC_4~ryde-rp.com", 0.450)
			end

			Wait(1)
		end

		Wait(1024)
	end
end)