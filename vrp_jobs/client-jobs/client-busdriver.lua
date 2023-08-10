local vRP = Proxy.getInterface("vRP")

local missionData = {vehicle = false, busBlip = nil}
local inCursa = false
local finishPos = vec3(471.51501464844,-582.11981201172,28.499822616578)
local hiringLocation = vec3(442.9266052246,-628.20416259766,28.520711898804)

local JobVehicle;

local function GenerateBusStation()
    missionData.step = missionData.step + 1

    if DoesBlipExist(missionData.busBlip) then
        RemoveBlip(missionData.busBlip)
    end

    if missionData.step >= missionData.maxSteps then
        missionData.finishing = true
        missionData.busBlip = AddBlipForCoord(finishPos)
        SetBlipAsShortRange(missionData.busBlip, true)
        SetBlipColour(missionData.busBlip, 1)
        SetBlipScale(missionData.busBlip, 0.7)
        SetBlipRoute(missionData.busBlip, true)
    else
        missionData.busBlip = AddBlipForCoord(missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3])
        SetBlipAsShortRange(missionData.busBlip, true)
        SetBlipColour(missionData.busBlip, 26)
        SetBlipScale(missionData.busBlip, 0.7)
        SetBlipRoute(missionData.busBlip, true)
    end
end

local function StartBusDriver(toggle,userSkil)
    if toggle then
        inCursa = true

        missionData = {
            step = 1,
            route = Config.BusRoutes[userSkil],
            maxSteps = #Config.BusRoutes[userSkil],
            finishing = false,
            currentSkill = userSkil,
            busBlip = nil,
        }

        JobVehicle =  SpawnVehicle(Config.BusSkills[userSkil], {464.86700439453,-622.99896240234,28.499542236328})

        missionData.busBlip = AddBlipForCoord(missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3])
        SetBlipAsShortRange(missionData.busBlip, true)
        SetBlipColour(missionData.busBlip, 26)
        SetBlipScale(missionData.busBlip, 0.7)
        SetBlipRoute(missionData.busBlip, true)
    else
        inCursa = false

        if DoesBlipExist(missionData.busBlip) then
            RemoveBlip(missionData.busBlip)
        end

        if DoesEntityExist(JobVehicle) then
            DeleteEntity(JobVehicle)
        end

        local missionData = {vehicle = false, busBlip = nil}
    end

    
    Citizen.CreateThread(function()
        while inCursa do
            Wait(1)

            if IsPedInAnyVehicle(PlayerPedId()) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle == JobVehicle then
                    local distance = #(GetEntityCoords(JobVehicle) - missionData.route[missionData.step][1])
                

                    local isStation = missionData.route[missionData.step][2]

                    if distance < 50 and not missionData.finishing then
                        if not isStation then
                            DrawMarker(20, missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3] + 4.20, 0, 0, 0, 0, 0, 0, 4.60, 6.60, -4.60, 174, 219, 242, 125, true, true, false, true)
                            DrawMarker(6, missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3] + 4.20, 0, 0, 0, 0, 0, 0, 6.60, 8.60, 6.60, 255, 255, 255, 90, true, true, false)
                        else
                            DrawMarker(0, missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3] + 0.20, 0, 0, 0, 0, 0, 0, 6.60, 6.60, 12.60, 255, 255, 255, 30, true, true, false, true)
                            DrawMarker(20, missionData.route[missionData.step][1][1], missionData.route[missionData.step][1][2], missionData.route[missionData.step][1][3] + 2.60, 0, 0, 0, 0, 0, 0, 4.60, 4.60, -4.60, 174, 219, 242, 135, true, true, false, true)
                        end
                    end

                    if distance <= 2.5 and not missionData.finishing then
                        if isStation then
                            FreezeEntityPosition(JobVehicle, true)
                            TriggerEvent("vRP:progressBar", {
                                duration = 10000,
                                text = "🚌 Astepti pasageri...",
                            })
                            Wait(10000)
                            FreezeEntityPosition(JobVehicle, false)
                            GenerateBusStation()
                        else
                            GenerateBusStation()
                        end
                    end


                    if missionData.finishing then
                        local sentAlert = false
                        if #(GetEntityCoords(PlayerPedId()) -  finishPos) <= 15 then
                            DrawMarker(4, finishPos.x, finishPos.y, finishPos.z + 2.60, 0, 0, 0, 0, 0, 0, 4.60, 6.60, -4.60, 174, 219, 242, 125, true, true, false, true)
                            DrawMarker(6, finishPos.x, finishPos.y, finishPos.z + 2.60, 0, 0, 0, 0, 0, 0, 6.60, 8.60, 6.60, 255, 255, 255, 90, true, true, false)
                           
                            if #(finishPos - GetEntityCoords(PlayerPedId())) <= 5 then
                                if not sentAlert then
                                    sentAlert = true
                                    TriggerEvent("vRP:requestKey", {key = "E", text = "PARCHEAZA AUTOBUZUL"})
                                end

                                if IsControlJustReleased(0, 51) then
                                    DeleteVehicle(JobVehicle)

                                    if DoesBlipExist(missionData.busBlip) then
                                        RemoveBlip(missionData.busBlip)
                                    end

                                    TriggerServerEvent("fp:job-busdriver-finish",missionData.currentSkill)

                                    sentAlert = false
                                    inCursa = false
                                    TriggerEvent("vRP:requestKey", false)


                                    CreateThread(function()
                                        Wait(1500)
                                        missionData = nil
                                    end)
                                    break
                                end
                            else
                                if sentAlert then
                                    sentAlert = false
                                    TriggerEvent("vRP:requestKey", false)
                                end
                            end

                        end
                    end

                else
                    vRP.subtitleText({"~b~Info: ~w~Trebuie sa fi in autobuz pentru ca pasagerii sa poata urca.", false, false, false, false, 0.9165})
                    vRP.subtitleText({"~HC_28~(( Intoarce-te la autobuz pentru a continua cursa.. ))", false, false, false, false, 0.9350})
                end
            else
                vRP.subtitleText({"~b~Info: ~w~Trebuie sa fi in autobuz pentru ca pasagerii sa poata urca.", false, false, false, false, 0.9165})
                vRP.subtitleText({"~HC_28~(( Intoarce-te la autobuz pentru a continua cursa.. ))", false, false, false, false, 0.9350})
            end
        end
    end)
