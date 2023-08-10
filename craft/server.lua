local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "fairplay-craft")

RegisterServerEvent("FairPlay:RequestOpenCraft", function(data)
    local player = source

    if data.onlyMafie then
        local user_id = vRP.getUserId({player})
        local hasUserFaction = vRP.hasUserFaction({user_id})
        if hasUserFaction then
            local theFaction = vRP.getUserFaction({user_id}) 
            local factionType = vRP.getFactionType({theFaction})

            if factionType == "Mafie" or factionType == "Gang" then
                TriggerClientEvent("FairPlay:OpenCraft", player, data)
            else
                vRPclient.notify(player, {"Doar mafiile pot accesa acest crafting!", "error"})
            end
        else
            vRPclient.notify(player, {"Doar mafiile pot accesa acest crafting!", "error"})
        end
    else
        TriggerClientEvent("FairPlay:OpenCraft", player, data)
    end
end)

local function hasItems(user_id, tableID, item)
    local itemNumber = 0
    for k, v in pairs(Config.Crafting[tableID].crafts[item].recipe) do
        if vRP.getInventoryItemAmount({user_id, v[2]}) >= v[3] then
            itemNumber = itemNumber + 1
        end
    end
    return itemNumber >= #Config.Crafting[tableID].crafts[item].recipe
end

local function GetUserItems(user_id, table, item, player)
	TriggerClientEvent("FairPlay:Crafting:clientAnim", player, Config.Crafting[table].crafts[item].time, item)
	SetTimeout(Config.Crafting[table].crafts[item].time, function()
		vRP.giveInventoryItem({user_id, item, Config.Crafting[table].crafts[item].amount,true})
        local itemName = vRP.getItemName({item})
        vRP.createLog({user_id, "A craftat x"..Config.Crafting[table].crafts[item].amount.." "..itemName..".", "Items", "Craft-Item", "fa-solid fa-bolt", 0, "info"})
	end)
    for k, v in pairs(Config.Crafting[table].crafts[item].recipe) do
        vRP.tryGetInventoryItem({user_id, v[2], v[3], true})
    end
end

RegisterServerEvent("FairPlay:CraftItem", function(table, item)
    local player = source
    local user_id = vRP.getUserId({player})

    if hasItems(user_id, table, item) then
		GetUserItems(user_id, table, item, player)
	else
		vRPclient.notify(player, {"Nu ai itemele necesare!", "error"})
    end
end)

