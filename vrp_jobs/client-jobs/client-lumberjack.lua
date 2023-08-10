local vRP = Proxy.getInterface("vRP")

local missionData = {}  
local hiringLocation =  vector3(-567.76177978516,5253.06640625,70.487510681152)

local object
local levelOneJob = false;
local levelTwoJob = false;
local levelThreeJob = false;

local LevelOneMissionBlip = nil
local LevelTwoMissionBlip = nil
local LevelThreeMissionBlip = nil


local function LumberjackSkillOne(toggle)
    local prelucratLocation = vector3(-471.82211303711,5303.2412109375,86.032455444336)
    
    if toggle then
        levelOneJob = true
        missionData = {
            missionStage = 2,
            missionCoords = Config.LumberjackLocations[1],
            currentMission = vector3(-506.34713745117,5262.9833984375,80.622421264648),
            currentSkill = 1,
        }
    else
        levelOneJob = false

        if DoesBlipExist(LevelOneMissionBlip) then
            RemoveBlip(LevelOneMissionBlip)
        end
        return;
    end

    local function PadurarWoodAnimation(ped, toggle)
        if toggle then 
            object = CreateObject(GetHashKey("prop_fncwood_16e"), GetEntityCoords(PlayerPedId()), true, true, true)
            setBoxAnimation(true, true)
            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.23, 0.05, -0.70, -15.0, 0.0, 24.0, true, false, false, true, 1, true)
        else
            DeleteObject(object)
            setBoxAnimation(false)
        end
    end

    local function GenerateMission()
        missionData.currentMission = missionData.missionCoords[math.random(1, #missionData.missionCoords)][1]

        if DoesBlipExist(LevelOneMissionBlip) then
            RemoveBlip(LevelOneMissionBlip)
        end

        LevelOneMissionBlip = AddBlipForCoord(missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3])
        SetBlipAsShortRange(LevelOneMissionBlip, true)
        SetBlipColour(LevelOneMissionBlip, 26)
        SetBlipScale(LevelOneMissionBlip, 0.7)
        SetBlipRoute(LevelOneMissionBlip, true)

        missionData.missionStage = 1
    end

    GenerateMission();

    local menuActive = false

    Citizen.CreateThread(function()
        while levelOneJob do
            Wait(1)

            if missionData.missionStage == 1 then

                local distance = #(GetEntityCoords(PlayerPedId())- missionData.currentMission)

                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Colecteaza Lemnul"})
                            menuActive = true
                        end
                        if IsControlJustPressed(0, 51) then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "🪚 Colectezi lemne...",
                            })
                            Wait(3000)
                            ClearPedTasks(PlayerPedId())
                            PadurarWoodAnimation(PlayerPedId(), true)

                            if DoesBlipExist(LevelOneMissionBlip) then
                                RemoveBlip(LevelOneMissionBlip)
                            end

                            LevelOneMissionBlip = AddBlipForCoord(prelucratLocation[1],prelucratLocation[2],prelucratLocation[3])
                            SetBlipAsShortRange(LevelOneMissionBlip, true)
                            SetBlipColour(LevelOneMissionBlip, 26)
                            SetBlipScale(LevelOneMissionBlip, 0.7)
                            SetBlipRoute(LevelOneMissionBlip, true)

                            vRP.notify({"Du lemnul pe banda!"})

                            missionData.missionStage = 2
                        end
                    else
                        if menuActive then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                        end
                    end
                end

            elseif missionData.missionStage == 2 then
                local distance = #(GetEntityCoords(PlayerPedId())- prelucratLocation)

                if distance <= 50 then
                    DrawMarker(0, prelucratLocation[1], prelucratLocation[2], prelucratLocation[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, 0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Prelucreaza lemnul"})
                            menuActive = true
                        end
                        if IsControlJustPressed(0, 51) then
                            TriggerEvent("vRP:requestKey", false)
                            menuActive = false
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "🪚 Plasezi lemnul pe banda...",
                            })
                            Wait(3000)
                            PadurarWoodAnimation(PlayerPedId(), false)
                            TriggerServerEvent("fp-lumberjack:reward", missionData.currentSkill, false)
                            GenerateMission()
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

