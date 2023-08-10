local vRP = Proxy.getInterface("vRP")
local RVJobs = Tunnel.getInterface("vrp_jobs", "vrp_jobs")

local hiringLocation = vector3(-97.184928894043,-1013.4155883789,27.275218963623)
local vehicleSpawnLocation = vector3(-85.929542541504,-1021.9624023438,28.084838867188)

local object;
local menuActive = false;
local ConstructorLevel;
local MissionVehicle;
local missionData = {}

local HasMission = false

local LevelOneConstructor = false;
local LevelTwoConstructor = false;
local LevelThreeConstructor = false;

local LevelOneConstructorBlip;
local LevelTwoConstructorBlip;

-- [CONSTRUCTOR FUNCTIONS]

local function startAnim(ped, dictionary, anim, time)
    Citizen.CreateThread(function()
        RequestAnimDict(dictionary)
        while not HasAnimDictLoaded(dictionary) do
            Wait(0)
        end
        TaskPlayAnim(ped, dictionary, anim, 8.0, 8.0, -1, 49, 0, 0, 0, 0)

        RequestAnimDict(dictionary)
        while not HasAnimDictLoaded(dictionary) do
            Wait(0)
        end
        TaskPlayAnim(ped, dictionary, anim, 8.0, 8.0, -1, 49, 0, 0, 0, 0)

        RequestAnimDict(dictionary)
        while not HasAnimDictLoaded(dictionary) do
            Wait(0)
        end
        TaskPlayAnim(ped, dictionary, anim, 8.0, 8.0, -1, 49, 0, 0, 0, 0)
        Wait(time)
    end)
end

local function CarryBrick(ped, toggle)
    if toggle then
        object = CreateObject(GetHashKey('prop_wallbrick_01'), GetEntityCoords(PlayerPedId()), true)
        setBoxAnimation(true, true)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.1, -0.13, 180.0, 180.0, -5.0, 0.0, false, false, true, false, 2, true)
    else
        DeleteObject(object)
        setBoxAnimation(false)
    end
end

local function HasFinishedMissions(skill)
    local misiuniTerminate = 0
    if skill == 2 then
        for k, v in pairs(missionData) do
            if v.made then
                misiuniTerminate = misiuniTerminate + 1
            end 
        end
        return misiuniTerminate == #Config.ConstructorLocations[2][ConstructorLevel].Places
    elseif skill == 3 then
        for k, v in pairs(missionData) do
            if v.made then
                misiuniTerminate = misiuniTerminate + 1
            end 
        end
        return misiuniTerminate == #Config.ConstructorLocations[3][ConstructorLevel].WorkPoints
    end 
end

RegisterNetEvent("fp-constructor:GenerateLevelOne", function(mission)
    missionData.currentMission = missionData.missionCoords[mission][1]

    if DoesBlipExist(LevelOneConstructorBlip) then
        RemoveBlip(LevelOneConstructorBlip)
    end

    LevelOneConstructorBlip = AddBlipForCoord(missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3])
    SetBlipAsShortRange(LevelOneConstructorBlip, true)
    SetBlipColour(LevelOneConstructorBlip, 26)
    SetBlipScale(LevelOneConstructorBlip, 0.7)
    SetBlipRoute(LevelOneConstructorBlip, true)

    missionData.missionStage = 2
end)

local function ToggleLevelOneConstructor(toggle)
    local caramiziLocation = vector3(1383.04296875,-773.25012207031,67.370635986328)
    
    if toggle then
        LevelOneConstructor = true

        vRP.notify({"Ai inceput jobul cu succes! \n Indreapta te spre zona marcata pe harta!", "info"})
        LevelOneConstructorBlip = AddBlipForCoord(1383.04296875,-773.25012207031,67.370635986328)
        SetBlipAsShortRange(LevelOneConstructorBlip, true)
        SetBlipColour(LevelOneConstructorBlip, 26)
        SetBlipScale(LevelOneConstructorBlip, 0.7)
        SetBlipRoute(LevelOneConstructorBlip, true)

        missionData = {
            missionStage = 1,
            missionCoords = Config.ConstructorLocations[1],
            currentMission = false,
            currentSkill = 1,
        }
    else
        LevelOneConstructor = false

        if DoesBlipExist(LevelOneConstructorBlip) then
            RemoveBlip(LevelOneConstructorBlip)
        end
        return;
    end

    Citizen.CreateThread(function()
        while LevelOneConstructor do
            Wait(1)

            if missionData.missionStage == 1 then
                local distance = #(GetEntityCoords(PlayerPedId())- caramiziLocation)

                if distance <= 50 then
                    DrawMarker(0, caramiziLocation[1], caramiziLocation[2], caramiziLocation[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, 0.90, 128, 187, 250, 125, true, true)
            
                    if distance <= 2.5 then
                        if not menuActive then
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Ridica o Caramida"})
                            menuActive = true
                        end
                        if IsControlJustPressed(0, 51) then
                            TriggerEvent("vRP:requestKey", false)
                            menuActive = false
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "Ridici o caramida din gramada...",
                            })
                            Wait(3000)
                            CarryBrick(PlayerPedId(), true)
                            vRP.notify({"Grabteste te cu aceasta caramida! Muncitori asteapta materialele!", "info"})
                            TriggerServerEvent("fp-constructor:reward", missionData.currentSkill, true)                            
                        end
                    else
                        if menuActive then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                        end
                    end
                end
            elseif missionData.missionStage == 2 then
                local distance = #(GetEntityCoords(PlayerPedId())- missionData.currentMission)

                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Lasa jos Caramida"})
                            menuActive = true
                        end
                        if IsControlJustPressed(0, 51) then

                            TriggerEvent("vRP:requestKey", false)
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "Asezi Caramida...",
                            })
                            Wait(3000)
                            ClearPedTasks(PlayerPedId())
                            CarryBrick(PlayerPedId(), false)
                            menuActive = false

                            if DoesBlipExist(LevelOneConstructorBlip) then
                                RemoveBlip(LevelOneConstructorBlip)
                            end

                            LevelOneConstructorBlip = AddBlipForCoord(caramiziLocation[1],caramiziLocation[2],caramiziLocation[3])
                            SetBlipAsShortRange(LevelOneConstructorBlip, true)
                            SetBlipColour(LevelOneConstructorBlip, 26)
                            SetBlipScale(LevelOneConstructorBlip, 0.7)
                            SetBlipRoute(LevelOneConstructorBlip, true)

                            TriggerServerEvent("fp-constructor:reward", missionData.currentSkill, false)

                            missionData.missionStage = 1;
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


