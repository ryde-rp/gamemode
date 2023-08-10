local vRP = Proxy.getInterface("vRP")
local RVJobs = Tunnel.getInterface("vrp_jobs", "vrp_jobs")

local hiringLocation = vector3(2832.5378417969,2799.7490234375,57.474082946777)
local hasJobMiner = false
local missionData = {
    missionBlip = nil,
}
local menuActive = false
local setScafandru = false
local meniuActiv = false;
local scafandruItem
local mask

local Mineaza = false

RegisterNetEvent("FP:EchipeazaSetScafandru", function()
    if not setScafandru then
        local coords = GetEntityCoords(PlayerPedId())

        scafandruItem = CreateObject(GetHashKey('p_s_scuba_mask_s'), coords[1], coords[2], coords[3], true, true, true)
        mask = CreateObject(GetHashKey('p_s_scuba_tank_s'), coords[1], coords[2], coords[3], true, true, true)

        AttachEntityToEntity(mask, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24818), -0.30, -0.22, 0.0, 0.0, 90.0, 180.0,true, true, false, true, 1, true)
        AttachEntityToEntity(scafandruItem, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 12844), 0.0, 0.0, 0.0, 0.0, 90.0, 180.0,true, true, false, true, 1, true)

        SetPedDiesInWater(PlayerPedId(), false)
        setScafandru = true
    else
        SetPedDiesInWater(PlayerPedId(), true)
        DeleteObject(scafandruItem)
        DeleteObject(mask)
        ClearPedSecondaryTask(PlayerPedId())
        setScafandru = false 
    end
end)

RegisterNetEvent("fp-jobs:miner:GenerateMission", function(mission)
    missionData.currentMission = missionData.missionLocation[mission][1]

    if DoesBlipExist(missionData.missionBlip) then
        RemoveBlip(missionData.missionBlip)
    end

    missionData.missionBlip = AddBlipForCoord(missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3])
    SetBlipAsShortRange(missionData.missionBlip, true)
    SetBlipColour(missionData.missionBlip, 26)
    SetBlipScale(missionData.missionBlip, 0.7)
    SetBlipRoute(missionData.missionBlip, true)
end)

