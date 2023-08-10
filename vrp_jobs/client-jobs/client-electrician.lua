local vRP = Proxy.getInterface("vRP")

local hiringLocation = vector3(718.78778076172,152.53147888184,80.754219055176);
local spawnVehicleLocation = vector3(752.04797363281,126.0571975708,78.454414367676);

local missionData = {}
local menuActive = false;
local minigameWins = 0;

local HasLevelOneElectrician = false;
local LevelTwoElectrician = false;
local LevelThreeElectrician = false;

local LevelOneElectricianBlip;
local LevelTwoElectricianBlip;
local LevelThreeElectricianBlip;

local LevelOneMissionVehicle;
local MissionVehicle;

local ladderInHandObj;
local ladderPlacedObj;

local HasMission = false;

-- [JOB FUNCTIONS]

local function showMinigame(toggle)
	SetNuiFocus(toggle, toggle)
	SendNUIMessage({
        action = "ToggleElectricianMinigame",
        open = toggle,
    })
end

local function DrawText3D(x, y, z, text, scl, font, colors)

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * scl
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 1.1 * scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(colors[1], colors[2], colors[3], 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function StartAnim(lib, anim)
	RequestAnimDict(lib)
	while not HasAnimDictLoaded(lib) do
		Wait(1)
	end
	TaskPlayAnim(PlayerPedId(), lib, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
end

-- [JOB]

RegisterNetEvent("fp-electrician:GenerateElectricianLevelOne", function(mission)
    missionData.currentMission = Config.ElectricianLocations[1][mission][1]
    
    if DoesBlipExist(LevelOneElectricianBlip) then
        RemoveBlip(LevelOneElectricianBlip)
    end

    LevelOneElectricianBlip = AddBlipForCoord(missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3])
    SetBlipAsShortRange(LevelOneElectricianBlip, true)
    SetBlipColour(LevelOneElectricianBlip, 26)
    SetBlipScale(LevelOneElectricianBlip, 0.7)
    SetBlipRoute(LevelOneElectricianBlip, true)

    HasMission = true;
end)


local function ToggleLevelOneElectrician(toggle)
    if toggle then
        missionData = {
            currentMission = false,
            missionBlip = false,
            currentSkil = 1,
            minigameWinsNeeded = 0,
        }
        HasLevelOneElectrician = true
        HasMission = false;
    else
        HasLevelOneElectrician = false
        if DoesBlipExist(LevelOneElectricianBlip) then
            RemoveBlip(LevelOneElectricianBlip)
        end
        return;
    end

    Citizen.CreateThread(function()
        while HasLevelOneElectrician do

            Wait(1)

            if HasMission then
                local distance = #(GetEntityCoords(PlayerPedId()) - missionData.currentMission)

                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            menuActive = true
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Repara Panoul"})
                        end
                        if IsControlJustPressed(0, 38) then
                            TriggerEvent("vRP:requestKey", false)

                            minigameWins = 0;
                            showMinigame(true)
                            FreezeEntityPosition(PlayerPedId(), true)

                            math.randomseed(GetGameTimer())
                            missionData.minigameWinsNeeded = math.random(1, 4)

                            while HasLevelOneElectrician and minigameWins < missionData.minigameWinsNeeded do
                                Wait(1000)
                                if minigameWins == -1 then
                                    break
                                end
                            end

                            showMinigame(false)
                            FreezeEntityPosition(PlayerPedId(), false)
                            menuActive = false;
                            TriggerServerEvent("fp-electrician:RewardElectrician", 1, true)
                            HasMission = false;
                            if minigameWins ~= -1 then
                                TriggerServerEvent("fp-electrician:RewardElectrician", 1, false)
                                HasMission = false;
                            end
                        end
                    else
                        if menuActive then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                        end
                    end
                end
            end
        end
    end)
end

RegisterNetEvent("fp-electrician:GenerateElectricianLevelTwo", function(mission)
    missionData.currentMission = Config.ElectricianLocations[2][mission][1]
    missionData.PropHash = Config.ElectricianLocations[2][mission][2]

    if DoesBlipExist(LevelTwoElectricianBlip) then
        RemoveBlip(LevelTwoElectrician)
    end

    LevelTwoElectricianBlip = AddBlipForCoord(missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3])
    SetBlipAsShortRange(LevelTwoElectrician, true)
    SetBlipColour(LevelTwoElectricianBlip, 26)
    SetBlipScale(LevelTwoElectricianBlip, 0.7)
    SetBlipRoute(LevelTwoElectricianBlip, true)

    HasMission = true
end)

