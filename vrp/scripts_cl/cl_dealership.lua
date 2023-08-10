local cfg = {}
local dealershipLocation = vec3(-67.986549377441,72.829200744629,71.899681091309)
local sellerLocation = vec3(-67.117431640625,74.470558166504,71.899688720703)
local categorySpawns = {
    ["barci"] = vec3(-1377.1522216796,-2001.3067626954,0.97041523456574),
    ["avioane"] = vec3(-1630.8156738282,-2973.974609375,13.944745063782),
    ["elicoptere"] = vec3(-1630.8156738282,-2973.974609375,13.944745063782),
}

local uiActive = false
local vehCamera = nil

RegisterNetEvent("vRP:setDealershipConfig")
AddEventHandler("vRP:setDealershipConfig", function(x)
    cfg = x
end)

local function changeCamera()
    DoScreenFadeOut(1000)
    Wait(1000)

    tvRP.teleport(-1267.379272461, -3031.6359863282, -48.490310668946)    
    Wait(500)

    FreezeEntityPosition(tempPed, true)

    local pos = {-1266.9384765625,-3013.2021484375,-48.490211486816}
    local g = Citizen.InvokeNative(0xC906A7DAB05C8D2B,pos[1],pos[2],pos[3],Citizen.PointerValueFloat(),0)

    tvRP.teleport(pos[1], pos[2], g)
    SetEntityHeading(tempPed, pos[4])
    SetEntityVisible(tempPed, false)
    
    if not DoesCamExist(vehCamera) then
        vehCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    
    SetCamActive(vehCamera,true)
    SetCamRot(vehCamera,vec3(-10.0,0.0, 161.3), true)
    SetCamFov(vehCamera,50.0)
    SetCamCoord(vehCamera,vec3(-1267.1352539062,-3023.5187988282,-44.521327972412))
    PointCamAtCoord(vehCamera,vec3(-1266.9384765625,-3013.2021484375,-48.490211486816))
    RenderScriptCams(true, false, 2500.0, true, true)

    DoScreenFadeIn(1000)
    TriggerEvent("vRP:interfaceFocus", true)
    Wait(1000)
end

local function destroyDealership()
    DoScreenFadeOut(500)
    tvRP.teleport(dealershipLocation.x, dealershipLocation.y, dealershipLocation.z)

    FreezeEntityPosition(tempPed, false)
    SetEntityVisible(tempPed, true)

    Wait(1000)

    DoScreenFadeIn(1000)
    RenderScriptCams(false, false, 1, true, true)
    DestroyAllCams(true)
end

local vehicleSpawned = false
local modelLoaded = true
local newVehicle

