local isBlackedOut = false
local injuredTime = 0

RegisterNetEvent("carCrashEffect", function()
	isBlackedOut = true

	Citizen.CreateThread(function()
		while isBlackedOut do
			Wait(1)

			DisableControlAction(0,71,true) -- veh forward
			DisableControlAction(0,72,true) -- veh backwards
			DisableControlAction(0,63,true) -- veh turn left
			DisableControlAction(0,64,true) -- veh turn right
			DisableControlAction(0,75,true) -- disable exit vehicle
		end
	end)

	injuredTime = 25
	DoScreenFadeOut(100)
	Citizen.Wait(1000)
    DoScreenFadeIn(250)

    StartScreenEffect('PeyoteEndOut', 0, true)
    StartScreenEffect('Dont_tazeme_bro', 0, true)
    StartScreenEffect('MP_race_crash', 0, true)

    while injuredTime > 0 do

        if injuredTime > 14 then 
            ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.4)
			ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        end 

        Citizen.Wait(750)
        injuredTime = injuredTime - 1

		if injuredTime <= 1 then
            StopScreenEffect('PeyoteEndOut')
            StopScreenEffect('Dont_tazeme_bro')
            StopScreenEffect('MP_race_crash')
        end
    end

	isBlackedOut = false
end)