local function StartMinerJob(toggle, skill)
    if toggle then
        hasJobMiner = true
        vRP.notify({"Ai inceput jobul cu succees! \n Indreapta te spre locatia marcata pe harta!"})
        missionData = {
            missionBlip = nil,
            missionLocation = Config.MinerLocations[skill],
            currentMission = false,
            currentSkill = skill,
            PickaxeItem = nil, 
        }
    else
        hasJobMiner = false

        if DoesBlipExist(missionData.missionBlip) then
            RemoveBlip(missionData.missionBlip)
        end

        local missionData = {
            missionBlip = nil,
        }
    end

    Citizen.CreateThread(function()
        while hasJobMiner do
            Wait(1)

            if not Mineaza then
                if missionData.currentMission then
                    local distance = #(GetEntityCoords(PlayerPedId()) - missionData.currentMission)
            
                    if distance <= 50 then
                        DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)
            
                        if distance <= 2.5 then
                            if not menuActive then
                                menuActive = true
                                TriggerEvent("vRP:requestKey", {key = "E", text = "Mineaza"})
                            end
                            if IsControlJustPressed(0, 51) then
                                TriggerEvent("vRP:requestKey", false)
                                RVJobs.hasItemAmount({"tarnacop", 1 , false}, function(hasTarnacop)
                                    if hasTarnacop then
                                        missionData.PickaxeItem = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(missionData.PickaxeItem, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, -0.02, -0.02, 280.0, 10.0, 360.0, true, true, false, true, 1, true)
                                        loadAnimDict("melee@large_wpn@streamed_core")
                                        TaskPlayAnim(PlayerPedId(), 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 8.0, 8.0, -1, 49, 0, 0, 0, 0)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        Mineaza = true;
                                        TriggerEvent("vRP:progressBar", {
                                            duration = 15000,
                                            text = "Minezi...",
                                        })
                                        Wait(15500)
                                        exports.progressbars:MiniGame({
                                            Difficulty = "Easy",
                                            Timeout = 8000, 
                                            onComplete = function(success)
                                                    if success then
                                                        ClearPedTasks(PlayerPedId())
                                                        DetachEntity(missionData.PickaxeItem, 1, true)
                                                        DeleteEntity(missionData.PickaxeItem)
                                                        TriggerServerEvent("fp-miner:RewardMiner", missionData.currentSkill, false)
                                                        menuActive = false
                                                        TriggerEvent("vRP:requestKey", false)
                                                        FreezeEntityPosition(PlayerPedId(), false)
                                                        Mineaza = false
                                                    else
                                                        ClearPedTasks(PlayerPedId())
                                                        DetachEntity(missionData.PickaxeItem, 1, true)
                                                        DeleteEntity(missionData.PickaxeItem)
                                                        TriggerServerEvent("fp-miner:RewardMiner", missionData.currentSkill, true)
                                                        menuActive = false
                                                        TriggerEvent("vRP:requestKey", false)
                                                        FreezeEntityPosition(PlayerPedId(), false)
                                                        Mineaza = false
                                                    end    
                                            end,
                                            onTimeout = function()
                                                ClearPedTasks(PlayerPedId())
                                                DetachEntity(missionData.PickaxeItem, 1, true)
                                                DeleteEntity(missionData.PickaxeItem)
                                                TriggerServerEvent("fp-miner:RewardMiner", missionData.currentSkill, true)
                                                menuActive = false
                                                TriggerEvent("vRP:requestKey", false)
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                Mineaza = false
                                            end
                                        })
                                    else
                                        vRP.notify({"Nu ai un Tarnacop la tine! \n Poti merge sa iti achizitionezi unul de la checkpoint-ul de pe harta!", "info"})
                                        SetNewWaypoint(hiringLocation[1], hiringLocation[2])
                                    end
                                end)
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
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(1)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if #(playerCoords - Config.CarbuneLocation) <= 10 then
            if not meniuActiv then
                meniuActiv = true;
                TriggerEvent("vRP:requestKey", {key = "E", text = "Aduna Carbune"})
            end
            if IsControlJustPressed(0, 51) then
                exports.progressbars:Custom({
                    Duration = 7000,
                    Label = "Aduni carbuni ...",
                    Animation = {
                        scenario = "world_human_gardener_plant",
                        animationDictionary = "idle_b"
                    },
                    DisableControls = {
                        Mouse = false,
                        Player = true,
                        Vehicle = true
                    }
                })
                Wait(7000)
                TriggerServerEvent('FP:GiveCarbune')
            end
        else
            if meniuActiv then
                TriggerEvent("vRP:requestKey", false)
                meniuActiv = false;
            end
            Wait(1000)
        end
    end
end)

CreateThread(function()
	vRP.createPed({"vRP_jobs:minerJob", {
		position = hiringLocation,
		rotation = 120,
		model = "s_m_y_dockwork_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Seba Obreja",
		description = "Manager job: Pescar",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp-miner:OpenMenu", args={"server"}},
            {item = "Vreau sa cumpar un Tarnacop", post= "fp-miner:BuyTarnacop", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp-miner:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp-miner:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-miner:removeGroup"},
		},
	}})
end)

CreateThread(function()
	vRP.createPed({"vRP_jobs:vindeMinereuri", {
		position = vector3(248.75186157227,224.47811889648,106.28707885742),
		rotation = 150,
		model = "u_m_y_chip",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Mihai Viziru",
		description = "Manager Banca",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau sa vand minereuri", post = "fp-miner:vindelingouri", args={"server"}},
		},
	}})
end)


RegisterNetEvent("fp-miner:OpenMiner", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenMiner",
        jobActive = hasJobMiner,
        skill = userSkill
    })
end)

RegisterNUICallback("closeMiner", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startMiner", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('fp-miner:StartJob', data.skill)
    cb("ok")
end)

AddEventHandler("FairPlay:JobChange", function(job, skill)
    if job == "Miner" then
        StartMinerJob(true, skill)
    else
        StartMinerJob(false, 0)
    end
end)

RegisterNetEvent("fp-miner:addGroup")
AddEventHandler("fp-miner:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Miner")
end)

RegisterNetEvent("fp-miner:removeGroup")
AddEventHandler("fp-miner:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Miner")
end)