RegisterNetEvent("fp-lumberjack:GenerateMission", function(mission)
    missionData.currentMission = Config.LumberjackLocations[1][mission][1]

    if DoesBlipExist(LevelTwoMissionBlip) then
        RemoveBlip(LevelTwoMissionBlip)
    end

    LevelTwoMissionBlip = AddBlipForCoord(missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3])
    SetBlipAsShortRange(LevelTwoMissionBlip, true)
    SetBlipColour(LevelTwoMissionBlip, 26)
    SetBlipScale(LevelTwoMissionBlip, 0.7)
    SetBlipRoute(LevelTwoMissionBlip, true)
end)

local function LumberjackSkillTwo(toggle)
    if toggle then
        levelTwoJob = true
        missionData = {
            missionStage = 1,
            currentSkill = 2,
            currentLocation = false
        }
    else
        levelTwoJob = false

        if DoesBlipExist(LevelTwoMissionBlip) then
            RemoveBlip(LevelTwoMissionBlip)
        end
        return;
    end

    local ProcessTables = {}
    local menuActive = false

    local tableLocations = {
        {
            vector3(-592.32836914063,5345.509765625,69.27320098877)
        },
        {
            vector3(-590.85015869141,5349.291015625,69.355575561523)
        }
    }
    
    local TreeLocation = {
        {
            vector3(-540.43493652344,5379.8583984375,70.49861907959),
        },
        {
            vector3(-554.12023925781,5369.99609375,70.360900878906),
        },
        {
            vector3(-532.17114257813,5372.462890625,70.440864562988),
        },
        {
            vector3(-501.63101196289,5377.77734375,75.839950561523),
        },
    }
    


    local function GenerateUserLocation()
        missionData.currentMission = TreeLocation[math.random(1, #TreeLocation)][1]

        if DoesBlipExist(LevelTwoMissionBlip) then
            RemoveBlip(LevelTwoMissionBlip)
        end

        LevelTwoMissionBlip = AddBlipForCoord(missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3])
        SetBlipAsShortRange(LevelTwoMissionBlip, true)
        SetBlipColour(LevelTwoMissionBlip, 26)
        SetBlipScale(LevelTwoMissionBlip, 0.7)
        SetBlipRoute(LevelTwoMissionBlip, true)
    end 

    GenerateUserLocation();

    Citizen.CreateThread(function()
        for k, v in pairs(tableLocations) do
            if DoesEntityExist(ProcessTables[k]) then
                DeleteEntity(ProcessTables[k])
            end
            ProcessTables[k] = CreateObject(GetHashKey("prop_tool_bench02_ld"), v[1], true, true, true)
            SetEntityRotation(ProcessTables[k], 0.0, 0.0, -20.0, 2, true)
            FreezeEntityPosition(ProcessTables[k], true)
            Wait(50)
        end
    end)

    local function PadurarWoodAnimation(ped, toggle)
        if toggle then 
            object = CreateObject(GetHashKey("prop_fncwood_16e"), GetEntityCoords(PlayerPedId()), true, true, true)
            setBoxAnimation(true, true)
            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.23, 0.05, -0.70, -15.0, 0.0, 24.0, true, false, false, true, 1, true)
        else
            DeleteObject(object)
            setBoxAnimation(false)
        end
    end

    local function CarryWood(ped, toggle)
        if toggle then 
            object = CreateObject(GetHashKey("prop_log_01"), GetEntityCoords(PlayerPedId()), true, true, true)
            setBoxAnimation(true, false)
            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.10, 0.15, -0.15, 60.0, -10.0, 75.0, true, false, false, true, 1, true)
        else
            DeleteObject(object)
            setBoxAnimation(false)
        end
    end

    Citizen.CreateThread(function()
        while levelTwoJob do
            Wait(1)

            if missionData.missionStage == 1 then
                local distance = #(GetEntityCoords(PlayerPedId())- missionData.currentMission)
                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            menuActive = true
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Ridici Busteanu"})
                        end
                        if IsControlJustPressed(0, 51) then
                            TriggerEvent("vRP:requestKey", false)
                            menuActive = false
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "🪚 Ridici Busteanul...",
                            })
                            Wait(3000)
                            ClearPedTasks(PlayerPedId())
                            CarryWood(PlayerPedId(), true)
                            if DoesBlipExist(LevelTwoMissionBlip) then
                                RemoveBlip(LevelTwoMissionBlip)
                                
                                LevelTwoMissionBlip = AddBlipForCoord(-594.02087402344,5348.0004882813,70.331214904785)
                                SetBlipAsShortRange(LevelTwoMissionBlip, true)
                                SetBlipColour(LevelTwoMissionBlip, 26)
                                SetBlipScale(LevelTwoMissionBlip, 0.7)
                                SetBlipRoute(LevelTwoMissionBlip, true)
                            end
                            vRP.notify({"Transporta busteanul la procesat!"})
                            missionData.missionStage = 2
                        end
                    else
                        if menuActive then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                        end
                    end
                end
            end

            if missionData.missionStage == 2 then
                for k, v in pairs(tableLocations) do
                    local distance = #(GetEntityCoords(PlayerPedId())- v[1])

                    if distance <= 50 then
                        DrawMarker(2, v[1][1] - 1.00,v[1][2] + 0.20,v[1][3] + 0.75, 0, 0, 0, 0, 0, 0, 0.90, 0.50, -0.90, 128, 187, 250, 125, true, true)

                        if distance <= 2.5 then
                            if not menuActive then
                                menuActive = true
                                TriggerEvent("vRP:requestKey", {key = "E", text = "Proceseaza Busteanul"})
                            end
                            if IsControlJustPressed(0, 51) then
                                menuActive = false
                                TriggerEvent("vRP:requestKey", false)
                                vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                                CarryWood(PlayerPedId(), false)
                                FreezeEntityPosition(PlayerPedId(),true)
                                TriggerEvent("vRP:progressBar", {
                                    duration = 10000,
                                    text = "🪚 Procesezi Busteanul...",
                                })
                                Wait(10000)
                                ClearPedTasks(PlayerPedId())
                                PadurarWoodAnimation(PlayerPedId(), true)
                                FreezeEntityPosition(PlayerPedId(),false)
                                TriggerServerEvent("fp-lumberjack:reward", missionData.currentSkill, true);
                                vRP.notify({"Du lemnul in gramada cu restul!"})
                                missionData.missionStage = 3
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

            if missionData.missionStage == 3 then
                local distance = #(GetEntityCoords(PlayerPedId())- missionData.currentMission)
                if distance <= 50 then
                    DrawMarker(2, missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        if not menuActive then
                            menuActive = true
                            TriggerEvent("vRP:requestKey", {key = "E", text = "Aseaza scandura in gramada"})
                        end
                        if IsControlJustPressed(0, 51) then
                            menuActive = false
                            TriggerEvent("vRP:requestKey", false)
                            vRP.playAnim({false, {{"pickup_object", "putdown_low"}}, false})
                            TriggerEvent("vRP:progressBar", {
                                duration = 3000,
                                text = "🪚 Asezi scandura in gramada...",
                            })
                            Wait(3000)
                            ClearPedTasks(PlayerPedId())
                            PadurarWoodAnimation(PlayerPedId(), false)
                            TriggerServerEvent("fp-lumberjack:reward", missionData.currentSkill, false);
                            GenerateUserLocation();
                            missionData.missionStage = 1
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

local function SpawnTrailer()
    local i = 0
    local mhash = GetHashKey("tvtrailer")
    while not HasModelLoaded(mhash) and i < 1000 do
        RequestModel(mhash)
        Citizen.Wait(10)
        i = i+1
    end

    local coords = vector3(-580.80444335938,5243.25390625,70.469467163086)
    local trailer = CreateVehicle(mhash, coords, 0.0, true, true)
    local trailerBlip = AddBlipForEntity(trailer)
    SetBlipSprite(trailerBlip, 479)
    local rotation = vector3(0.0, -0.133276, -23.9509)
    SetEntityRotation(trailer, rotation, true, true)
    return trailer
end

local function LumberjackSkillThree(toggle, vehicle)
    if toggle then
        levelThreeJob = true
        missionData = {
            missionStage = 1,
            currentMission = nil,
            missionRadius = nil,
            currentSkill = 3,
            trailerAttached = false,
            truck = vehicle,
            busteanNumber = 0,
            trailer = SpawnTrailer(),
        }
    else
        if DoesBlipExist(LevelThreeMissionBlip) then
            RemoveBlip(LevelThreeMissionBlip)
        end

        levelThreeJob = false

        return;
    end

    local menuActive = false

    if levelThreeJob then
        local function GenerateNextMission()
            if DoesBlipExist(LevelThreeMissionBlip) then
                RemoveBlip(LevelThreeMissionBlip)
            end

            missionData.currentMission = Config.LumberjackLocations[2][math.random(1, #Config.LumberjackLocations[2])][1]

            LevelThreeMissionBlip = AddBlipForCoord(missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3])
            SetBlipAsShortRange(LevelThreeMissionBlip, true)
            SetBlipColour(LevelThreeMissionBlip, 25)
            SetBlipScale(LevelThreeMissionBlip, 0.7)
            SetBlipRoute(LevelThreeMissionBlip, true)
        end

        local function CarryWood(ped, toggle)
            if toggle then 
                object = CreateObject(GetHashKey("prop_log_01"), GetEntityCoords(PlayerPedId()), true, true, true)
                setBoxAnimation(true, false)
                AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.10, 0.15, -0.15, 60.0, -10.0, 75.0, true, false, false, true, 1, true)
            else
                DeleteObject(object)
                setBoxAnimation(false)
            end
        end

        Citizen.CreateThread(function()
            while levelThreeJob do
                Wait(1)

                if DoesEntityExist(missionData.trailer) then

                    if missionData.missionStage == 1 then
                        if IsEntityAttachedToAnyVehicle(missionData.trailer) then
                            if GetEntityAttachedTo(missionData.trailer) == missionData.truck then
                                if not missionData.trailerAttached then
                                    missionData.trailerAttached = true
                                    missionData.missionRadius = AddBlipForRadius(-388.30508422852,2595.1669921875,89.728607177734, 75.0)
                                    SetBlipColour(missionData.missionRadius, 11)
                                    -- mision blip
                                    LevelThreeMissionBlip = AddBlipForCoord(-388.30508422852,2595.1669921875,89.728607177734)
                                    SetBlipAsShortRange(LevelThreeMissionBlip, true)
                                    SetBlipColour(LevelThreeMissionBlip, 25)
                                    SetBlipScale(LevelThreeMissionBlip, 0.7)
                                    SetBlipRoute(LevelThreeMissionBlip, true)
                                end
                                
                                local distance = #(GetEntityCoords(PlayerPedId())- vector3(-388.30508422852,2595.1669921875,89.728607177734))

                                if distance <= 150 then
                                    missionData.missionStage = 2
                                    GenerateNextMission();
                                else
                                    vRP.subtitleText({"~b~Info: ~w~Condu pana la zona marcata pe harta!", false, false, false, false, 0.9165})
                                end
                            else
                                vRP.subtitleText({"~b~Info: ~w~Trebuie sa ai camionul tau atasat la trailer!", false, false, false, false, 0.9165})
                                vRP.subtitleText({"~HC_28~(( Ataseaza camionul tau la trailer pentru a continua misiunea.. ))", false, false, false, false, 0.9350})
                            end
                        else
                            vRP.subtitleText({"~b~Info: ~w~Trebuie sa ai camionul tau atasat la trailer!", false, false, false, false, 0.9165})
                            vRP.subtitleText({"~HC_28~(( Ataseaza camionul tau la trailer pentru a continua misiunea.. ))", false, false, false, false, 0.9350})
                            local x,y,z = table.unpack(GetEntityCoords(missionData.trailer));
                            DrawMarker(2, x,y,z + 2.50, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)
                        end
                    end

                    if missionData.missionStage == 2 then
                        vRP.subtitleText({"~b~Info: ~w~Trebuie sa tai copacii pe care sa ii incarci in Remorca!", false, false, false, false, 0.9165})

                        local distance = #(GetEntityCoords(PlayerPedId()) - missionData.currentMission)

                        if distance <= 50 then
                            DrawMarker(2, missionData.currentMission[1],missionData.currentMission[2],missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                            if distance <= 2.5 then
                                if not menuActive then
                                    TriggerEvent('vRP:requestKey', {key = "E", text = "Taie copacul"})
                                    menuActive = true
                                end
                                if IsControlJustPressed(0, 51) then
                                    menuActive = false
                                    TriggerEvent('vRP:requestKey', false)

                                    local ToporItem = CreateObject(GetHashKey("w_me_hatchet"), 0, 0, 0, true, true, true)
                                    AttachEntityToEntity(ToporItem, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, -0.02, -0.02, 280.0, 10.0, 360.0, true, true, false, true, 1, true)
                                    loadAnimDict("melee@hatchet@streamed_core")
                                    Wait(100)
                                    TaskPlayAnim(PlayerPedId(), 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 8.0,8.0, -1, 49, 0, 0, 0, 0)

                                    exports.progressbars:MiniGame({
                                        Difficulty = "Easy",
                                        Timeout = 8000, 
                                        onComplete = function(success)
                                                if success then
                                                    ClearPedTasks(PlayerPedId())
                                                    DeleteEntity(ToporItem)
                                                    CarryWood(PlayerPedId(), true)
                                                    vRP.notify({"Du copacul taiat la remorca!", "info"})
                                                    menuActive = false
                                                    TriggerEvent("vRP:requestKey", false)
                                                    missionData.missionStage = 3;
                                                else
                                                    ClearPedTasks(PlayerPedId())
                                                    DeleteEntity(ToporItem)
                                                    menuActive = false
                                                    TriggerEvent("vRP:requestKey", false)
                                                    GenerateNextMission();
                                                end    
                                        end,
                                        onTimeout = function()
                                            menuActive = false
                                            TriggerEvent("vRP:requestKey", false)
                                            ClearPedTasks(PlayerPedId())
                                            DeleteEntity(ToporItem)
                                            GenerateNextMission()
                                        end
                                    })
                                end
                            else
                                menuActive = false
                                TriggerEvent("vRP:requestKey", false)
                            end
                        end
                    end

                    if missionData.missionStage == 3 then
                        local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(missionData.trailer))

                        if distance <= 25 then
                            local x,y,z = table.unpack(GetEntityCoords(missionData.trailer));
                            DrawMarker(2, x,y,z + 2.50, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                            if distance <= 2.5 then
                                if not menuActive then
                                    TriggerEvent('vRP:requestKey', {key = "E", text = "Incarca copacul"})
                                    menuActive = true
                                end
                                if IsControlJustPressed(0, 51) then
                                    menuActive = false
                                    TriggerEvent('vRP:requestKey', false)
                                    TriggerEvent("vRP:progressBar", {
                                        duration = 3000,
                                        text = "🪚 Incarci copacul in Remorca...",
                                    })
                                    Wait(3000)
                                    CarryWood(PlayerPedId(), false)
                                    missionData.busteanNumber = missionData.busteanNumber + 1

                                    if missionData.busteanNumber == 10 then
                                        missionData.missionStage = 4
                                        vRP.notify({"Livreaza copacii inapoi la sediu!", "info"})
                                        if DoesBlipExist(LevelThreeMissionBlip) then
                                            RemoveBlip(LevelThreeMissionBlip)
                                        end
                                        LevelThreeMissionBlip = AddBlipForCoord(-555.84722900391,5388.3579101563,68.82356262207)
                                        SetBlipAsShortRange(LevelThreeMissionBlip, true)
                                        SetBlipColour(LevelThreeMissionBlip, 25)
                                        SetBlipScale(LevelThreeMissionBlip, 0.7)
                                        SetBlipRoute(LevelThreeMissionBlip, true)
                                    else
                                        GenerateNextMission()
                                        vRP.notify({"Mai ai nevoie de " .. 10 - missionData.busteanNumber .. " copaci!", "info"})
                                        missionData.missionStage = 2
                                    end
                                end
                            else
                                menuActive = false
                                TriggerEvent("vRP:requestKey", false)
                            end
                        end  
                    end

                    if missionData.missionStage == 4 then

                        local finishCoords = vector3(-555.84722900391,5388.3579101563,68.82356262207)
                        local distance = #(GetEntityCoords(PlayerPedId()) - finishCoords)

                        if distance <= 50 then
                            DrawMarker(0, finishCoords[1], finishCoords[2], finishCoords[3] + 0.20, 0, 0, 0, 0, 0, 0, 6.60, 6.60, 12.60, 255, 255, 255, 30, true, true, false, true)
                            DrawMarker(20, finishCoords[1], finishCoords[2], finishCoords[3] + 2.60, 0, 0, 0, 0, 0, 0, 4.60, 4.60, -4.60, 174, 219, 242, 135, true, true, false, true)

                            if distance <= 2.5 then
                                if not menuActive then
                                    TriggerEvent("vRP:requestKey", {key = "E", text = "Termina cursa"})
                                end
                                if IsControlJustPressed(0, 51) then
                                    menuActive = false
                                    TriggerEvent("vRP:requestKey", false)
                                    TriggerEvent("vRP:progressBar", {
                                        duration = 3000,
                                        text = "🪚 Livrezi copacii...",
                                    })
                                    Wait(3000)
                                    DeleteEntity(missionData.trailer);
                                    if DoesBlipExist(LevelThreeMissionBlip) then
                                        RemoveBlip(LevelThreeMissionBlip)
                                    end
                                    TriggerServerEvent("fp-lumberjack:reward", missionData.currentSkill, false)
                                    levelThreeJob = false;
                                    missionData = {}
                                end
                            else
                                menuActive = false
                                TriggerEvent("vRP:requestKey", false)
                            end
                        end
                    end

                    local trailerDistance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(missionData.trailer))
                    if trailerDistance <= 5 then
                        local x,y,z = table.unpack(GetEntityCoords(missionData.trailer));
                        DrawText3D(x,y,z,"Busteni in Remorca \n ~b~Numar:~w~"..missionData.busteanNumber.."/10 \n Apasa ~b~[E]~w~ pentru a incarca busteni", 1.0, 0)
                    end
                end
            end
        end)
    end
end

CreateThread(function()
	vRP.createPed({"vRP_jobs:lumberJack", {
		position = hiringLocation,
		rotation = 85,
		model = "a_m_m_farmer_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Paduraru Ion",
		description = "Manager job: Taietor de Lemne",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp-lumberjack", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp-lumberjack:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp-lumberjack:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-lumberjack:removeGroup"},
		},
	}})