local function testDrive(model, category)
    local carName = cfg.vehicles[category][model].name
    local hash = GetHashKey(model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end

    local spawnPoint = categorySpawns[category] or vec3(-84.053268432617,79.850700378418,71.557769775391)
    TriggerServerEvent("vRP:setWorld", "privateWorld")

    DoScreenFadeOut(500)
    Wait(1000)

    tvRP.teleport(spawnPoint.x, spawnPoint.y, spawnPoint.z)
    Wait(150)

    local tempVehicle = CreateVehicle(hash, spawnPoint, 150.0, false, false)
    SetVehicleCustomPrimaryColour(tempVehicle, 255, 255, 255)
    SetVehicleCustomSecondaryColour(tempVehicle, 255, 255, 255)
    SetPedIntoVehicle(tempPed, tempVehicle, -1)
    NetworkFadeInEntity(tempVehicle, 1)

    DoScreenFadeIn(500)
    Wait(1000)

    local gameTimer = GetGameTimer() + 60000
    SendNUIMessage({
        act = "interface",
        target = "testdrive",
        model = carName,
    })
    
    while DoesEntityExist(tempVehicle) and gameTimer > GetGameTimer() do
        Wait(1)

        if IsVehicleDamaged(tempVehicle) then
            SetVehicleFixed(tempVehicle)
        end
    end

    DoScreenFadeOut(500)
    Wait(1000)

    DeleteEntity(tempVehicle)
    tvRP.teleport(dealershipLocation.x, dealershipLocation.y, dealershipLocation.z)
    TriggerServerEvent("vRP:setWorld")

    DoScreenFadeIn(500)
    Wait(1000)
end

CreateThread(function()
    RegisterNetEvent("fp-dealership:viewCatalog")
    AddEventHandler("fp-dealership:viewCatalog", function()
        SendNUIMessage({
            act = "interface",
            target = "dealership",
            event = "show",
        })

        uiActive = true

        CreateThread(function()
            while uiActive do
                Wait(1)
                DisplayRadar(false)
            end

            DisplayRadar(true)
        end)

        changeCamera()
    end)

    tvRP.createPed("vRP_dealershipManager", {
        position = sellerLocation,
        rotation = 155,
        model = "u_m_y_ushi",
        freeze = true,
        scenario = {
            name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
        },
        minDist = 3.5,
        
        name = "Manager",
        description = "Manager: Grand Autos",
        text = "Bine ai venit la noi, cu ce te putem ajuta?!",
        fields = {
            {item = "Vreau sa accesez catalogul.", post = "fp-dealership:viewCatalog"},
        },
    })

    tvRP.createBlip("vRP_Dealership:blip", dealershipLocation.x, dealershipLocation.y, dealershipLocation.z, 811, 47, "Reprezentanta Auto", 0.9)
end)

RegisterNUICallback("closeDealership", function(data, cb)
    TriggerEvent("vRP:interfaceFocus", false)
    uiActive = false
    destroyDealership()

    cb("ok")
end)

RegisterNUICallback("setDealershipColors", function(data, cb)
    if data.paint == "primary" then
        SetVehicleCustomPrimaryColour(newVehicle, data.r, data.g, data.b)
    elseif data.paint == "secondary" then
        SetVehicleCustomSecondaryColour(newVehicle, data.r, data.g, data.b)
    end

    cb("ok")
end)

RegisterNUICallback("createDealershipVehicle", function(data, cb)
    local model = data.model
    if not modelLoaded then
        modelLoaded = true
        return cb({breaking = 1, traction = 1, acceleration = 1})
    end

    if not vehicleSpawned then
        vehicleSpawned = true
        modelLoaded = false

        local hash = GetHashKey(model)
        RequestModel(hash) 
        while not HasModelLoaded(hash) do
            Wait(1)
        end

        newVehicle = CreateVehicle(hash, -1266.9384765625, -3013.2021484375, -48.490211486816, 261.46661, false, false)
        SetVehicleCustomPrimaryColour(newVehicle, 255, 255, 255)
        SetVehicleCustomSecondaryColour(newVehicle, 255, 255, 255)
        NetworkFadeInEntity(newVehicle, 1)

        modelLoaded = true

        local breaking = math.floor(GetVehicleModelAcceleration(hash) * 10)
        if breaking > 5 then breaking = 5 end

        local acceleration = math.floor(GetVehicleModelAcceleration(hash) * 10)
        if acceleration > 5 then acceleration = 5 end

        local traction = math.floor(math.floor(GetVehicleModelMaxTraction(hash) * 10)/10)
        if traction > 5 then traction = 5 end

        cb({
            breaking = breaking,
            acceleration = acceleration,
            traction = traction,
        })
    else
        modelLoaded = false
        DeleteEntity(newVehicle)

        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(1)
        end

        newVehicle = CreateVehicle(hash, -1266.9384765625, -3013.2021484375, -48.490211486816, 261.46661, false, false)
        SetVehicleCustomPrimaryColour(newVehicle, 255, 255, 255)
        SetVehicleCustomSecondaryColour(newVehicle, 255, 255, 255)
        NetworkFadeInEntity(newVehicle, 1)
        modelLoaded = true

        local breaking = math.floor(GetVehicleModelAcceleration(hash) * 10)
        if breaking > 5 then breaking = 5 end

        local acceleration = math.floor(GetVehicleModelAcceleration(hash) * 10)
        if acceleration > 5 then acceleration = 5 end

        local traction = math.floor(math.floor(GetVehicleModelMaxTraction(hash) * 10)/10)
        if traction > 5 then traction = 5 end

        cb({
            breaking = breaking,
            acceleration = acceleration,
            traction = traction,
        })
    end

    SetVehicleOnGroundProperly(newVehicle)
    FreezeEntityPosition(newVehicle, true)
end)

RegisterNUICallback("deleteDealershipVehicle", function(data, cb)
    DeleteEntity(newVehicle)
    vehicleSpawned = false

    cb("ok")
end)

RegisterNUICallback("buyDealershipVehicle", function(data, cb)
    TriggerServerEvent("fp-dealership:buyVehicle", data.model, data.category)
    cb("ok")
end)

RegisterNUICallback("testDealershipVehicle", function(data, cb)
    testDrive(data.model, data.category)
    cb("ok")
end)

RegisterNUICallback("getDealershipVehicles", function(data, cb)
    cb(cfg.vehicles[data.category] or {})
end)