
Citizen.CreateThread(function()

    local dmvCoords = vec3(438.9528503418,-979.30645751953,30.689483642578)

    local blip = AddBlipForCoord(dmvCoords)
	SetBlipSprite(blip, 773)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 62)
    SetBlipPriority(blip, 1)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Scoala de Soferi")
    EndTextCommandSetBlipName(blip)

    local keyActive = false
    while true do
        local dist = #(dmvCoords - pedPos)
        while dist <= 20.0 do
            DrawMarker(27, dmvCoords - vec3(0.0, 0.0, 0.9), 0, 0, 0, 0, 0, 0, 0.501, 0.501, 0.5001, 255, 255, 255, 200, 0, 0, 0, 1)
            

            if dist <= 1 then
				
                if not keyActive then
                    TriggerEvent("vRP:requestKey", {key = "E", text = "Sustine testul teoretic"})
                    keyActive = true
                end

                if IsControlJustPressed(0, 38) then

                    if keyActive then
                        TriggerEvent("vRP:requestKey", false)
                        keyActive = false
                    end

                    TriggerServerEvent("vrp-dmv:tryPassingTest")
                    Citizen.Wait(5000)
                    break
                end
            elseif keyActive then
                TriggerEvent("vRP:requestKey", false)
                keyActive = false
            end


            Citizen.Wait(1)
            dist = #(dmvCoords - pedPos)
        end
        Citizen.Wait(2000)
    end

end)

RegisterNetEvent("vrp-dmv:openExaminationMenu", function()
    TriggerEvent("vRP:interfaceFocus", true)
    SendNUIMessage({
        act = "interface",
        target = "drivingSchool",
    })
end)

RegisterNUICallback("completeDmv", function(data, cb)
    TriggerServerEvent("vrp-dmv:updateExamination", data[1])
    cb("ok")
end)




local drivingRoute = {
	vector3(-960.44201660156,-201.44219970703,37.60863494873),
	vector3(-995.54046630859,-182.95402526855,37.80184173584),
    vector3(-904.34655761719,-134.98805236816,37.365070343018),
    vector3(-808.49725341797,-85.905494689941,37.290855407715),
    vector3(-731.41729736328,-38.891647338867,37.374038696289),
    vector3(-752.76904296875,209.76849365234,75.188873291016),
    vector3(-671.77459716797,245.87545776367,80.831489562988),
    vector3(-572.83709716797,256.06127929688,82.467323303223),
    vector3(-243.48036193848,258.41662597656,91.590629577637),
    vector3(-21.521364212036,256.06591796875,107.3275604248),
    vector3(10.568374633789,252.26147460938,108.98072814941),
    vector3(-39.966426849365,54.945304870605,71.840507507324),
    vector3(103.87300109863,-21.484869003296,67.43856048584),
    vector3(262.25692749023,-78.937316894531,69.534996032715),
    vector3(374.04348754883,-127.59078216553,64.614112854004),
    vector3(355.39627075195,-240.71936035156,53.502262115479),
    vector3(313.51940917969,-359.82650756836,44.707187652588),
    vector3(294.64483642578,-455.88555908203,42.758289337158),
    vector3(172.36009216309,-788.78967285156,30.944469451904),
    vector3(115.19087982178,-975.07971191406,28.900663375854),
    vector3(195.41523742676,-1041.0139160156,28.811010360718),
    vector3(382.00549316406,-1054.5360107422,28.72124671936),
    vector3(758.77191162109,-1009.0823364258,25.814699172974),
    vector3(778.80688476563,-749.68737792969,26.67280960083),
    vector3(620.91760253906,-373.74395751953,42.996234893799),
    vector3(497.138671875,-318.34231567383,44.877849578857),
    vector3(379.69485473633,-273.25112915039,53.282653808594),
    vector3(251.32897949219,-223.32579040527,53.534378051758),
    vector3(93.755363464355,-170.25761413574,54.450687408447),
    vector3(35.211879730225,-254.39491271973,47.343383789063),
    vector3(-78.43172454834,-231.51316833496,44.418659210205),
    vector3(-255.28007507324,-167.46612548828,40.007350921631),
    vector3(-399.7487487793,-210.20280456543,35.751377105713),
    vector3(-549.939453125,-283.00698852539,34.650321960449),
    vector3(-616.67443847656,-320.69281005859,34.214447021484),
    vector3(-684.2568359375,-238.30348205566,36.215084075928),
    vector3(-737.84039306641,-151.34251403809,36.551956176758),
    vector3(-760.34027099609,-124.10055541992,37.322040557861),
    vector3(-843.45739746094,-146.15873718262,37.311321258545),
    vector3(-916.69970703125,-184.60676574707,37.185989379883),
    vector3(-965.30249023438,-195.72230529785,36.884613037109),
}

local inDriveTest = false

RegisterNetEvent("vrp-dmv:startDriving", function(vehId)

    TriggerEvent("vRP:requestKey", false)

    while not DoesEntityExist(NetworkGetEntityFromNetworkId(vehId)) do
		Citizen.Wait(100)
	end
    local vehicle = NetworkGetEntityFromNetworkId(vehId)
    
    inDriveTest = true
    
	Citizen.CreateThread(function()
		while inDriveTest do
			Citizen.Wait(500)

			if not DoesEntityExist(vehicle) then
				inDriveTest = false
				break
			end
		end
	end)

    local blip = AddBlipForCoord(drivingRoute[1])
	SetBlipSprite(blip, 271)
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.7)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 0)
    SetBlipAsShortRange(blip, true)


    for i in pairs(drivingRoute) do

		while inDriveTest do
			Citizen.Wait(1)
			DrawMarker(1, drivingRoute[i] - vec3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 4.0, 255, 255, 255, 100)
            DrawMarker(22, drivingRoute[i] + vec3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 200, true, true, false, true)

			if #(drivingRoute[i] - pedPos) <= 10.0 then
                if drivingRoute[i + 1] then
                    SetBlipCoords(blip, drivingRoute[i + 1])
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 0)
                end

				break
			end
		end

    end

    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end

	if inDriveTest then
		TriggerEvent("vRP:requestKey", {key = '<i class="fas fa-info"></i>', text = "Parcheaza autoturismul cu spatele"})
		while inDriveTest do

			local heading = GetEntityHeading(vehicle) or 0.0

			if heading > 208.0 - 3.0 and heading < 208.0 + 3.0 then
				if GetEntitySpeed(vehicle) <= 0.5 then

					Citizen.Wait(2000)
					heading = GetEntityHeading(vehicle) or 0.0
					if GetEntitySpeed(vehicle) <= 0.5 and heading > 208.0 - 3.0 and heading < 208.0 + 3.0 then
						break
					end
				end
			end

			Citizen.Wait(1)
		end
	end

    TriggerEvent("vRP:requestKey", false)



    if inDriveTest then
		DoScreenFadeOut(3000)
		Citizen.Wait(3000)

		inDriveTest = false

		TriggerServerEvent("vrp-dmv:finishExamination")

		Citizen.Wait(1000)
		DoScreenFadeIn(2000)
	end

end)