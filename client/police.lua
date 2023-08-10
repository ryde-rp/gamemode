local reportsPosition = vec3(442.79034423828,-981.93908691406,30.689510345459)

CreateThread(function()
  RegisterNetEvent("fp-police:checkSelfReports")
  AddEventHandler("fp-police:checkSelfReports", function()
    vRPserver.verifyPoliceReports({})
  end)

	tvRP.createPed("vRPcaziere:checkSelf", {
    position = reportsPosition,
    rotation = 100,
    model = "s_m_y_cop_01",
    freeze = true,
    scenario = {
      name = "WORLD_HUMAN_CLIPBOARD"
    },
    minDist = 2.5,
    
    name = "Mitica Cosbuc",
    description = "Departamentul de Politie L.S.",
    text = "Bine ai venit la noi, cu ce te putem ajuta?",
    fields = {
      {item = "Vreau sa-mi verific cazierul.", post = "fp-police:checkSelfReports"},
    },
  })
end)

local handcuffed = false
local cuffsVariation = nil

function tvRP.togHandcuffs()
  local ped = tempPed
  if IsPedInAnyVehicle(ped) then
    if(handcuffed)then
      handcuffed = false
      SetEnableHandcuffs(ped, handcuffed)
      tvRP.stopAnim(true)
      Citizen.Wait(500)
      SetPedStealthMovement(ped,false,"")

      if lastCuffVariation then
        SetPedComponentVariation(ped, 7, cuffsVariation, 0, 0)
      end

      return
    end
  else
    handcuffed = not handcuffed
    SetEnableHandcuffs(ped, handcuffed)
    if handcuffed then
      SetCurrentPedWeapon(ped, -1569615261, true)
      tvRP.playAnim(true,{{"mp_arresting","idle",1}},true)
      cuffsVariation = GetPedDrawableVariation(ped, 7)

      if IsPedMale(tempPed) then
        SetPedComponentVariation(ped, 7, 41, 0, 0)
      else
        SetPedComponentVariation(ped, 7, 25, 0, 0)
      end
    else
      tvRP.stopAnim(true)
      Citizen.Wait(500)
      SetPedStealthMovement(ped,false,"")
      ForcePedMotionState(ped, 247561816)

      if lastCuffVariation then
        SetPedComponentVariation(ped, 7, cuffsVariation, 0, 0)
      end

    end
  end
end

function tvRP.setHandcuff(flag)
  if handcuffed ~= flag then
    tvRP.togHandcuffs()
  end
end

function tvRP.isHandcuffed()
  return handcuffed
end

function tvRP.setHandcuffed()
  TriggerServerEvent("vRP:$x", "Illegal use of vRPlibs['Tunnel'] detected")
end

function tvRP.toggleHandcuff()
  TriggerServerEvent("vRP:$x", "Illegal use of vRPlibs['Tunnel'] detected")
end

-- (experimental, based on experimental getNearestVehicle)
function tvRP.putInNearestVehicleAsPassenger(radius)
  local veh = tvRP.getNearestVehicle(radius)

  if IsEntityAVehicle(veh) then
    for i=1,math.max(GetVehicleMaxNumberOfPassengers(veh),3) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
  
  return false
end

function tvRP.putInNetVehicleAsPassenger(net_veh)
  local veh = NetworkGetEntityFromNetworkId(net_veh)
  if IsEntityAVehicle(veh) then
    for i=1,GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
end

function tvRP.putInVehiclePositionAsPassenger(x,y,z)
  local veh = tvRP.getVehicleAtPosition(x,y,z)
  if IsEntityAVehicle(veh) then
    for i=1,GetVehicleMaxNumberOfPassengers(veh) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(tempPed,veh,i)
        return true
      end
    end
  end
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(15000)
    if handcuffed then
      tvRP.playAnim(true, {{"mp_arresting","idle",1}}, true)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(500)
    while handcuffed do
      Wait(0)
      DisableControlAction(0,21,true) -- disable sprint
      DisableControlAction(0,24,true) -- disable attack
      DisableControlAction(0,25,true) -- disable aim
      DisableControlAction(0,47,true) -- disable weapon
      DisableControlAction(0,58,true) -- disable weapon
      DisableControlAction(0,263,true) -- disable melee
      DisableControlAction(0,264,true) -- disable melee
      DisableControlAction(0,257,true) -- disable melee
      DisableControlAction(0,140,true) -- disable melee
      DisableControlAction(0,141,true) -- disable melee
      DisableControlAction(0,142,true) -- disable melee
      DisableControlAction(0,143,true) -- disable melee
      DisableControlAction(0,75,true) -- disable exit vehicle
      DisableControlAction(27,75,true) -- disable exit vehicle
    end
  end
end)

