local RVUtils = Tunnel.getInterface("vrp_jafpacific", "vrp_jafpacific")
local vRP = Proxy.getInterface("vRP")

local ActiveRobbery = false;
local CanLoot = false;
local CurrentStep = 1;

local Doorlocked = {};
local GasAlert = false;
local stopTimer = false

-- Minigame Verifications
local PasswordMinigame = false;
local MinigamesAttempt = 0;
local Minigame = false;

local RobberyProps = {}

RegisterNetEvent("FP:BankRobbery:ResetSystem", function()
    for k, v in pairs(RobberyProps) do
        if DoesEntityExist(v.obj) then
            DeleteObject(v.obj)
        end
    end

    RobberyProps = {};
    PasswordMinigame = false;
    MinigamesAttempt = 0;
    Minigame = false;
    GasAlert = false
    ActiveRobbery = false;
    stopTimer = false;
    CanLoot = false
    CurrentStep = 1;
end)

local RobberyEvents = {
    {
        coords = vector3(257.10, 220.30, 106.28),
        text = "[~b~E~w~] Pentru a incepe ~w~jaful",
        EventStep = 1,
        Event = function()
            local loc = vector3(257.40, 220.20, 106.35)
            local heading = 336.48
            local ptfx = vector3(257.39, 221.20, 106.29)
            local oldmodel = "hei_v_ilev_bk_gate_pris"
            local newmodel = "hei_v_ilev_bk_gate_molten"

            RVUtils.CanRobBank({}, function(canRob, notify)
                if canRob then
                    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                    RequestModel("hei_p_m_bag_var22_arm_s")
                    RequestNamedPtfxAsset("scr_ornate_heist")
                    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                        Citizen.Wait(50)
                    end
                    local ped = PlayerPedId()
                    SetEntityHeading(ped, heading)
                    Citizen.Wait(100)
                    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
                    local bagscene = NetworkCreateSynchronisedScene(loc[1], loc[2], loc[3], rotx, roty, rotz + 0, 2, false, false, 1065353216, 0, 1.3)
                    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), loc[1], loc[2], loc[3],  true,  true, false)
                    SetEntityCollision(bag, false, true)
                    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
                    SetPedComponentVariation(ped, 5, 0, 0, 0)
                    NetworkStartSynchronisedScene(bagscene)
                    Citizen.Wait(1500)
                    local x, y, z = table.unpack(GetEntityCoords(ped))
                    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
                    SetEntityCollision(bomba, false, true)
                    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                    Citizen.Wait(4000)
                    DeleteObject(bag)
                    SetPedComponentVariation(ped, 5, 45, 0, 0)
                    DetachEntity(bomba, 1, 1)
                    FreezeEntityPosition(bomba, true)
                    SetPtfxAssetNextCall("scr_ornate_heist")
                    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    NetworkStopSynchronisedScene(bagscene)
                
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
                    Citizen.Wait(2000)
                    ClearPedTasks(ped)
                    Citizen.Wait(2000)
                    DeleteObject(bomba)
                    Citizen.Wait(9000)
                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("FP:BankRobbery:ChangeDoorState", 1, false)
                    CurrentStep = 2;
                else
                    vRP.notify({notify, "error"})
                end 
            end)
        end,
    },
    {
        coords = vector3(262.35, 223.00, 107.05),
        text = "[~b~E~w~] Hack Security Panel",
        EventStep = 2,
        Event = function()
            RVUtils.CanHackTerminal({}, function(canHack, notify)
                if canHack then
                    RequestModel("p_ld_id_card_01")
                    while not HasModelLoaded("p_ld_id_card_01") do
                        Citizen.Wait(1)
                    end
                    local ped = PlayerPedId()
        
                    Citizen.Wait(100)
                    local pedco = GetEntityCoords(PlayerPedId())
                    local IdProp = CreateObject(GetHashKey("p_ld_id_card_01"), pedco, true, true, false)
                    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
                    local panel = GetClosestObjectOfType(pedco[1], pedco[2], pedco[3], 1.0,GetHashKey('hei_prop_hei_securitypanel'), false, false, false)
                
                    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
                    Citizen.Wait(1500)
                    AttachEntityToEntity(IdProp, panel, boneIndex, -0.09, -0.02, -0.08, 270.0, 0.0, 270.0, true, true, false, true, 1, true)
                    FreezeEntityPosition(IdProp)
                    Citizen.Wait(500)
                    ClearPedTasksImmediately(ped)
                    Citizen.Wait(1500)
                    SetNuiFocus(true, true)
                    PasswordMinigame = false;
                    SendNUIMessage({action = "StartPasswordMinigame"})
                    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                     while CurrentStep == 2 and not PasswordMinigame do
                         Wait(1000)
                     end 
                    TriggerServerEvent("FP:BankRobbery:ChangeDoorState", 3, false)
                    CurrentStep = 3;
                else
                    vRP.notify({notify, "error"})
                end
            end)

        end,
    },
    {
        coords = vector3(253.00,228.40,102.20),
        text = "[~b~E~w~] Hack Security Panel",
        EventStep = 3,
        Event = function()
            RVUtils.CanHackTerminal({}, function(canHack, notify)
                if canHack then
                    RequestModel("p_ld_id_card_01")
                    while not HasModelLoaded("p_ld_id_card_01") do
                        Citizen.Wait(1)
                    end
                    local ped = PlayerPedId()
        
                    Citizen.Wait(100)
                    local pedco = GetEntityCoords(PlayerPedId())
                    local IdProp = CreateObject(GetHashKey("p_ld_id_card_01"), pedco, true, true, false)
                    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
                    local panel = GetClosestObjectOfType(pedco[1], pedco[2], pedco[3], 1.0,GetHashKey('hei_prop_hei_securitypanel'), false, false, false)
                
                    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
                    Citizen.Wait(1500)
                    AttachEntityToEntity(IdProp, panel, boneIndex, -0.09, -0.02, -0.08, 270.0, 0.0, 270.0, true, true, false, true, 1, true)
                    FreezeEntityPosition(IdProp)
                    Citizen.Wait(500)
                    ClearPedTasksImmediately(ped)
                    Citizen.Wait(1500)
                    MinigamesAttempt = 0;
                    Minigame = false
                    SetNuiFocus(true, true);
                    SendNUIMessage({action = "StartMinigame"})
                    while CurrentStep == 3 and not Minigame do
                        Wait(1000)
                    end
                    TriggerServerEvent("FP:BankRobbery:SV:SpawnProps")
                    TriggerServerEvent("FP:BankRobbery:SV:StartLooting")
                    CurrentStep = 4;
                else
                    vRP.notify({notify, "error"})
                end
            end)

        end,
    },{
        coords = vector3(252.95, 220.70,101.76),
        text = "[~b~E~w~] Planteaza Bomba Termica",
        EventStep = 4,
        Event = function()
            local loc = vector3(252.95, 220.70,101.76)
            local heading = 160
            local rotplus = 170.0
            local ptfx = vector3(252.985, 221.70, 101.72)
            local oldmodel = "hei_v_ilev_bk_safegate_pris"
            local newmodel = "hei_v_ilev_bk_safegate_molten"

            RVUtils.CanPlantTermicBomb({}, function(canPlant, notify)
                if canPlant then
                    vRP.notify({notify, "info"})
                    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                    RequestModel("hei_p_m_bag_var22_arm_s")
                    RequestNamedPtfxAsset("scr_ornate_heist")
                    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                        Citizen.Wait(50)
                    end
                    local ped = PlayerPedId()
                    SetEntityHeading(ped, heading)
                    Citizen.Wait(100)
                    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
                    local bagscene = NetworkCreateSynchronisedScene(loc[1], loc[2], loc[3], rotx, roty, rotz + rotplus, 2, false, false, 1065353216, 0, 1.3)
                    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), loc[1], loc[2], loc[3],  true,  true, false)
                    SetEntityCollision(bag, false, true)
                    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
                    SetPedComponentVariation(ped, 5, 0, 0, 0)
                    NetworkStartSynchronisedScene(bagscene)
                    Citizen.Wait(1500)
                    local x, y, z = table.unpack(GetEntityCoords(ped))
                    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
                    SetEntityCollision(bomba, false, true)
                    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                    Citizen.Wait(4000)
                    DeleteObject(bag)
                    SetPedComponentVariation(ped, 5, 45, 0, 0)
                    DetachEntity(bomba, 1, 1)
                    FreezeEntityPosition(bomba, true)
                    SetPtfxAssetNextCall("scr_ornate_heist")
                    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    NetworkStopSynchronisedScene(bagscene)
                
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
                    Citizen.Wait(2000)
                    ClearPedTasks(ped)
                    Citizen.Wait(2000)
                    DeleteObject(bomba)
                    Citizen.Wait(9000)
                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("FP:BankRobbery:ChangeDoorState", 4, false)
                    CurrentStep = 5;
                else
                    vRP.notify({notify, "error"})
                end
            end)
        end,
    },
    {
        coords = vector3(261.65, 215.60, 101.76),
        text = "[~b~E~w~] Planteaza Bomba Termica",
        EventStep = 5,
        Event = function()
            local loc = vector3(261.65, 215.60, 101.76)
            local heading = 252
            local rotplus = 270.0
            local ptfx = vector3(261.68, 216.63, 101.75)
            local oldmodel = "hei_v_ilev_bk_safegate_pris"
            local newmodel = "hei_v_ilev_bk_safegate_molten"

            RVUtils.CanPlantTermicBomb({}, function(canPlant, notify)
                if canPlant then
                    vRP.notify({notify, "info"})
                    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                    RequestModel("hei_p_m_bag_var22_arm_s")
                    RequestNamedPtfxAsset("scr_ornate_heist")
                    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                        Citizen.Wait(50)
                    end
                    local ped = PlayerPedId()
                    SetEntityHeading(ped, heading)
                    Citizen.Wait(100)
                    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
                    local bagscene = NetworkCreateSynchronisedScene(loc[1], loc[2], loc[3], rotx, roty, rotz + rotplus, 2, false, false, 1065353216, 0, 1.3)
                    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), loc[1], loc[2], loc[3],  true,  true, false)
                    SetEntityCollision(bag, false, true)
                    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
                    SetPedComponentVariation(ped, 5, 0, 0, 0)
                    NetworkStartSynchronisedScene(bagscene)
                    Citizen.Wait(1500)
                    local x, y, z = table.unpack(GetEntityCoords(ped))
                    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
                    SetEntityCollision(bomba, false, true)
                    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                    Citizen.Wait(4000)
                    DeleteObject(bag)
                    SetPedComponentVariation(ped, 5, 45, 0, 0)
                    DetachEntity(bomba, 1, 1)
                    FreezeEntityPosition(bomba, true)
                    SetPtfxAssetNextCall("scr_ornate_heist")
                    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    NetworkStopSynchronisedScene(bagscene)
                
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
                    Citizen.Wait(2000)
                    ClearPedTasks(ped)
                    Citizen.Wait(2000)
                    DeleteObject(bomba)
                    Citizen.Wait(9000)
                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("FP:BankRobbery:ChangeDoorState", 5, false)
                    CurrentStep = 0;
                else
                    vRP.notify({notify, "error"})
                end
            end)
        end,
    }
}