RegisterNetEvent("fp-constructor:GenerateLevelTwo", function(mission)
    missionData = {}
    ConstructorLevel = mission
    for k, v in pairs(Config.ConstructorLocations[2][ConstructorLevel].Places) do

        local blip = AddBlipForCoord(v.Pos)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Misiune Constructor")
        EndTextCommandSetBlipName(blip)

        SetBlipSprite(blip, 566)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 26)
        SetBlipAsShortRange(blip, true)

        missionData[#missionData + 1] = {
            coords = v.Pos,
            time = v.WorkingTime,
            type = v.Tool,
            made = false,
            text = v.text,
            blips = blip
        }
    end
    HasMission = true;
end)

local function ToggleLevelTwoConstructor(toggle)
    if toggle then
        HasMission = false
        LevelTwoConstructor = true;
        vRP.notify({"Ai inceput jobul cu succes! \n Indreapta te spre zona marcata pe harta!", "info"})
    else
        LevelTwoConstructor = false
        return;
    end
    Citizen.CreateThread(function()
        while LevelTwoConstructor do
            Wait(1)
            local playerCoords = GetEntityCoords(PlayerPedId())
            if HasMission then
                for k, v in pairs(missionData) do
                    local distance = #(v.coords - playerCoords)
                    if distance <= 50 and not v.made then
                        DrawMarker(2, v.coords[1], v.coords[2], v.coords[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)
                        if distance <= 2.5 then
                            if not menuActive then
                                TriggerEvent("vRP:requestKey", {key = "E", text = "Incepe sa lucrezi"})
                                menuActive = true
                            end
                            if IsControlJustPressed(1, 51) then
                                TriggerEvent("vRP:requestKey", false)
                                FreezeEntityPosition(PlayerPedId(), true)
                                if v.type == 'hammer' then
                                    object = CreateObject(GetHashKey('prop_tool_hammer'), v.coords[1], v.coords[2], v.coords[3], true, true, true)
                                    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0,0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
        
                                    startAnim(PlayerPedId(), 'amb@world_human_hammering@male@base', 'base', v.time)
                                elseif v.type == 'pneumatic hammer' then
                                    object = CreateObject(GetHashKey('prop_tool_jackham'), v.coords[1], v.coords[2],v.coords[3], true, true, true)
                                    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0,0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
        
                                    startAnim(PlayerPedId(), 'amb@world_human_const_drill@male@drill@base', 'base',v.time)
                                elseif v.type == 'drill' then
                                    object = CreateObject(GetHashKey('prop_tool_drill'), v.coords[1], v.coords[2],v.coords[3], true, true, true)
                                    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.07, 0.0, 0.0, 0.0, 90.0, 1, 1, 0, 0, 2, 1)
        
                                    startAnim(PlayerPedId(), 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle',v.time)
                                    RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
                                    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
                                    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
        
                                elseif v.type == 'weld' then
                                    object = CreateObject(GetHashKey('prop_weld_torch'), v.coords[1], v.coords[2],v.coords[3], true, true, true)
                                    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0,0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
        
                                    startAnim(PlayerPedId(), 'amb@world_human_welding@male@base', 'base', v.time)
                                end
                                TriggerEvent("vRP:progressBar", {
                                    duration = v.time,
                                    text = "Lucrezi...",
                                })
                                SetTimeout(v.time, function()
                                    DeleteEntity(object)
                                    ClearPedTasks(PlayerPedId())
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    RemoveBlip(v.blips)
                                    menuActive = false
                                    if HasFinishedMissions(2) then
                                        TriggerServerEvent("fp-constructor:reward", 2, false)
                                        HasMission = false
                                    end
                                end)
                                v.made = true
                            end
                        else
                            if menuActive then
                                TriggerEvent("vRP:requestKey", false)
                                menuActive = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

RegisterNetEvent("fp-constructor:GenerateLevelThree", function(mission)
    missionData = {}
    ConstructorLevel = mission
    for k, v in pairs(Config.ConstructorLocations[3][ConstructorLevel].WorkPoints) do
        local blip = AddBlipForCoord(v.coords)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Misiune Constructor")
        EndTextCommandSetBlipName(blip)

        SetBlipSprite(blip, 566)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 26)
        SetBlipAsShortRange(blip, true)

        missionData[#missionData + 1] = {
            made = false,
            coords = v.coords,
            blip = blip
        }
    end
    HasMission = true
end)


local function ToggleLevelThreeConstructor(toggle)
    if toggle then
        HasMission = false
        LevelThreeConstructor = true
        MissionVehicle = SpawnVehicle("acp_pbipper", vehicleSpawnLocation)
        vRP.notify({"Ai inceput jobul cu succes! \n Indreapta te spre zona marcata pe harta!", "info"})
    else
        if DoesEntityExist(MissionVehicle) then
            DeleteEntity(MissionVehicle)
        end
        LevelThreeConstructor = false
        return;
    end

    local Working = false;

    Citizen.CreateThread(function()
        while LevelThreeConstructor do
            Wait(1)
            local playerCoords = GetEntityCoords(PlayerPedId())
            if HasMission and not Working then
                for k, v in pairs(missionData) do
                    local distance = #(playerCoords - v.coords)
                    if distance <= 50 and not v.made then
                        DrawMarker(2, v.coords[1], v.coords[2], v.coords[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)
    
                        if distance <= 2.5 then
                            if not menuActive then
                                TriggerEvent("vRP:requestKey", {key = "E", text = "Incepe sa lucrezi"})
                                menuActive = true
                            end
                            if IsControlJustPressed(1, 51) then
                                TriggerEvent("vRP:requestKey", false)
                                object = CreateObject(GetHashKey('prop_tool_jackham'), v.coords[1], v.coords[2],v.coords[3], true, true, true)
                                AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0,0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    
                                Working = true
                                FreezeEntityPosition(PlayerPedId(), true)
                                startAnim(PlayerPedId(), 'amb@world_human_const_drill@male@drill@base', 'base',v.time)
                                TriggerEvent("vRP:progressBar", {
                                    duration = 9500,
                                    text = "Lucrezi...",
                                })
                                SetTimeout(9500, function()
                                    DeleteEntity(object)
                                    ClearPedTasks(PlayerPedId())
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    RemoveBlip(v.blip)
                                    menuActive = false
                                    Working = false
    
                                    if HasFinishedMissions(3) then
                                        TriggerServerEvent("fp-constructor:reward", 3, false)
                                        HasMission = false
                                    end
    
                                end)
                                v.made = true;
                            end
                        else 
                            if menuActive then
                                TriggerEvent("vRP:requestKey", false)
                                menuActive = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

CreateThread(function()
	vRP.createPed({"vRP_jobs:constructor", {
		position = hiringLocation,
		rotation = 150,
		model = "s_m_y_construct_02",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Vasile Tecaru",
		description = "Manager job: Constructor",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp-constructor:OpenMenu", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp-constructor:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp-constructor:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-constructor:removeGroup"},
		},
	}})
end)

local function HasJobActive()
   if LevelOneConstructor then
        return true
   elseif LevelTwoConstructor then
        return true
   elseif LevelThreeConstructor then
        return true
   end
    return false
end

RegisterNetEvent("fp-constructor:OpenConstructor", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenConstructor",
        jobActive = HasJobActive(),
        skill = userSkill
    })
end)

RegisterNUICallback("closeConstructor", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startConstructor", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("fp:jobs-constructor", data.skill)
end)

RegisterCommand("constructor", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenConstructor",
        skill = 1
    })
end)

AddEventHandler("FairPlay:JobChange", function(job, skill)
    if job == "Constructor" then
        if skill == 1 then
            ToggleLevelOneConstructor(true)
            ToggleLevelTwoConstructor(false)
            ToggleLevelThreeConstructor(false)
        elseif skill == 2 then
            ToggleLevelOneConstructor(false)
            ToggleLevelTwoConstructor(true)
            ToggleLevelThreeConstructor(false)
        elseif skill == 3 then
            ToggleLevelOneConstructor(false)
            ToggleLevelTwoConstructor(false)
            ToggleLevelThreeConstructor(true)
        end
    else
        ToggleLevelOneConstructor(false)
        ToggleLevelTwoConstructor(false)
        ToggleLevelThreeConstructor(false)
    end
end)

RegisterNetEvent("fp-constructor:addGroup")
AddEventHandler("fp-constructor:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Constructor")
end)

RegisterNetEvent("fp-constructor:removeGroup")
AddEventHandler("fp-constructor:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Constructor")
end)