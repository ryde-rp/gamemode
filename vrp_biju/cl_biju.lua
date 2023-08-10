local vRP = exports.vrp:getClientObject()
local bijuArea = vec3(-622.12969970703,-230.79737854004,38.057075500488)
local infoPos = vec3(-630.47747802734,-240.98530578613,38.162967681885)
local robPositions = {
	{-627.2122, -234.895, 37.64523, "des_jewel_cab3_start", "des_jewel_cab3_end"},
	{-626.1615, -234.1316, 37.64523, "des_jewel_cab4_start", "des_jewel_cab4_end"},
	{-627.595, -234.3683, 37.64523},
	{-626.5442, -233.6049, 37.54623},
	{-625.275, -238.2881, 37.64523, "des_jewel_cab3_start", "des_jewel_cab2_end"},
	{-626.3253, -239.0511, 37.64523, "des_jewel_cab2_start", "des_jewel_cab2_end"},
	{-625.3298, -227.3696, 37.64523},
	{-619.9666, -226.1982, 37.64523},
	{-619.2035, -227.2485, 37.64523, "des_jewel_cab2_start", "des_jewel_cab2_end"},
	{-617.086, -230.163, 37.64523},
	{-618.7983, -234.1508, 37.64523},
	{-619.8483, -234.9137, 37.64523},
	{-617.8491, -229.1127, 37.64523},
	{-624.2798, -226.6067, 37.64523},
	{-620.5214, -232.8823, 37.64523},
	{-623.6131, -228.6263, 37.64523},
	{-623.9567, -230.7202, 37.64523},
	{-622.6159, -232.5636, 37.64523},
}

local allowedWeaps = {
	[GetHashKey'WEAPON_ASSAULTRIFLE_MK2'] = true,
}

local canRob = true
local pedCoords = GetEntityCoords(PlayerPedId())
Citizen.CreateThread(function()
	while true do
		pedCoords = GetEntityCoords(PlayerPedId())
		Citizen.Wait(200)
	end
end)

local function DrawText3D(x,y,z, text, scl, font) 
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  local px,py,pz = table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)
  local scale = (1/dist*scl)*(1/GetGameplayCamFov()*100);
 
  if onScreen then
    SetTextScale(0.0*scale, 1.1*scale)
    SetTextFont((font or 0))
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
  end
end

RegisterNetEvent("vrp-biju:setState")
AddEventHandler("vrp-biju:setState", function(state)
	canRob = state
end)

RegisterNetEvent("vrp-biju:sendCoords")
AddEventHandler("vrp-biju:sendCoords", function(cpData)
	local bps = {}
	local inRob = true

	for _, pos in pairs(robPositions) do
		local id = AddBlipForCoord(pos[1], pos[2], pos[3])
		SetBlipSprite(id, 618)
		SetBlipColour(id, 73)
		SetBlipScale(id, 0.5)
		SetBlipAsShortRange(id, true)
		
		table.insert(bps, id)
	end

	Citizen.CreateThread(function()
		local requestInteract = {}
		local tblThatWereRobbed = {}

		while inRob do

			if #(bijuArea - pedCoords) > 15 then
				TriggerServerEvent("vrp-biju:cancelRob")
				inRob = false
				break
			end

			for tblId, pos in pairs(robPositions) do
				local dist = #(vec3(pos[1], pos[2], pos[3]) - pedCoords)
				if dist <= 8.5 then

					local wasRobbed = tblThatWereRobbed[tblId]

					if dist <= 1 and not wasRobbed then
						if not requestInteract[tblId] then
							requestInteract[tblId] = true
							TriggerEvent("vRP:requestKey", {key = "E", text = "Fura din vitrina"})
						end

						if IsControlJustReleased(0, 51) then

							local uWeap = GetSelectedPedWeapon(PlayerPedId())
							if not uWeap or not allowedWeaps[uWeap] then
								vRP.notify("Nu poti sparge vitrina fara o arma!", "error", false, "fas fa-gem")
							else
								TriggerEvent("vRP:requestKey", false)
								RequestAnimDict("missheist_jewel")
								while not HasAnimDictLoaded("missheist_jewel") do
									Citizen.Wait(1)
								end

								TaskPlayAnim(PlayerPedId(), 'missheist_jewel', 'smash_case', 1.0, -1.0,-1,1,0,0, 0,0)
								Citizen.Wait(1500)
								CreateModelSwap(pos[1], pos[2], pos[3], 0.1, GetHashKey(pos[4] or "des_jewel_cab_start"), GetHashKey(pos[5] or "des_jewel_cab_end"), false)
								PlaySoundFromCoord(-1, "Glass_Smash", pos[1], pos[2], pos[3], 0, 0, 0)
								Citizen.Wait(3000)
								tblThatWereRobbed[tblId] = true
								TriggerServerEvent("vrp-biju:robCoords", cpData)
								Citizen.Wait(500)
								ClearPedTasks(PlayerPedId())
								requestInteract[tblId] = nil
							end


						end
					elseif requestInteract[tblId] then
						TriggerEvent("vRP:requestKey", false)
						requestInteract[tblId] = nil
					end

					if not wasRobbed then
						DrawMarker(3, pos[1], pos[2], pos[3] + 0.5, 0, 0, 0, 0, 0, 0, 0.15, 1.25, 0.15, 239, 202, 87, 105, true, true, false)
					else
						DrawMarker(3, pos[1], pos[2], pos[3] + 0.5, 0, 0, 0, 0, 0, 0, 0.15, 1.25, 0.15, 153, 34, 18, 105, true, true, false)
					end
				end
			end

			Citizen.Wait(1)
		end

		for _, id in pairs(bps) do
			RemoveBlip(id)
		end
	end)
end)