local function ToggleLevelTwoElectrician(toggle)
    if toggle then
        HasMission = false;
        LevelTwoElectrician = true
        missionData = {
            currentMission = false,
            currentSkill = 2,
            minigameWinsNeeded = 0,
            missionStage = 1,
            PropHash = 0,
            vehicle = SpawnVehicle("electrician", spawnVehicleLocation), 
            areScaraInMana = false,
            areScaraMontata = false,
        }

        LevelOneMissionVehicle = missionData.vehicle
    else
        LevelTwoElectrician = false

        if DoesBlipExist(LevelTwoElectricianBlip) then
            RemoveBlip(LevelTwoElectricianBlip)
        end

        if DoesEntityExist(LevelOneMissionVehicle) then
            DeleteEntity(LevelOneMissionVehicle)
        end

        return;
    end

    Citizen.CreateThread(function()
        while LevelTwoElectrician do
            Wait(1)

            if HasMission then
                local stalp = GetClosestObjectOfType(missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3], 1.0, missionData.PropHash, false, false, false)
                local stalpCoords = GetEntityCoords(stalp)
                local vehPos = GetEntityCoords(missionData.vehicle)
    
                local dist = #(GetEntityCoords(PlayerPedId()) - stalpCoords)

                if dist <= 5 then
                    if IsPedInAnyVehicle(PlayerPedId()) then
                        DrawText3D(stalpCoords[1], stalpCoords[2], stalpCoords[3] + 2.5, "Coboara din vehicul", 1.2, 2,{122, 195, 254})
                    else
                        if not missionData.areScaraInMana then
                            DrawText3D(vehPos[1], vehPos[2], vehPos[3] + 1, "Apasa E~n~~w~Ia scara din vehicul", 1.2, 2,{122, 195, 254})
    
                            if #(GetEntityCoords(PlayerPedId()) - vehPos) <= 2.5 then
                                if IsControlJustPressed(0, 38) then
                                    StartAnim('mini@repair', 'fixing_a_ped')
                                    exports.progressbars:Custom({
                                        Duration = 5000,
                                        Label = "Iei scara din masina...",
                                        Animation = {
                                            scenario = "",
                                            animationDictionary = ""
                                        },
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
    
                                    Wait(5000)
                                    ladderInHandObj = CreateObject(GetHashKey("prop_byard_ladder01"), playerCoords, true,true, true)
                                    StartAnim('amb@world_human_muscle_free_weights@male@barbell@idle_a', 'idle_a')
                                    AttachEntityToEntity(ladderInHandObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.05, 0.1, -0.3, 300.0, 100.0, 20.0, true, true, false, true, 1, true)
    
                                    missionData.areScaraInMana = true
                                end
                            end
                        else
                            DrawText3D(stalpCoords[1], stalpCoords[2], stalpCoords[3] + 2.5, "Apasa E~n~~w~Monteaza scara", 1.2, 2, {122, 195, 254})
                            if dist <= 2.0 then
                                if IsControlJustPressed(0, 38) then
    
                                    missionData.areScaraInMana  = false
                                    DeleteObject(ladderInHandObj)
    
                                    StartAnim('mini@repair', 'fixing_a_ped')
                                    exports.progressbars:Custom({
                                        Duration = 5000,
                                        Label = "Montezi scara...",
                                        Animation = {
                                            scenario = "",
                                            animationDictionary = ""
                                        },
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
    
                                    Wait(5000)
                                    ClearPedTasks(PlayerPedId())
                                    ladderPlacedObj = CreateObject(GetHashKey("hw1_06_ldr_"), stalpCoords - vector3(0.5, 0, 0),true, true, false)
    
                                    PlaceObjectOnGroundProperly(ladderPlacedObj)
                                    SetEntityHeading(ladderPlacedObj, 69.0)
                                    FreezeEntityPosition(ladderPlacedObj, true)
                                    SetEntityAsMissionEntity(ladderPlacedObj, true, true)
    
                                    missionData.areScaraMontata = true
    
                                    while LevelTwoElectrician do
                                        local playerCoords = GetEntityCoords(PlayerPedId())
                                        if playerCoords[3] >= stalpCoords[3] + 4.5 then
                                            break
                                        end
                                        Wait(100)
                                    end
    
                                    minigameWins = 0
                                    showMinigame(true)
                                    FreezeEntityPosition(PlayerPedId(), true)
    
                                    math.randomseed(GetGameTimer())
                                    missionData.minigameWinsNeeded = math.random(1, 4)
    
                                    while LevelTwoElectrician and minigameWins < missionData.minigameWinsNeeded do
                                        Wait(1000)
                                        if minigameWins == -1 then
                                            break
                                        end
                                    end
    
                                    showMinigame(false)
                                    FreezeEntityPosition(PlayerPedId(), false)
    
                                    if LevelTwoElectrician and minigameWins > 0 then
    
                                        while LevelTwoElectrician do
                                            Wait(1)
                                            local playerCoords = GetEntityCoords(PlayerPedId())
                                            if missionData.areScaraMontata then
    
                                                local dst = #(playerCoords - stalpCoords)
    
                                                DrawText3D(stalpCoords[1], stalpCoords[2], stalpCoords[3] + 2.5, "Apasa E~n~~w~Demonteaza scara",1.2, 2, {122, 195, 254})
    
                                                if dst <= 2.0 then
                                                    if IsControlJustPressed(0, 38) then
                                                        StartAnim('mini@repair', 'fixing_a_ped')
                                                        exports.progressbars:Custom({
                                                            Duration = 5000,
                                                            Label = "Demontezi scara...",
                                                            Animation = {
                                                                scenario = "",
                                                                animationDictionary = ""
                                                            },
                                                            DisableControls = {
                                                                Mouse = false,
                                                                Player = true,
                                                                Vehicle = true
                                                            }
                                                        })
                                                        Wait(5000)
                                                        DeleteObject(ladderPlacedObj)
                                                        ladderInHandObj = CreateObject(GetHashKey("prop_byard_ladder01"), playerCoords, true, true, true)
                                                        StartAnim('amb@world_human_muscle_free_weights@male@barbell@idle_a','idle_a')
                                                        AttachEntityToEntity(ladderInHandObj, PlayerPedId(),GetPedBoneIndex(PlayerPedId(), 28422), 0.05, 0.1, -0.3, 300.0, 100.0,20.0, true, true, false, true, 1, true)
    
                                                        missionData.areScaraMontata = false
                                                        missionData.areScaraInMana = true
                                                    end
                                                end
    
                                            else
    
                                                DrawText3D(vehPos[1], vehPos[2], vehPos[3] + 1,"Apasa E~n~~w~Pune scara in vehicul", 1.2, 2, {122, 195, 254})
    
                                                if #(GetEntityCoords(PlayerPedId()) - vehPos) <= 3.0 then
                                                  if IsControlJustPressed(0, 38) then
                                                      StartAnim('mini@repair', 'fixing_a_ped')
                                                      exports.progressbars:Custom({
                                                          Duration = 5000,
                                                          Label = "Pui scara in masina...",
                                                          Animation = {
                                                              scenario = "",
                                                              animationDictionary = ""
                                                          },
                                                          DisableControls = {
                                                              Mouse = false,
                                                              Player = true,
                                                              Vehicle = true
                                                          }
                                                      })
                                                      Wait(5000)
                                                      missionData.areScaraInMana = false
                                                      DeleteObject(ladderInHandObj)
                                                      ClearPedTasks(PlayerPedId())
    
                                                      break
                                                  end
                                                end
                                            end
                                        end
                                        TriggerServerEvent("fp-electrician:RewardElectrician", 2, false)
                                        HasMission = false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

RegisterNetEvent("fp-electrician:GenerateElectricianLevelThree", function(mission)
    missionData.currentMission = Config.ElectricianLocations[3][mission][1]
    
    if DoesBlipExist(LevelThreeElectricianBlip) then
        RemoveBlip(LevelThreeElectricianBlip)
    end

    LevelThreeElectricianBlip = AddBlipForCoord(missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3])
    SetBlipAsShortRange(LevelThreeElectricianBlip, true)
    SetBlipColour(LevelThreeElectricianBlip, 26)
    SetBlipScale(LevelThreeElectricianBlip, 0.7)
    SetBlipRoute(LevelThreeElectricianBlip, true)
end)

local function ToggleLevelThreeElectrician(toggle)
    if toggle then
        missionData = {
            currentMission = false,
            missionBlip = false,
            currentSkil = 3,
            minigameWinsNeeded = 0,
        }

        MissionVehicle = SpawnVehicle("electrician", spawnVehicleLocation)

        LevelThreeElectrician = true
    else
        LevelThreeElectrician = false
        if DoesBlipExist(LevelThreeElectricianBlip) then
            RemoveBlip(LevelThreeElectricianBlip)
        end

        if DoesEntityExist(MissionVehicle) then
            DeleteEntity(MissionVehicle)
        end

        return;
    end

    Citizen.CreateThread(function()
        while LevelThreeElectrician do
            Wait(1)

            if missionData.currentMission then
                local distance = #(GetEntityCoords(PlayerPedId()) - missionData.currentMission)

                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            menuActive = true
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Repara Eoliana"})
                        end
                        if IsControlJustPressed(0, 38) then
                            TriggerEvent("vRP:requestKey", false)

                            minigameWins = 0;
                            showMinigame(true)
                            FreezeEntityPosition(PlayerPedId(), true)

                            math.randomseed(GetGameTimer())
                            missionData.minigameWinsNeeded = math.random(1, 4)

                            while LevelThreeElectrician and minigameWins < missionData.minigameWinsNeeded do
                                Wait(1000)
                                if minigameWins == -1 then
                                    break
                                end
                            end

                            showMinigame(false)
                            FreezeEntityPosition(PlayerPedId(), false)
                            menuActive = false;
                            TriggerServerEvent("fp-electrician:RewardElectrician", 3, true)
                            if minigameWins ~= -1 then
                                TriggerServerEvent("fp-electrician:RewardElectrician", 3, false)
                            end
                        end
                    else
                        if menuActive then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                        end
                    end
                end
            end
        end
    end)
end

CreateThread(function()
	vRP.createPed({"vRP_jobs:electrician", {
		position = hiringLocation,
		rotation = 150,
		model = "s_m_y_construct_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Sebastian Codin",
		description = "Manager job: Electrician",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp-electrician:OpenMenu", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp-electrician:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp-electrician:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-electrician:removeGroup"},
		},
	}})
end)

local function HasJobActive()
    if HasLevelOneElectrician then
        return true
    elseif LevelTwoElectrician then
        return true
    elseif LevelThreeElectrician then
        return true
    end
    return false
end

RegisterNUICallback("closeMinigame", function()
	showMinigame(false)
	minigameWins = -1
end)

RegisterNUICallback("winMinigame", function()
	minigameWins = (minigameWins or 0) + 1
end)

RegisterNetEvent("fp-electrician:OpenElectrician", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenElectrician",
        jobActive = HasJobActive(),
        skill = userSkill
    })
end)

RegisterNUICallback("closeElectrician", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startElectrician", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("fp:job-electrician", data.skill)
end)

AddEventHandler("FairPlay:JobChange", function(job, skill)
    if job == "Electrician" then
        if skill == 1 then
            ToggleLevelOneElectrician(true)
            ToggleLevelTwoElectrician(false)
            ToggleLevelThreeElectrician(false)
        elseif skill == 2 then
            ToggleLevelOneElectrician(false)
            ToggleLevelTwoElectrician(true)
            ToggleLevelThreeElectrician(false)
        elseif skill == 3 then
            ToggleLevelOneElectrician(false)
            ToggleLevelTwoElectrician(false)
            ToggleLevelThreeElectrician(true)
        end
    else
        ToggleLevelOneElectrician(false)
        ToggleLevelTwoElectrician(false)
        ToggleLevelThreeElectrician(false)
    end
end)

RegisterNetEvent("fp-electrician:addGroup")
AddEventHandler("fp-electrician:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Electrician")
end)

RegisterNetEvent("fp-electrician:removeGroup")
AddEventHandler("fp-electrician:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Electrician")
end)
