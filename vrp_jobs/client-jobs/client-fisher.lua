local vRP = Proxy.getInterface("vRP")
local FPJobs = Tunnel.getInterface("vrp_jobs", "vrp_jobs")
local hiringLocation = vector3(-1593.9592285156,5192.8315429688,4.3940372467041)

local inJob = false
local missionData = {
    missionBlip = nil,
}
local isFishing = false

RegisterNetEvent("fp-jobs:fisher:GenerateMission", function(mission)
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

local function StartFisher(toggle, skill)
    if toggle then
        inJob = true
        vRP.notify({"Ai inceput jobul cu success! Indreapta te spre locatia marcata pe harta!"})
        missionData = {
            missionBlip = nil,
            missionLocation = Config.FisherLocations[skill],
            currentMission = false,
            currentSkill = skill,
        }
    else
        inJob = false

        if DoesBlipExist(missionData.missionBlip) then
            RemoveBlip(missionData.missionBlip)
        end

        local missionData = {
            missionBlip = nil,
        }

        return;
    end

    local menuActive = false 

    Citizen.CreateThread(function()
        while inJob do
            Wait(1)

            if not isFishing then
                if missionData.currentMission ~= false then
                    local distance = #(GetEntityCoords(PlayerPedId()) - missionData.currentMission)
            
                    if distance <= 50 then
                        DrawMarker(2, missionData.currentMission[1], missionData.currentMission[2], missionData.currentMission[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)
            
                        if distance <= 2.5 then
                            if not menuActive then
                                menuActive = true
                                TriggerEvent("vRP:requestKey", {key = "E", text = "Pescuieste"})
                            end
                            if IsControlJustPressed(0, 51) then
                                TriggerEvent("vRP:requestKey", false)
                                FPJobs.hasItemAmount({"ramapescar", 1 , true}, function(areMomeala)
                                    if areMomeala then
                                        isFishing = true;
                                        TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_STAND_FISHING", 0, true)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        TriggerEvent("vRP:progressBar", {
                                            duration = 15000,
                                            text = "Pescuiesti...",
                                        })
                                        Wait(15500)
                                        exports.progressbars:MiniGame({
                                            Difficulty = "Easy",
                                            Timeout = 8000, 
                                            onComplete = function(success)
                                                    if success then
                                                        ClearPedTasks(PlayerPedId())
                                                        TriggerServerEvent("fp-jobs:RewardFisher", missionData.currentSkill, false)
                                                        menuActive = false
                                                        TriggerEvent("vRP:requestKey", false)
                                                        FreezeEntityPosition(PlayerPedId(), false)
                                                        isFishing = false
                                                    else
                                                        ClearPedTasks(PlayerPedId())
                                                        TriggerServerEvent("fp-jobs:RewardFisher", missionData.currentSkill, true)
                                                        menuActive = false
                                                        TriggerEvent("vRP:requestKey", false)
                                                        FreezeEntityPosition(PlayerPedId(), false)
                                                        isFishing = false
                                                    end    
                                            end,
                                            onTimeout = function()
                                                ClearPedTasks(PlayerPedId())
                                                TriggerServerEvent("fp-jobs:RewardFisher", missionData.currentSkill, true)
                                                menuActive = false
                                                TriggerEvent("vRP:requestKey", false)
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                isFishing = false
                                            end
                                        })
                                    else
                                        vRP.notify({"Nu ai momeala la tine! \n Poti merge sa culegi din zona marcata pe harta!", "info"})
                                        SetNewWaypoint(-1987.9641113281,2595.6486816406)
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

CreateThread(function()
	vRP.createPed({"vRP_jobs:fisherJob", {
		position = hiringLocation,
		rotation = 220,
		model = "a_m_y_runner_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Marian Corvine",
		description = "Manager job: Pescar",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp-fisher:OpenMenu", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp-fisher:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp-fisher:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp-fisher:removeGroup"},
		},
	}})
end)

RegisterNetEvent("fp-fisher:openFisher", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenFisher",
        jobActive = inJob, 
        skill = userSkill
    })
end)

RegisterNUICallback("closeFisher", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startFisher", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('fp:job-fisher', data.skill)
    cb("ok")
end)

AddEventHandler("FairPlay:JobChange", function(job, skill)
    if job == "Pescar" then
        StartFisher(true, skill)
    else
        StartFisher(false, 0)
    end
end)

RegisterNetEvent("fp-fisher:addGroup")
AddEventHandler("fp-fisher:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Pescar")
end)

RegisterNetEvent("fp-fisher:removeGroup")
AddEventHandler("fp-fisher:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Pescar")
end)