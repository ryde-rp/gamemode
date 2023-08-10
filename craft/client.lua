local vRP = Proxy.getInterface("vRP") -- vRPclient

local canCraft = true
local menuActive = false;

Citizen.CreateThread(function()
    while true do
        local ticks = 1024

        if canCraft then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local shahmaut = false
            for k, v in pairs(Config.Crafting) do
                local distance = #(playerCoords - v.coordinates)

                if distance <= 15 then
                    ticks = 1
                    DrawMarker(2, v.coordinates[1], v.coordinates[2], v.coordinates[3] + 0.10, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 128, 187, 250, 125, true, true)

                    if distance <= 2.5 then
                        shahmaut = true
                         if not menuActive then
                             menuActive = true
                             TriggerEvent("vRP:requestKey", {key = "E", text = "Deschide meniul de crafting"})
                         end
                         if IsControlJustPressed(0, 51) then
                             TriggerEvent("vRP:requestKey", false)
                             TriggerServerEvent("FairPlay:RequestOpenCraft", {tableName = v.tableName, crafts = v.crafts, tableID = k, onlyMafie = v.onlyMafie})
                         end
                    end
                end   
            end
            if not shahmaut then
                if menuActive then
                    TriggerEvent("vRP:requestKey", false)
                     menuActive = false
                end
            end
        end

        Citizen.Wait(ticks)
    end
end)

CreateThread(function()
	vRP.createPed({"PRELUCRARE_NPC", {
		position = vec3(-511.40902709961,5305.5825195313,80.23974609375),
		rotation = 158.740,
		model = "a_m_m_hillbilly_01",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 0.0,
		
		name = "Mihai Viziru",
		description = "Manager magazin.",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
            -- {item = "Vinde coliere facute din perle.", post = "fp-scafandru:sellColiere", args={"server"}},
		},
	}})
end)

CreateThread(function()
	vRP.createPed({"ARMEALBE", {
		position = vec3(3064.5329589844,2207.5617675781,3.7968029975891),
		rotation = 260.787,
		model = "a_m_m_og_boss_01",
		freeze = true,
		scenario = {
			-- name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 0.0,
		
		name = "Mihai Viziru",
		description = "Manager magazin.",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
            -- {item = "Vinde coliere facute din perle.", post = "fp-scafandru:sellColiere", args={"server"}},
		},
	}})
end)

RegisterNetEvent("FairPlay:OpenCraft", function(data, items)
    SendNUIMessage({
        action = "openCraft",
        name = data.tableName,
        craft = data.crafts,
        wb = data.tableID
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("craft", function(data)
    TriggerServerEvent("FairPlay:CraftItem", data.table, data.itemID)
end)

local function playAnim(animDict, anim, bINSpeed, bOUTSpeed, time, flag, PBRate, lX, lY, lZ)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, anim, bINSpeed, bOUTSpeed, time, flag, PBRate, lX, lY, lZ)
end

RegisterNetEvent("FairPlay:Crafting:clientAnim", function(timp, itemID)
    canCraft = false
    playAnim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, 8.0, -1, 49, 0, 0, 0, 0)
    FreezeEntityPosition(PlayerPedId(), true)
    exports.progressbars:Custom({
        Duration = timp,
        Label = "Craftezi..",
        Animation = {},
        DisableControls = {
            Mouse = false,
            Player = true,
            Vehicle = true
        }})
    SetTimeout(timp, function()
        ClearPedSecondaryTask(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        canCraft = true
    end)
end)


RegisterNUICallback("sideCraft", function(data)
    SendNUIMessage({
        action = "openSideCraft",
        itemId = Config.Crafting[data.table].crafts[data.item].item,
        itemName = Config.Crafting[data.table].crafts[data.item].itemName,
        itemAmount = Config.Crafting[data.table].crafts[data.item].amount,
        time = Config.Crafting[data.table].crafts[data.item].time,
        recipe = Config.Crafting[data.table].crafts[data.item].recipe,
    })
end)

