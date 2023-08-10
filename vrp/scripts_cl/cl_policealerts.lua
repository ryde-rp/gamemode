local isCop = false
AddEventHandler("vRP:onFactionChange", function(faction)
    isCop = (faction == "Politia Romana")
end)

local backupCodes = {
    " are o situatie de urgenta ",
    " are nevoie de asistenta cu risc mic",
    " are nevoie de asistenta cu risc mediu",
    " are nevoie de asistenta urgenta",
    " are nevoie de ingrijiri medicale",
}

local codNames = {
    "COD MAXIMA UREGENTA",
    "COD ASISTENTA CU RISC MIC",
    "COD ASISTENTA CU RISC MEDIU",
    "COD ASISTENTA CU RISC URGENTA",
    "COD ASISTENTA MEDICALA URGENTA",
}

local function AddAlertBlip(tcds)
    local blip = AddBlipForCoord(tcds.x, tcds.y, tcds.z)
    local alpha = 250
    SetBlipSprite(blip, 0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, alpha)
    SetBlipAsShortRange(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Focuri de arma")
    EndTextCommandSetBlipName(blip)
    SetTimeout(1000 * 9, function()
        SetBlipSprite(blip, 0)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, 0)
    end)
end

RegisterNetEvent("vRP:showPoliceRequest", function(coords, cod, time, nume, prenume)
    local user = nume .. ' ' .. prenume

    local streetname = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords[1], coords[2], coords[3],Citizen.ResultAsInteger(), Citizen.ResultAsInteger()))
    local streetlabel = GetLabelText(GetNameOfZone(coords[1], coords[2], coords[3]))

    if cod == 3 then
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    elseif cod == 4 then
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    end

    SendNUIMessage({
        act = 'police-alert',
        code = 'BK ' .. cod,
        backupName = codNames[cod],
        location = streetname .. ', ' ..streetlabel,
        text = user..""..backupCodes[cod],
        time = time,
        cop = user,
    })

    SetNewWaypoint(coords[1], coords[2])
end)

local function TryAlerteaza()
    if not isCop then
        if IsPedCurrentWeaponSilenced(PlayerPedId()) then
            local nmath = math.random(1, 4)
            if nmath == 4 then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local hashStrada = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                local nameStrada = GetStreetNameFromHashKey(hashStrada)
                local labelStrada = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
                local data = {}
                data.cod = '10-11'
                data.titlu = 'Focuri de arma'
                data.description = "Au fost sesizate niste focuri de arma in aceasta zona"
                data.street = nameStrada .. ', ' .. labelStrada
                TriggerServerEvent('vRP:registerPoliceAlert', data, playerCoords)
                Wait(5000)
            end
        else
            local vmath = math.random(1, 3)
            if vmath == 2 then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local hashStrada = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                local nameStrada = GetStreetNameFromHashKey(hashStrada)
                local labelStrada = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
                local data = {}
                data.cod = '10-11'
                data.titlu = 'Focuri de arma'
                data.description = "Au fost sesizate niste focuri de arma in aceasta zona"
                data.street = nameStrada .. ', ' .. labelStrada
                TriggerServerEvent('vRP:registerPoliceAlert', data, playerCoords)
                Wait(5000)
            end
        end
    end
end

RegisterNetEvent("vRP:alertPoliceShoot", TryAlerteaza)

RegisterNetEvent('vRP:alertThePolice', function(data, cds)
    local alpha = 150
    local gunshotBlip = AddBlipForRadius(cds.x, cds.y, cds.z, 100.0)

    SetBlipHighDetail(gunshotBlip, true)
    SetBlipColour(gunshotBlip, 1)
    SetBlipAlpha(gunshotBlip, alpha)
    SetBlipAsShortRange(gunshotBlip, true)
    SetNewWaypoint(cds.x, cds.y)
    AddAlertBlip(cds)

    SendNUIMessage({
        act = 'police-alert',
        code = '10-11',
        backupName = "FOCURI DE ARMA",
        location = data.street,
        text = "Au fost sesizate niste focuri de arma in aceasta zona",
        time = "20:00",
        cop = "NECUNOSCUT",
    })

    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
    
    while alpha ~= 0 do
        Citizen.Wait(10 * 4)
        alpha = alpha - 1
        SetBlipAlpha(gunshotBlip, alpha)

        if alpha == 0 then
            RemoveBlip(gunshotBlip)
            return
        end
    end
end)