AddEventHandler("CEventGunShot", function(none, eventEnt, possibleData)
	if (eventEnt == PlayerPedId()) and canRob and (#(bijuArea - pedCoords) <= 10) then
		local uWeap = GetSelectedPedWeapon(PlayerPedId())
		if not allowedWeaps[uWeap] then
			return vRP.notify("Nu poti incepe un jaf la bijuterie cu aceasta arma!", "error", false, "fas fa-gem")
		end

		TriggerServerEvent("vrp-biju:startRobbing")
	end
end)

Citizen.CreateThread(function()
    local normalBlip = vRP.createBlip("vRPvangelico:blip", bijuArea.x, bijuArea.y, bijuArea.z, 617, 5, "Bijuterie: Vangelico", 0.550)
    local fakeBlip = vRP.createBlip("vRPvangelico:cBlip", bijuArea.x, bijuArea.y, bijuArea.z, 161, 5, "", 0.450)

    SetBlipPriority(normalBlip, 2)
    SetBlipPriority(fakeBlip, 1)

    vRP.createPed("vRProb:sellIllegals:biju", {
        position = vec3(1977.4372558594,-2608.87890625,3.5522453784943),
        rotation = 225,
        model = "g_m_y_mexgoon_01",
        freeze = true,
        scenario = {
            name = "WORLD_HUMAN_CLIPBOARD_FACILITY",
        },
        minDist = 2.5,
        
        name = "Gica Samsaru",
        description = "Afacerist: Hot de bijuterii",
        text = "Cu ce ti-as putea fi de folos?",
        fields = {
            {item = "Vreau sa vand bijuteriile furate.", post = "vrp-biju:sellJewels", args={"serverside"}}
        },
    })

    vRP.createPed("vRProb:sellIllegals:bank", {
        position = vec3(1983.7590332031,-2614.3090820313,3.5522437095642),
        rotation = 50,
        model = "cs_jimmydisanto",
        freeze = true,
        scenario = {
            name = "WORLD_HUMAN_CLIPBOARD_FACILITY",
        },
        minDist = 2.5,
        
        name = "Bazatu Ion",
        description = "Afacerist: Hot de lingouri",
        text = "Cu ce ti-as putea fi de folos?",
        fields = {
            {item = "Vreau sa vand lingourile furate.", post = "FP:BankRobbery:SellLingouri", args={"serverside"}}
        },
    })


	while true do

		while not canRob do
			Citizen.Wait(1024)
		end

		while (#(infoPos - pedCoords) <= 5.5) and (GetInteriorFromEntity(PlayerPedId()) == 0) do
			DrawText3D(infoPos.x, infoPos.y, infoPos.z + 0.450, "~y~VANGELICO ~w~ROBBERY", 0.650, 2)
			DrawText3D(infoPos.x, infoPos.y, infoPos.z + 0.325, "Pentru a jefuii magazinul de bijuterii~n~trebuie sa detii o arma de calibru mare, cum", 0.650)
			DrawText3D(infoPos.x, infoPos.y, infoPos.z + 0.145, "ar fi un ~y~Assault Rifle~w~, pentru a incepe jaful", 0.650)
			DrawText3D(infoPos.x, infoPos.y, infoPos.z + 0.045, "trebuie sa intri in interiorul magazinului", 0.650)
			DrawText3D(infoPos.x, infoPos.y, infoPos.z - 0.045, "si sa tragi cateva gloante in orice directie.", 0.650)

			DrawMarker(30, infoPos, 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 255, 212, 59, 85, false, true, false, true)
			Citizen.Wait(1)
		end

		Citizen.Wait(1000)
	end
end)