RegisterNetEvent('policeAnim$beingArested')
AddEventHandler('policeAnim$beingArested', function(target)
	local playerPed = tempPed
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Citizen.Wait(10)
	end
	AttachEntityToEntity(tempPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	Citizen.Wait(950)
	DetachEntity(tempPed, true, false)
end) 

RegisterNetEvent('policeAnim$onUncuffed')
AddEventHandler('policeAnim$onUncuffed', function(target)
  local playerPed = tempPed
  local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

  AttachEntityToEntity(tempPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
  Citizen.Wait(950)
  DetachEntity(tempPed, true, false)
end)

RegisterNetEvent('policeAnim$aresting')
AddEventHandler('policeAnim$aresting', function()
	local playerPed = tempPed
	RequestAnimDict('mp_arrest_paired')
	while not HasAnimDictLoaded('mp_arrest_paired') do
		Citizen.Wait(10)
	end
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	Citizen.Wait(3000)
end)

local jailData = false
local expireTime = 0
local cellTime = 0
local jailEnding = vec3(1839.4506835938,2594.4699707032,45.952339172364)
local jailCoords = vec3(1691.9475097656,2605.2463378906,45.55862045288)
local jailChief = vec3(1788.0197753906,2597.9318847656,45.797790527344)

local jailBlips = {
  vec3(1825.8540039062,2617.400390625,45.56639099121),
  vec3(1848.6506347656,2697.0510253906,45.805541992188),
  vec3(1771.7404785156,2760.775390625,45.73696899414),
  vec3(1651.0805664062,2753.3117675782,45.4846534729),
  vec3(1570.2780761718,2676.28125,45.395198822022),
  vec3(1533.2470703125,2581.369140625,45.339359283448),
  vec3(1539.6359863282,2464.458984375,45.453994750976),
  vec3(1658.2756347656,2392.2895507812,45.565490722656),
  vec3(1760.118774414,2406.3669433594,45.496158599854),
  vec3(1823.5650634766,2475.1701660156,45.53938293457),
}

local jailCells = {
  vec3(1785.5888671875,2601.6987304688,50.549633026124),
  vec3(1789.6555175782,2597.9443359375,50.549633026124),
  vec3(1789.7236328125,2593.8791503906,50.54963684082),
  vec3(1789.7170410156,2589.9760742188,50.54963684082),
  vec3(1789.0506591796,2586.044921875,50.54963684082),
  vec3(1789.0451660156,2582.0048828125,50.54963684082),
  vec3(1789.4290771484,2578.0200195312,50.54963684082),
  vec3(1789.7307128906,2574.2082519532,50.54963684082),
  vec3(1786.0744628906,2568.5119628906,50.54963684082),
  vec3(1781.990600586,2568.4624023438,50.549648284912),
  vec3(1778.0568847656,2568.375,50.549648284912),
  vec3(1774.0794677734,2568.39453125,50.549625396728),
  vec3(1769.8303222656,2573.7106933594,50.549629211426),
  vec3(1769.841796875,2577.6010742188,50.549629211426),
  vec3(1769.588256836,2581.7353515625,50.549633026124),
  vec3(1769.7012939454,2585.7416992188,50.549633026124),
  vec3(1769.4636230468,2589.6938476562,50.549633026124),
  vec3(1769.5161132812,2593.6594238282,50.549633026124),
  vec3(1769.8334960938,2597.5893554688,50.549633026124),
}

local prisonWork = {
  -- Curata curtea cu matura
  {
    vec3(1774.6873779296,2553.2985839844,45.56496810913),
    vec3(1753.7630615234,2566.0041503906,45.56496810913),
    vec3(1726.822631836,2555.8073730468,45.5648727417),
    vec3(1722.1701660156,2545.4162597656,45.5648727417),
    vec3(1715.3266601562,2520.20703125,45.564868927002),
    vec3(1724.4187011718,2506.7429199218,45.706806182862),
    vec3(1708.157836914,2494.4560546875,45.564888000488),
    vec3(1692.8244628906,2470.9194335938,45.59443283081),
    vec3(1676.4580078125,2514.7719726562,45.564891815186),
    vec3(1678.9619140625,2554.4450683594,45.564891815186)
  },

  -- Strange frunzele uscate
  {
    vec3(1760.6881103516,2545.4946289062,45.564945220948),
    vec3(1754.1346435546,2544.5942382812,45.564945220948),
    vec3(1745.0817871094,2547.4790039062,45.564945220948),
    vec3(1743.1027832032,2514.1057128906,45.564933776856),
    vec3(1749.3034667968,2517.3898925782,45.564933776856),
    vec3(1695.8303222656,2522.2170410156,45.5648727417),
    vec3(1701.069946289,2547.7326660156,45.5648727417),
    vec3(1681.658203125,2547.4499511718,45.5648727417),
    vec3(1669.0245361328,2525.376953125,45.5648727417),
    vec3(1665.1987304688,2527.9304199218,45.5648727417),
    vec3(1680.669921875,2478.6677246094,45.564922332764),
    vec3(1712.9772949218,2513.2543945312,45.56489944458),
    vec3(1733.6470947266,2505.5852050782,45.56489944458),
    vec3(1762.0225830078,2521.5642089844,45.564929962158),
  }
}

local function workAsCleaner()
  CreateThread(function()
    local jobPositions = prisonWork[2]
    local janitorPos = table.rnd(jobPositions)

    tvRP.createBlip("vRP_prison:workBlip", janitorPos.x, janitorPos.y, janitorPos.z, 480, 11, "Munca in cadrul Penitenciarului", 0.650)

    while jailData do
      if not jailData.onWork then
        break
      end

      DrawMarker(20, janitorPos, 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 159, 201, 166, 150, true, true, false, true)

      tvRP.subtitleText("~HC_60~Munca in cadrul Penitenciarului L.S:", 0, false, false, 160, 0.9325)
      tvRP.subtitleText("~HC_4~Mergi la ~w~locatia transmisa~HC_4~ pentru a ~w~strange frunzele~HC_4~.", 0, false, false, false, 0.95)

      if jailData.time <= 2 then
        tvRP.notify("Timpul din care se poate scadea din sedinta s-a terminat!", "info", false, "fas fa-handcuffs")
        break
      end

      while #(janitorPos - pedPos) <= 0.5 do
        ExecuteCommand("e jpickup")
        TriggerEvent("vRP:progressBar", {
          duration = 10500,
          text = "🍃 Strangi frunzele de pe jos..",
        }, function()            
            janitorPos = table.rnd(jobPositions)
            tvRP.setBlipCoords("vRP_prison:workBlip", janitorPos)
            ExecuteCommand("e c")

            cellTime = cellTime - 1
            jailData.time = cellTime

            local cTimer = GetGameTimer()
            expireTime = cTimer + ((cellTime or 0) * 60 * 1000)

            if cellTime > 0 then
              tvRP.notify("Timp ramas: "..cellTime.." (de) minute", "info", false, "fas fa-handcuffs")
            end

            vRPserver.onJailWork({})
        end)
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)

        ExecuteCommand("e jpickup")
        Wait(1500)
        break
      end

      Wait(1)
    end

    tvRP.deleteBlip("vRP_prison:workBlip")
  end)
end

local function workAsJenitor()
  CreateThread(function()
  	local jobPositions = prisonWork[1]
    local janitorPos = table.rnd(jobPositions)

	  tvRP.createBlip("vRP_prison:workBlip", janitorPos.x, janitorPos.y, janitorPos.z, 480, 36, "Munca in cadrul Penitenciarului", 0.650)

    while jailData do
      if not jailData.onWork then
        break
      end

      DrawMarker(20, janitorPos, 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 252, 239, 166, 150, true, true, false, true)

      tvRP.subtitleText("~HC_58~Munca in cadrul Penitenciarului L.S:", 0, false, false, 160, 0.9325)
      tvRP.subtitleText("~HC_4~Mergi la ~w~locatia transmisa~HC_4~ pentru a ~w~matura curtea~HC_4~.", 0, false, false, false, 0.95)

      if jailData.time <= 2 then
        tvRP.notify("Timpul din care se poate scadea din sedinta s-a terminat!", "info", false, "fas fa-handcuffs")
        break
      end

      while #(janitorPos - pedPos) <= 0.5 do
        ExecuteCommand("e janitor")
        TriggerEvent("vRP:progressBar", {
          duration = 10500,
          text = "🧹 Maturi curtea penitenciarului..",
        }, function()            
            janitorPos = table.rnd(jobPositions)
            tvRP.setBlipCoords("vRP_prison:workBlip", janitorPos)
            ExecuteCommand("e c")

            cellTime = cellTime - 1
            jailData.time = cellTime

            local cTimer = GetGameTimer()
            expireTime = cTimer + ((cellTime or 0) * 60 * 1000)

            if cellTime > 0 then
              tvRP.notify("Timp ramas: "..cellTime.." (de) minute", "info", false, "fas fa-handcuffs")
            end

            vRPserver.onJailWork({})
        end)

        Wait(10500)
      	break
      end

      Wait(1)
    end

    tvRP.deleteBlip("vRP_prison:workBlip")
  end)
end

local function startCommunityWork(type)
  if not jailData then
    return tvRP.notify("In acest moment nu esti inchis in penitenciarul orasului Los Santos!", "error", false, "fas fa-handcuffs")
  end

  if jailData.onWork then
    tvRP.notify("Te-ai oprit din a muncii in folosul penitenciarului Los Santos!", "warning", false, "fas fa-handcuffs")
    jailData.onWork = false
    return
  end

  jailData.onWork = true
  tvRP.notify("Ai inceput sa muncesti in cadrul penitenciarului Los Santos!", "success", false, "fas fa-handcuffs")

  if type == "maturatorCurte" then
    workAsJenitor()
  elseif type == "strangeFrunze" then
    workAsCleaner()
  end
end

CreateThread(function()
  for _, blipPosition in pairs(jailBlips) do
    tvRP.createBlip("vRPpolice:cellBlip:".._, blipPosition.x, blipPosition.y, blipPosition.z, 188, 0, "Puscarie", 0.600)
  end

  RegisterNetEvent("fp-jailWork:strangeFrunze")
  AddEventHandler("fp-jailWork:strangeFrunze", function()
    if not jailData then
      return tvRP.notify("In acest moment nu esti inchis in penitenciar!", "error", false, "fas fa-handcuffs")
    end

    if jailData.time <= 2 then
      tvRP.notify("Nu esti eligibil la munca in cadrul penitenciarului!", "info", false, "fas fa-handcuffs")
    else
      startCommunityWork("strangeFrunze")
    end
  end)

  RegisterNetEvent("fp-jailWork:maturaCurtea")
  AddEventHandler("fp-jailWork:maturaCurtea", function()
    if not jailData then
      return tvRP.notify("In acest moment nu esti inchis in penitenciar!", "error", false, "fas fa-handcuffs")
    end
    
    if jailData.time <= 2 then
      tvRP.notify("Nu esti eligibil la munca in cadrul penitenciarului!", "info", false, "fas fa-handcuffs")
    else
      startCommunityWork("maturatorCurte")
    end
  end)

	tvRP.createPed("vRPjail:workChief", {
    position = jailChief,
    rotation = 180,
    model = "s_m_m_ciasec_01",
    freeze = true,
    minDist = 3.5,
    
    name = "Gabriel Anghel",
    description = "Penitenciarul Sandy Shores",
    text = "Bine ai venit, rau ai nimerit! Cum te pot ajuta?",
    fields = {
      {item = "Vreau sa strang frunze.", post = "fp-jailWork:strangeFrunze"},
      {item = "Vreau sa dau cu matura.", post = "fp-jailWork:maturaCurtea"}
    },
  })
end)

function tvRP.getJailTime()
  if jailData then
    return jailData.time or 0
  end

  return 0
end

function tvRP.isInJail()
  return tvRP.getJailTime() > 0
end

function tvRP.breakJail()
  expireTime = 0
  tvRP.teleport(jailEnding.x, jailEnding.y, jailEnding.z)
  tvRP.notify("Ai fost eliberat!", "success", false, "fas fa-handcuffs")
  tvRP.deleteBlip("vRPjail:director")
end

RegisterNetEvent("jail$onCellEnter", function(x)
  local theCell = jailCells[math.random(1, #jailCells)]
  tvRP.teleport(theCell.x, theCell.y, theCell.z)
  tvRP.setHandcuff(false)

  tvRP.createBlip("vRPjail:director", jailChief.x, jailChief.y, jailChief.z, 408, 63, "Director Penitenciar", 0.5)
  cellTime = x

  CreateThread(function()
    local cTimer = GetGameTimer()
    expireTime = cTimer + ((cellTime or 0) * 60 * 1000)

    jailData = {
      time = cellTime,
    }

    if expireTime > cTimer then
	    tvRP.notify("Timp ramas: "..cellTime.." (de) minute", "info", false, "fas fa-handcuffs")

	    while expireTime > GetGameTimer() do
		    Wait(60000)
        if expireTime == 0 then return end

		    cellTime = cellTime - 1
		    jailData.time = cellTime

        local cTimer = GetGameTimer()
        expireTime = cTimer + ((cellTime or 0) * 60 * 1000)

		    if (#(jailCoords - pedPos) > 750) then
  				tvRP.teleport(jailCoords.x, jailCoords.y, jailCoords.z)
  				tvRP.notify("Nu ai voie sa pleci din puscarie!", "warning")
  			end
		    
		    if cellTime % 2 == 0 then
			    TriggerServerEvent("jail$onMinutePassed")

			    if cellTime > 0 then
			      tvRP.notify("Timp ramas: "..cellTime.." (de) minute", "info", false, "fas fa-handcuffs")
			    end
		    end
	    end

	    tvRP.teleport(jailEnding.x, jailEnding.y, jailEnding.z)
	    tvRP.notify("Ai fost eliberat!", "success", false, "fas fa-handcuffs")
      tvRP.deleteBlip("vRPjail:director")
    end
  end)
end)