Citizen.CreateThread(function()
    while true do
        local ticks = 500
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(RobberyEvents) do
            local distance = #(playerCoords - v.coords)
            if distance < 10.0 then

                ticks = 1
                if CurrentStep == v.EventStep then
                    DrawText3D(v.coords[1],v.coords[2], v.coords[3], v.text, 0.40)
                    if distance < 2.5 then
                        if IsControlJustReleased(0, 38) then
                            v.Event()
                        end
                    end
                end
            end
        end

        Citizen.Wait(ticks)
    end
end)


Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(Doorlocked) do
            if #(playerCoords - v.coords) <= 10 then
                local door = GetClosestObjectOfType(v.coords[1], v.coords[2], v.coords[3], 1.0, v.objModel ,false, false, false)
                if door ~= 0 then
                    SetEntityCanBeDamaged(door, false)
                    if not v.locked then
                      NetworkRequestControlOfEntity(door)
                      FreezeEntityPosition(door, false)
                    else
                        local locked, heading = GetStateOfClosestDoorOfType(v.objModel, v.coords[1], v.coords[2],v.coords[3], locked, heading)
                        if heading > -0.02 and heading < 0.02 then
                            NetworkRequestControlOfEntity(door)
                            FreezeEntityPosition(door, true)
                        end
                    end
                end
            end
        end
    end
