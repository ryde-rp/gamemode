local washLocations = {
	{vec3(36.882846832276,-1393.4376220704,29.339164733886), false},
	{vec3(28.457609176636,-1393.5631103516,29.321746826172), false},
	{vec3(13.872825622558,-1393.4783935546,29.298511505126), false},
	{vec3(13.882162094116,-1390.2091064454,29.294738769532), false},
	{vec3(28.507745742798,-1390.1063232422,29.319967269898), false},
	{vec3(36.95112991333,-1390.2427978516,29.375839233398), false},
	{vec3(168.98609924316,-1716.4201660156,29.29168510437), false},
	{vec3(169.78845214844,-1717.105834961,29.291704177856), false},
	{vec3(174.04891967774,-1733.5428466796,29.382173538208), false},
	{vec3(174.93360900878,-1740.0190429688,29.290914535522), false},
	{vec3(-702.06317138672,-938.80633544922,19.013889312744), false},
	{vec3(-702.06512451172,-927.74206542968,19.01389503479), false},
}

local blipLocations = {
	vec3(22.654397964478,-1392.240600586,29.329578399658),
	vec3(167.30477905274,-1731.8719482422,29.291662216186),
	vec3(-700.29595947266,-933.86853027344,19.01389503479),
}

local function loadParticles()
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
    	Citizen.Wait(1)
    end
end

CreateThread(function()
	loadParticles()
	for _, blipLocation in pairs(blipLocations) do
		local theBlip = AddBlipForCoord(blipLocation)
		SetBlipSprite(theBlip, 100)
		SetBlipScale(theBlip, 0.650)
		SetBlipAsShortRange(theBlip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Spalatorie Auto")
		EndTextCommandSetBlipName(theBlip)
	end

	local hasWasher = false
	local lastWasherCoords = nil
	local usedWasher = false

	while true do
		local ticks = 500

		for _, theLocation in pairs(washLocations) do
			local theDist = #(theLocation[1] - pedPos)
			if theDist <= 15 then
				ticks = 1

				if theDist <= 1 then
					tvRP.subtitleText("Apasa tasta ~b~E ~w~pentru a ~b~"..("%s"):format(not hasWasher and "~w~lua" or "pune inapoi").."~w~ furtunul")
					if IsControlJustReleased(0, 51) then
						hasWasher = not hasWasher
						if not hasWasher and not theLocation[2] then
							tvRP.notify("Trebuie sa lasi furtunul in locatia in care l-ai luat!", "error")
							hasWasher = true
						else
							if hasWasher then
								vRPserver.accesCarwash({}, function(code)
									if code then
										theLocation[2] = true
										CreateThread(function()
											GiveWeaponToPed(tempPed, "WEAPON_PRESSURE1", 250, false, true)
											lastWasherCoords = pedPos
											while hasWasher do
												DisablePlayerFiring(PlayerId(), true)

												if IsDisabledControlPressed(0, 24) then
													if not usedWasher then
														usedWasher = true

														CreateThread(function()
															local gameTimer = GetGameTimer() + 15000
															local pfx = nil
															local pValue = 0
															while gameTimer > GetGameTimer() do
																if IsDisabledControlPressed(0, 24) then
																	SetParticleFxShootoutBoat(true)
																	local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0 + GetGameplayCamRelativePitch() * 0.4, 0.0)
																	local x = offset.x
																	local y = offset.y

																	local _,z = GetGroundZFor_3dCoord(x, y, offset.z)

																	Citizen.Wait(GetGameplayCamRelativePitch())
																    
																    UseParticleFxAssetNextCall("core")
																    pfx = StartParticleFxLoopedAtCoord("water_cannon_spray", x, y, z + 0.55, 0.0, 0.0, GetEntityHeading(tempPed), 0.75, false, false, false, false)
						 											
						 											Wait(100)
						 											StopParticleFxLooped(pfx, 0)
						 											pValue = pValue + 1
						 										end
															    Wait(1)
														    end
														    
														    if HasPedGotWeapon(tempPed, "WEAPON_PRESSURE1", false) then
															    if pValue > 10 then
					    											local vehicle = tvRP.getNearestVehicle(10)
					    											if vehicle then
					    												SetVehicleDirtLevel(vehicle, 0.0)
															    		tvRP.notify("Ti-ai spalat masina, acum pune furtunul la loc!")
															    		pValue = 0
															    	end
															    else
															    	tvRP.notify("Ai folosit prea putina apa!", "warning")
															    end
															end

														    StopParticleFxLooped(pfx, 0)
													    end)
													end
												end

												local removeCds = #(lastWasherCoords - pedPos)
												if removeCds > 15 then
													RemoveWeaponFromPed(tempPed, "WEAPON_PRESSURE1")
													tvRP.notify("Te-ai indepartat prea mult iar furtunul s-a rupt!", "warning")
													hasWasher = false
													usedWasher = false
													pValue = 0
												end
												Wait(1)
											end

											DisablePlayerFiring(PlayerId(), false)
											RemoveWeaponFromPed(tempPed, "WEAPON_PRESSURE1")
										end)
									else
										hasWasher = false
									end
								end)
							else
								RemoveWeaponFromPed(tempPed, "WEAPON_PRESSURE1")
								tvRP.notify("Ai pus furtunul la loc!")
								usedWasher = false
								theLocation[2] = false
							end	
						end
					end
				end

				if theLocation[2] then
					DrawMarker(0, theLocation[1], 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 31, 222, 100, 105, true, true, true, true)
				else
					DrawMarker(0, theLocation[1], 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.75, 0, 215, 215, 105, true, true, true, true)
				end
			end
		end

		Wait(ticks)
	end
end)