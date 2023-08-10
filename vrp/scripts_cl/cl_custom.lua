
-- FairPlay Romania
-- made by @Proxy & @Robert


Citizen.CreateThread(function()

  SetPedCanLosePropsOnDamage(tempPed, false, 0)
  SetCanAttackFriendly(tempPed, true, false)
  SetPoliceIgnorePlayer(tempPlayer, true)
	SetDispatchCopsForPlayer(tempPlayer, false)

  NetworkSetFriendlyFireOption(true)

  Citizen.Wait(15000)

  local injuredWalking = false

  local injuredRunning = false
  RegisterNetEvent("vRP:bypassRunning", function()
    
    injuredRunning = true

    Citizen.SetTimeout(45000, function()
      injuredRunning = false
    end)
  end)

  if not HasAnimSetLoaded("move_m@injured") then
      RequestAnimSet("move_m@injured")
  end

  while true do
      if not DoesEntityExist(tempPed) then
          tempPed = PlayerPedId()
          SetPedCanLosePropsOnDamage(tempPed, false, 0)
          SetCanAttackFriendly(tempPed, true, false)
      end
      local playerHealth = GetEntityHealth(tempPed)
      local playerArmor = GetPedArmour(tempPed)

      if not playerArmor or playerArmor < 50 then
          SetPedConfigFlag(tempPed, 438, true)
      else
          SetPedConfigFlag(tempPed, 438, false)
      end
      SetPedConfigFlag(tempPed, 184, true)

      if playerHealth <= 130 then
          SetPedMovementClipset(tempPed, "move_m@injured", 0.2)
          if not injuredWalking then
              injuredWalking = true
              Citizen.CreateThread(function()
                while injuredWalking do
                  DisableControlAction(0, 21, true)
                  DisableControlAction(0, 22, true)
                  
                  if injuredRunning then
                    Citizen.Wait(1000)
                  end
                  Citizen.Wait(1)
                end
              end)
          end
      elseif injuredWalking then
          injuredWalking = false
          ResetPedMovementClipset(tempPed)
      end

      Citizen.Wait(2000)
  end
end)



RegisterNetEvent("vRP:onJobChange")
AddEventHandler("vRP:onJobChange", function(newJob)
  tvRP.stopMission()
end)


onlinePlayers = 0
RegisterNetEvent('getOnlinePly', function(ammt)
    onlinePlayers = ammt
end)


local myUserData = {
    faction = "Civil"
}
RegisterNetEvent("discord:setUserData", function(uid, faction)
    myUserData.uid = uid
    myUserData.name = GetPlayerName(PlayerId())
    if faction then
        myUserData.faction = faction
    end
end)


exports("getMyUserId", function()
    return myUserData.uid or false
end)

Citizen.CreateThread(function()
  SetDiscordAppId(1012321394102636585)
  SetDiscordRichPresenceAction(0, "🌐 Intra pe Discord", "https://discord.gg/ryde")
  SetDiscordRichPresenceAction(1, "✅ Conecteaza-te pe server", "fivem://connect/[IPNEBUN]:30120")
  SetDiscordRichPresenceAsset('logox')
  SetDiscordRichPresenceAssetText('https://discord.gg/ryde')
  SetRichPresence("Se conecteaza pe server...")

  while not myUserData.uid do
      Citizen.Wait(5000)
  end

  while true do
      SetDiscordAppId(1012321394102636585)
      SetDiscordRichPresenceAction(0, "🌐 Intra pe Discord", "https://discord.gg/ryde")
      SetDiscordRichPresenceAction(1, "✅ Conecteaza-te pe server", "fivem://connect/[IPNEBUN]:30120")

      SetDiscordRichPresenceAsset('logox')
      SetDiscordRichPresenceAssetText('https://discord.gg/ryde')

      SetRichPresence(myUserData.name.." ["..myUserData.uid.."] - ".. onlinePlayers .. "/512")
      Citizen.Wait(30000)
  end
end)


RegisterNetEvent("vRP:showAccountStats", function(user_id, name, sex, userObj, userWarns)
  TriggerEvent("vRP:interfaceFocus", true)
  SendNUIMessage({
    act = "interface",
    target = "accountStats",
    user_id = user_id,
    username = name,
    sex = sex,
    userObj = userObj,
    userWarns = userWarns,
  })
end)