end

CreateThread(function()
	vRP.createPed({"vRP_jobs:busChief", {
		position = hiringLocation,
		rotation = 85,
		model = "a_m_m_business_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Dumitru Vlajgan",
		description = "Manager job: Sofer de Autobuz",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fp:job-busdriver:openmenu", args={"server"}},
            {item = "Vreau sa cumpar licenta", post = "fp:job-busdriver:BuyLicense", args={"server"}},
            {item = "Vreau sa ma angajez.", post = "fp:job-busdriver:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fp:job-busdriver:removeGroup"},
		},
	}})
end)

RegisterNetEvent("fp-bus:openBus", function(userSkill)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenBus",
        jobActive = inCursa,
        skill = userSkill
    })
end)

RegisterNUICallback("CloseBus", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startBus", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('fp:job-busdriver', data.skill)
    cb("ok")
end)

AddEventHandler("FairPlay:JobChange", function(job, skill)
    if job == "Sofer de Autobuz" then
        StartBusDriver(true, skill)
    else
        StartBusDriver(false, 0)
    end
end)

RegisterNetEvent("fp:job-busdriver:addGroup")
AddEventHandler("fp:job-busdriver:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Sofer Autobuz")
end)

RegisterNetEvent("fp:job-busdriver:removeGroup")
AddEventHandler("fp:job-busdriver:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Sofer Autobuz")
end)