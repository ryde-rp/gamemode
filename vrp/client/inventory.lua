local inventoryItems, inventorySlots, inventoryMaxWeight, inventoryTotalWeight = {}, 6, 20.0, 0.0

RegisterNetEvent("fp-inventory:UpdateClientInventory", function(items, maxWeight, totalWeight)
    inventoryItems = items
    inventoryMaxWeight = maxWeight
    inventoryTotalWeight = totalWeight
end)