-- Ridica mainile --
local handsup = false
RegisterCommand("+ridicamaini", function()
    if (GVEHICLE == 0) then
        handsup = true
        Citizen.CreateThread(function()
            local dict = "missminuteman_1ig_2"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(100)
            end
        end)
        if handsup then
            TaskPlayAnim(tempPed, "missminuteman_1ig_2", "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
            handsup = true
        end
    end
end)

RegisterCommand("-ridicamaini", function()
    if handsup then
        RemoveAnimSet("missminuteman_1ig_2")
        ClearPedSecondaryTask(tempPed)
        handsup = false
    end
end)

RegisterKeyMapping("+ridicamaini", "Ridica mainile", "keyboard", "x")

-- Finger Pointing --
local isPlayerPointing = false

function tvRP.isPointingFinger()
  return isPlayerPointing
end

RegisterCommand('+arataCuDegetul', function()
    local ped = tempPed
    isPlayerPointing = true

    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")

    while isPlayerPointing do
        local camPitch = GetGameplayCamRelativePitch()
        if camPitch < -70.0 then
            camPitch = -70.0
        elseif camPitch > 42.0 then
            camPitch = 42.0
        end
        camPitch = (camPitch + 70.0) / 112.0
        
        local camHeading = GetGameplayCamRelativeHeading()
        local cosCamHeading = Cos(camHeading)
        local sinCamHeading = Sin(camHeading)
        if camHeading < -180.0 then
            camHeading = -180.0
        elseif camHeading > 180.0 then
            camHeading = 180.0
        end
        camHeading = (camHeading + 180.0) / 360.0
        
        local blocked = 0
        local nn = 0
        
        local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
        local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
        nn, blocked, coords, coords = GetRaycastResult(ray)
        
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
        Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
        Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
        SetCurrentPedWeapon(tempPed, GetHashKey("WEAPON_UNARMED"), true)

        if not IsPedOnFoot(tempPed) then
            CancelEvent();
            isPlayerPointing = false
        end
        
        Wait(1)
    end
end)

RegisterCommand('-arataCuDegetul', function()
    isPlayerPointing = false
    local ped = tempPed
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(tempPed)
end)

RegisterKeyMapping("+arataCuDegetul", "Arata cu degetul", "keyboard", "B")

-- Overhead talking marker --
Citizen.CreateThread(function()
  while true do
    local ticks = 1000
    local theUsers = GetActivePlayers()

    for _, i in pairs(theUsers)  do
      local userPed = GetPlayerPed(i)

      if NetworkIsPlayerTalking(i) then
        ticks = 1

        PlayFacialAnim(userPed, 'mic_chatter', 'mp_facial')
      else
        PlayFacialAnim(userPed, 'mood_normal_1', 'facials@gen_male@variations@normal')
      end
    end

    Wait(ticks)
  end
end)

-- CNN Announcements --
Citizen.CreateThread(function()
  RegisterNetEvent("fp-weazelNews:addAnounce")
  AddEventHandler("fp-weazelNews:addAnounce", function()
    TriggerServerEvent('FP:announces')
  end)
  
  local weazelPos = vec3(-591.52813720703,-932.98278808594,23.87756729126)
  local normalBlip = tvRP.createBlip("vRP_weazelNews:blip", weazelPos.x, weazelPos.y, weazelPos.z, 767, 6, "Weazel News", 0.550)
  local fakeBlip = tvRP.createBlip("vRP_weazelNews:cBlip", weazelPos.x, weazelPos.y, weazelPos.z, 161, 6, "", 0.450)

  SetBlipPriority(normalBlip, 2)
  SetBlipPriority(fakeBlip, 1)

  tvRP.createPed("vRP:weazelAgent", {
    position = weazelPos,
    rotation = 10,
    model = "csb_abigail",
    freeze = true,
    scenario = {
      default = true,
    },
    minDist = 3.5,
    
    name = "Anunturi comerciale",
    description = "Angajat: Weazel News",
    text = "Bine ai venit la noi, cu ce te putem ajuta?",
    fields = {
      {item = "Vreau sa pun un anunt.", post = "fp-weazelNews:addAnounce"}
    },
  })
end)

function tvRP.createAnnounce(userPhone, text, user_id)
  SendNUIMessage{
    act = "createAnunt",
    text = text,
    number = userPhone,
    user_id = user_id,
  }
end

-- Maini in san --
local mainiInSan = false
RegisterCommand("tinemainileinsan", function()
  mainiInSan = not mainiInSan

  if mainiInSan then
    RequestAnimDict("amb@world_human_hang_out_street@female_arms_crossed@base")
    while not HasAnimDictLoaded("amb@world_human_hang_out_street@female_arms_crossed@base") do
      Wait(1)
    end

    TaskPlayAnim(tempPed, "amb@world_human_hang_out_street@female_arms_crossed@base", "base", 8.0, 8.0, -1, 50, 0, false, false, false)
    return
  end

  ClearPedTasks(tempPed)
end)

RegisterKeyMapping("tinemainileinsan", "Tine mainile in san", "keyboard", "U")

-- Sistem Fluierat --

RegisterCommand("fluiera", function()
  if IsControlPressed(0, 21) then
    return
  end

  if GVEHICLE == 0 and not GSWIMMING and not IsPedShooting(tempPed) and not IsPedClimbing(tempPed) and not IsPedCuffed(tempPed) and not IsPedDiving(tempPed) and not IsPedFalling(tempPed) and not IsPedJumping(tempPed) and not IsPedJumpingOutOfVehicle(tempPed) and IsPedOnFoot(tempPed) and not IsPedRunning(tempPed) and not IsPedUsingAnyScenario(tempPed) and not IsPedInParachuteFreeFall(tempPed) then
    SetCurrentPedWeapon(tempPed, GetHashKey("WEAPON_UNARMED"), true)

    Citizen.CreateThread(function()
      loadAnimDict("rcmnigel1c")

      TaskPlayAnim(tempPed, "rcmnigel1c", "hailing_whistle_waive_a", 2.7, 2.7, -1, 49, 0, 0, 0, 0)
        
      Wait(1347)
      ClearPedSecondaryTask(tempPed)
    end)  
  end
end)

RegisterKeyMapping("fluiera", "Fluiera", "keyboard", "H")

local isBusted = false
RegisterCommand("k", function()
  local player = tempPed

  if not IsEntityDead(player) then 
    loadAnimDict("random@arrests")
    loadAnimDict("random@arrests@busted")

    if IsEntityPlayingAnim(player, "random@arrests@busted", "idle_a", 3) then 
      TaskPlayAnim(player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(3000)

      TaskPlayAnim(player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0)
      isBusted = false
    else
      TaskPlayAnim(player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(4000)
      
      TaskPlayAnim(player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(500)
      
      TaskPlayAnim(player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
      Wait(1000)
      
      TaskPlayAnim(player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
      isBusted = true

      Citizen.CreateThread(function()
        while isBusted do
          DisableControlAction(1, 140, true)
          DisableControlAction(1, 141, true)
          DisableControlAction(1, 142, true)
          DisableControlAction(0,21,true)

          Wait(1)
        end
      end)
    end     
  end
end)


-- Citizen.CreateThread(function()
-- 	local bhops = 0
-- 	local reduction = 0

-- 	while true do
-- 		if IsPedJumping(tempPed) then
-- 			bhops = bhops + 1
      
--       if bhops >= 1 then
-- 				Citizen.Wait(300)
-- 				SetPedToRagdoll(tempPed, 500, 500, 0, 0, 0, 0)
-- 			end
-- 		end

-- 		Citizen.Wait(1100)
-- 		reduction = reduction + 1
-- 		if reduction == 2 then
-- 			bhops = math.max(bhops - 1, 0)
-- 			reduction = 0
-- 		end
-- 	end
-- end)


-- Reciclare Gunoaie --
Citizen.CreateThread(function()
  tvRP.createPed("vRP_jobs:garbageRecycle", {
    position = vec3(-448.58630371094,-1697.9907226563,18.934724807739),
    rotation = 160,
    model = "s_m_y_garbage",
    freeze = true,
    scenario = {
      anim = {
        dict = "oddjobs@taxi@",
        name = "idle_a",
      },
    },
    minDist = 3.5,
    
    name = "Sefu' la Gunoierii Ryde SRL",
    description = "Reciclare gunoaie",
    text = "Bine ai venit la noi, cu ce te putem ajuta?!",
    fields = {
      {item = "Vreau sa reciclez gunoaie.", post = "fp-garbage:recicleazaGunoaie", args = {type = "serverside"}},
    },
  })
end)

-- NPC AMMO CRAFT -- Metal Fragmentat
local buyMetalPos = vec3(4818.5766601563,-4309.765625,5.6743102073669)

Citizen.CreateThread(function()
  tvRP.createPed("vRP:buyMetal", {
    position = buyMetalPos,
    rotation = 10,
    model = "cs_floyd",
    freeze = true,
    scenario = {
      default = true,
    },
    minDist = 3.5,
    
    name = "+40736715169",
    description = "Vanzaor: Metal Fragmentat",
    text = "Salut serif, cu ce te pot ajuta?",
    fields = {
      {item = "Vreau sa cumpar Metal Fragmentat", post = "fp-buyMetalFragmentat", args = {type = "serverside"}}
    },
  })
end)

-- /me

local nbrDisplaying = 1

local function DrawMeText3D(x, y, z, text, backgroundEnabled)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoord())
	local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

	local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

	if onScreen then

		-- Formalize the text
		SetTextColour(255, 255, 255, 200)
		if backgroundEnabled then
			SetTextColour(219, 29, 29, 200)
		end
		SetTextScale(0.0 * scale, 0.55 * scale)
		SetTextFont(font)
		SetTextProportional(1)
		SetTextCentre(true)

		-- Calculate width and height
		BeginTextCommandWidth("STRING")
		AddTextComponentString(text)
		local height = GetTextScaleHeight(0.55 * scale, font)
		local width = EndTextCommandGetWidth(font)

		-- Diplay the text
		SetTextEntry("STRING")
		AddTextComponentString(text)
		EndTextCommandDisplayText(_x, _y)

		if backgroundEnabled then
			DrawRect(_x, (_y + scale / 58) + 0.005, width, height + 0.01, 0, 0, 0, 100)
		end
	end
end

local function Display(mePlayer, text, offset, backgroundEnabled)
	local mePed = GetPlayerPed(mePlayer)

	if NetworkIsPlayerActive(mePlayer) and mePed then

		local untilTime = GetGameTimer() + 4000
		local coords = GetEntityCoords(PlayerPedId(), false)

		Citizen.CreateThread(function()
			nbrDisplaying = nbrDisplaying + 1

			while GetGameTimer() < untilTime do
				Citizen.Wait(1)
				local coordsMe = GetEntityCoords(mePed, false)
				local dist = #(coordsMe - coords)
				if dist < 150 then
					DrawMeText3D(coordsMe.x, coordsMe.y, coordsMe.z + offset - 0.1, text, backgroundEnabled)
				else
					break
				end
			end

			nbrDisplaying = nbrDisplaying - 1
		end)
	end
end

RegisterCommand('me', function(source, args)
	local text = ""
	for i = 1, #args do
		text = text .. ' ' ..args[i]
	end
	text = text .. ''

	local activePly = GetActivePlayers()
	local activeSrc = {}
	for _, ply in ipairs(activePly) do
		table.insert(activeSrc, GetPlayerServerId(ply))
	end

	TriggerServerEvent('3dme:shareDisplay', text, false, activeSrc)
end)

RegisterNetEvent("vrp-3dme:display")
AddEventHandler("vrp-3dme:display", function(msg)

	local activePly = GetActivePlayers()
	local activeSrc = {}
	for _, ply in ipairs(activePly) do
		table.insert(activeSrc, GetPlayerServerId(ply))
	end

	TriggerServerEvent('3dme:shareDisplay', msg, true, activeSrc)
end)

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(mePlayer, text, bg)
	local offset = 1 + (nbrDisplaying * 0.14)
	Display(GetPlayerFromServerId(mePlayer), text, offset, bg)
end)