end)

local function HasActiveJob()
    if levelOneJob then
        return true
    elseif levelTwoJob then
        return true
    elseif levelThreeJob then
        return true
    end
    return false
end

RegisterNetEvent("fp:job-lumberjack:openmenu", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenLumberjack",
        jobActive = HasActiveJob(),
        skill = userSkill
    })
end)

RegisterNUICallback("closeLumberjack", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startLumberjack", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("fp:job-lumberjack", data.skill)
end)

AddEventHandler("FairPlay:JobChange", function(job, skill, vehicle)
    if job == "Taietor de Lemne" then
        if skill == 1 then
            LumberjackSkillOne(true)
            LumberjackSkillTwo(false)
            LumberjackSkillThree(false)
        elseif skill == 2 then
            LumberjackSkillTwo(true)
            LumberjackSkillOne(false)
            LumberjackSkillThree(false)
        elseif skill == 3 then
            LumberjackSkillThree(true, vehicle)
            LumberjackSkillOne(false)
            LumberjackSkillTwo(false)
        end
    else
        LumberjackSkillOne(false)
        LumberjackSkillTwo(false)
        LumberjackSkillThree(false)
    end
end)

RegisterNetEvent("fp-lumberjack:addGroup")
AddEventHandler("fp-lumberjack:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Taietor de Lemne")
end)

RegisterNetEvent("fp-lumberjack:removeGroup")
AddEventHandler("fp-lumberjack:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Taietor de Lemne")
end)