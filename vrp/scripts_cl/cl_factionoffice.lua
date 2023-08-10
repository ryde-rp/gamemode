local factionData = false
local fHealPack = false

local healCoordsX, healCoordsY, healCoordsZ = 0, 0, 0

local function loadModel(modelNeeded)
    RequestModel(modelNeeded)
    while not HasModelLoaded(modelNeeded) do
      RequestModel(modelNeeded)
      Citizen.Wait(1)
    end
end

local function buildFactionLocation()
    local chestX, chestY, chestZ = factionData.chestPos[1], factionData.chestPos[2], factionData.chestPos[3]

    local factionChestVec = vec3(chestX, chestY, chestZ)
    local factionShopVec = vec3(0,0,0)

    if fHealPack then
        factionShopVec = vec3(healCoordsX, healCoordsY, healCoordsZ)

        local fHealBlip = AddBlipForCoord(healCoordsX, healCoordsY, healCoordsZ)
        SetBlipSprite(fHealBlip, 501)
        SetBlipScale(fHealBlip, 0.6)
        SetBlipColour(fHealBlip, 43)
        SetBlipAsShortRange(fHealBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Echipament factiune")
        EndTextCommandSetBlipName(fHealBlip)

        factionData.fHealBlip = fHealBlip
    end

    local fChestBlip = AddBlipForCoord(chestX, chestY, chestZ)
    SetBlipSprite(fChestBlip, 568)
    SetBlipScale(fChestBlip, 0.6)
    SetBlipColour(fChestBlip, 6)
    SetBlipAsShortRange(fChestBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Cufarul factiunii")
    EndTextCommandSetBlipName(fChestBlip)

    factionData.fChestBlip = fChestBlip

    while factionData do
        local scriptTicks = 1500
        local factionChestDistance = #(factionChestVec - pedPos)
        if fHealPack then
            local healShopDistance = #(factionShopVec - pedPos)
            if healShopDistance <= 4.5 then
                scriptTicks = 1

                DrawMarker(20, healCoordsX, healCoordsY, healCoordsZ-0.40, 0, 0, 0, 0,0, 0, 0.65, 0.40, 0.40, 81, 158, 199, 145, 0, 0, true, true)
                DrawText3D(healCoordsX, healCoordsY, healCoordsZ-0.05, "~b~E ~w~- Echipament factiune", 0.85)
                
                if healShopDistance <= 2.5 then
                    if IsControlJustReleased(0, 51) then
                        TriggerServerEvent("vRP:openFactionStore", "heal")
                    end
                end
            end
        end

        if factionChestDistance <= 4.5 then
            scriptTicks = 1

            DrawMarker(20, chestX, chestY, chestZ-0.40, 0, 0, 0, 0,0, 0, 0.65, 0.40, 0.40, 81, 158, 199, 145, 0, 0, true, true)
            DrawText3D(chestX, chestY, chestZ-0.05, "~b~E ~w~- Foloseste cufarul", 0.85)
            
            if factionChestDistance <= 2.5 then
                if IsControlJustReleased(0, 51) then
                    TriggerServerEvent("vRP:openFactionChest", "Marabunta Grande")
                end
            end
        end
        Citizen.Wait(scriptTicks)
    end
end

RegisterNetEvent("vRP:setFactionOffice", function(fData)
    if not fData then
        return false
    end
    
    factionData = fData
    if factionData then
        fHealPack = factionData.healPack

        if fHealPack then
            healCoordsX, healCoordsY, healCoordsZ = factionData.healPos[1], factionData.healPos[2], factionData.healPos[3]
        end

        Citizen.CreateThread(buildFactionLocation)
    end
end)

RegisterNetEvent("vRP:unsetFactionOffice", function()
    if factionData then
        if factionData.fHealBlip then
            RemoveBlip(factionData.fHealBlip)
        end

        if factionData.fChestBlip then
            RemoveBlip(factionData.fChestBlip)
        end

        factionData = false
    end
end)

RegisterNetEvent("vRP:openFactionStore", function(theStore, theItems, theFaction)
    if theStore == "weapon" then
        SendNUIMessage({
            act = "interface",
            target = "factionStore",

            type = "weapons",
            items = theItems,
            faction = theFaction,
        })
    else
        SendNUIMessage({
            act = "interface",
            target = "factionStore",
            
            type = "heal",
            items = theItems,
            faction = theFaction,
        })
    end
    
    TriggerEvent("vRP:interfaceFocus", true)
end)

RegisterNUICallback("fs$buyItem", function(data, cb)
    if data.item then
        vRPserver.buyFactionItem{data.item, data.amount, data.price}
    end

    cb("discord.gg/ryde")
end)

CreateThread(function()
    local weaponShop = vec3(5061.939453125,-4591.1743164063,2.8736238479614)
	tvRP.createPed("vrp_fWeaponShop", {
		position = weaponShop,
		rotation = 245,
		model = "g_m_y_mexgoon_03",
		freeze = true,
		scenario = {
            anim = {
                dict = "anim@amb@nightclub@peds@",
                name = "rcmme_amanda1_stand_loop_cop",
            }
		},
		minDist = 2.5,
		
		name = "Danu Neamu",
		description = "Afacerist: Cayo Perico",
		text = "Te salut bos, iti dau un parfum sa miroasa frumos?",
		fields = {
			{item = "Vreau sa cumpar arme.", post = "vRP:openFactionStore", args = {"weapon"}}
		},
	})

    -- Faction Duty
    local policeDuty = vec3(487.32168579102,-997.09167480469,30.689651489258)
    local smurdDuty = vec3(-818.64343261719,-1243.8614501953,7.3374261856079)

    RegisterNetEvent("fp-factions:switchDuty")
    AddEventHandler("fp-factions:switchDuty", function()
        vRPserver.setFactionDuty{}
    end)

    tvRP.createPed("policeDuty", {
        position = policeDuty,
        rotation = 90,
        model = "u_m_y_chip",
        freeze = true,
        scenario = {
            name = "WORLD_HUMAN_CLIPBOARD_FACILITY",
        },
        minDist = 2.5,
        
        name = "Valeriu Lungu",
        description = "Departamentul de Politie L.S.",
        text = "Cu ce ti-as putea fi de folos?",
        fields = {
            {item = "Vreau sa ma pun On/Off Duty.", post = "fp-factions:switchDuty"}
        },
    })

    tvRP.createPed("smurdDuty", {
        position = smurdDuty,
        rotation = 0,
        model = "u_m_y_chip",
        freeze = true,
        scenario = {
            name = "WORLD_HUMAN_CLIPBOARD_FACILITY",
        },
        minDist = 2.5,
        key = 47,
        
        name = "Mihai Kobrak",
        description = "Centrul medical Viceroy",
        text = "Cu ce ti-as putea fi de folos?",
        fields = {
            {item = "Vreau sa ma pun On/Off Duty.", post = "fp-factions:switchDuty"}
        },
    })
end)