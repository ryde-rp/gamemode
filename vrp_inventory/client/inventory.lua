vRP = Proxy.getInterface("vRP")

RegisterCommand("deschideInventar", function()
    if IsPedFalling(PlayerPedId()) then return end
    
    TriggerServerEvent("ad-inventory:openInventory")
end)

RegisterKeyMapping("deschideInventar", "Deschide inventarul", "keyboard", "i")

RegisterNetEvent('ad-inventory:openInventory', function(inventory, totalWeight, maxWeight, chestData, playerInventory)
    if not vRP.isHandcuffed{} then
        
        SetNuiFocus(true, true)
        TriggerScreenblurFadeIn(1000)

        SendNUIMessage({
            action = "openInventory",
            inventory = inventory,
            totalWeight = math.floor(totalWeight),
            maxWeight = math.floor(maxWeight),
            other = chestData,
            playerData = playerInventory,
            isInVehicle = IsPedInAnyVehicle(PlayerPedId(), false),
        })
    
    end
end)

RegisterNetEvent("ad-inventory:refreshInventory", function(inventory, totalWeight, maxWeight, chestData, playerInventory)
    SendNUIMessage({
        action = "refresh",
        inventory = inventory,
        totalWeight = math.floor(totalWeight),
        maxWeight = math.floor(maxWeight),
        other = chestData,
        playerData = playerInventory,
    })
end)

RegisterNUICallback("GiveItem", function(data, cb)
    TriggerServerEvent("ad-inventory:giveItem", data.item, data.amount)
end)

RegisterNUICallback("DropItem", function(data)
    TriggerServerEvent("ad-inventory:trashItem", data.item, data.label, data.amount)
end)

RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("ad-inventory:useItem", data.item)
end)


-- OTHERS

RegisterNUICallback("storeUserWeapons", function(_, cb)
    TriggerServerEvent("vRP:storeWeapons")
    cb("www.tropicalromania.com")
end)

RegisterNetEvent("ad-inventory:forceClose", function()
    SendNUIMessage{
        action = "close",
    }
end)

RegisterNUICallback("CloseInventory", function(data, cb)
    TriggerScreenblurFadeOut(1000)
    SetNuiFocus(false, false)
    TriggerServerEvent("ad-inventory:closeChest")
end)

RegisterNUICallback("SetInventoryData", function(data, cb)
    if data.frominventory == "other" then
        TriggerServerEvent("ad-inventory:fromChestToPlayer", data.item, tonumber(data.amount), data.isPlayer);
    else
        TriggerServerEvent("ad-inventory:fromPlayerToChest", data.item, tonumber(data.amount), data.isPlayer)
    end
    cb("ok")
end)

RegisterNUICallback("CerePortbagaj", function(data, cb)
    TriggerServerEvent("ad-inventory:CerePortbagaj")
    cb("ok")
end)

RegisterNUICallback("CereTorpedou", function(data, cb)
    TriggerServerEvent("ad-inventory:CereTorpedou")
    cb("ok")
end)

RegisterNUICallback("Perchezitioneaza", function(data, cb)
    TriggerServerEvent("ad-inventory:PerchezitioneazaJucator")
    cb("ok")
end)

RegisterNUICallback("StrangeArmele", function(data, cb)
    TriggerServerEvent("ad-inventory:storeWeapons")
    cb("ok")
end)

RegisterNUICallback("GiveMoney", function(data, cb)
    TriggerServerEvent("ad-inventory:OferaBani")
    cb("ok")
end)