end)


RegisterNetEvent("FP:BankRobbery:CL:SpawnProps", function()
    for k, v in pairs(Config.PropsToSpawn) do
        RobberyProps[v.grab] = {
            taked = false,
            obj = CreateObject(v.hash, v.coords[1], v.coords[2], v.coords[3], 1, 0, 0),
            coords = v.coords,
            text = v.text
        }

        if v.grab == 3 or v.grab == 4 then
            local heading = GetEntityHeading(RobberyProps[v.grab].obj)
    
            SetEntityHeading(RobberyProps[v.grab].obj, heading + 150)
        end

        SendNUIMessage({
            action = "UpdateActions",
            robberyData = RobberyProps,
        })
    end
end)


RegisterNetEvent("FP:BankRobbery:StartLooting", function(toggle)
    CanLoot = toggle;
    Citizen.CreateThread(function()
        while CanLoot do
            Wait(1)
            local playerCoords = GetEntityCoords(PlayerPedId());

            for k, v in pairs(RobberyProps) do
                if not v.taked then
                    local distance = #(playerCoords - v.coords)
                    if distance < 10.0 then
                        DrawText3D(v.coords[1],v.coords[2], v.coords[3], "[~b~E~w~] Colecteaza", 0.40)
                        if distance < 1.5 then
                            if IsControlJustReleased(0, 38) then
                                v.taked = true
                                TriggerServerEvent("FP:BankRobbery:SV:Loot", k)
                                Loot(k)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent("FP:BankRobbery:ChangeVaultState", function(unlock)
    local obj = GetClosestObjectOfType(253.92,224.56,101.88, 1.0, GetHashKey("v_ilev_bk_vaultdoor") ,false, false, false)
    local count = 0

    if unlock then
        FreezeEntityPosition(obj, false)
        repeat
	        local rotation = GetEntityHeading(obj) - 0.05

            SetEntityHeading(obj, rotation)
            count = count + 1
            Citizen.Wait(10)
        until count == 1100
        FreezeEntityPosition(obj, true)
    else
        FreezeEntityPosition(obj, false)
        repeat
	        local rotation = GetEntityHeading(obj) + 0.05

            SetEntityHeading(obj, rotation)
            count = count + 1
            Citizen.Wait(10)
        until count == 1100
    end
    FreezeEntityPosition(obj, true)
end)

RegisterNetEvent("FP:BankRobbery:UpdateDoors", function(data)
    Doorlocked = data;
end)


local min, sec = 0, 0
RegisterNetEvent("FP:BankRobbery:UpdateTime", function(time)
	min = time

	Citizen.CreateThread(function()
		while min + sec > 0 and not stopTimer do
			Citizen.Wait(1000)
			sec = sec - 1
			if sec < 0 then
				min = min - 1
				sec = 59
			end
            
            SendNUIMessage({
                action = "UpdateTime",
                time = string.format("%02d:%02d",min,sec)
            })
		end
	end)
end)

RegisterNetEvent("FP:BankRobbery:CloseUI", function()
    stopTimer = true;
    SendNUIMessage({
        action = "CloseActions"
    })
end)

RegisterNetEvent("FP:BankRobbery:CL:GAS", function(toggle)
    GasAlert = toggle
    if toggle then
        Citizen.CreateThread(function()
            SetPtfxAssetNextCall("core")
            local Gas = StartNetworkedParticleFxNonLoopedAtCoord("veh_respray_smoke", 262.78, 213.22, 101.68, 0.0, 0.0, 0.0, 0.80, false, false, false, false)
            SetPtfxAssetNextCall("core")
            local Gas2 = StartNetworkedParticleFxNonLoopedAtCoord("veh_respray_smoke", 257.71, 216.64, 101.68, 0.0, 0.0, 0.0, 1.50, false, false, false, false)
            SetPtfxAssetNextCall("core")
            local Gas3 = StartNetworkedParticleFxNonLoopedAtCoord("veh_respray_smoke", 252.71, 218.22, 101.68, 0.0, 0.0, 0.0, 1.50, false, false, false, false)
            Citizen.Wait(20000)
            StopParticleFxLooped(Gas, 0)
            StopParticleFxLooped(Gas2, 0)
            StopParticleFxLooped(Gas3, 0)
        end)
    end
    Citizen.CreateThread(function()
        while GasAlert  do
            Wait(1)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist1 = #(playerCoords - vector3(252.71, 218.22, 101.68))
            local dist2 = #(playerCoords - vector3(262.78, 213.22, 101.68))

            if dist1 <= 5 or dist2 < 6.5 then
                ApplyDamageToPed(PlayerPedId(), 3, false)
                Wait(350)
            end
        end
    end)
end)

RegisterNetEvent("vrp-robbing:showAlert", function(text)
    SendNUIMessage({
        action = "OpenAlert",
        text = text
    })

    TriggerEvent("vRP:playAudio", "burglar", 0.3)
end)

RegisterNetEvent("FP:BankRobbery:ShowUI", function()
    SendNUIMessage({action = "ShowActions"})
end)

RegisterNetEvent("FP:BankRobbery:CL:Loot", function(id)
    RobberyProps[id].taked = true
    SendNUIMessage({
        action = "UpdateActions",
        robberyData = RobberyProps,
    })
end)

RegisterNUICallback("PasswordMinigame", function(data, cb)
    PasswordMinigame = data.result;
    if not data.result then
        MinigamesAttempt = MinigamesAttempt + 1
        if MinigamesAttempt == 1 then
            TriggerServerEvent("vRP:alertThePolice")
        end
    end
    if data.result then
        SendNUIMessage({action = 'ClosePasswordMinigame'})
        SetNuiFocus(false, false)
    end
    cb("ok")
end)

RegisterNUICallback("Minigame", function(data, cb)
    Minigame = data.result;
    MinigamesAttempt = MinigamesAttempt + 1;
    if data.result then
        SendNUIMessage({action = 'CloseMinigame'})
        SetNuiFocus(false, false)
    end
end)