local sandwichPrice = 10
local waterPrice = 5

RegisterServerEvent("vendingMachines$getSandwich", function()
	local user_id = vRP.getUserId(source)
	
	if vRP.canCarryItem(user_id, "fp_sandvis", 1, true) then
		if vRP.tryPayment(user_id, sandwichPrice, true) then
			vRP.giveInventoryItem(user_id, "fp_sandvis", 1, true)
		end
	end
end)


RegisterServerEvent("vendingMachines$getWater", function()
	local user_id = vRP.getUserId(source)
	
	if vRP.canCarryItem(user_id, "fp_apa", 1, true) then
		if vRP.tryPayment(user_id, waterPrice, true) then
			vRP.giveInventoryItem(user_id, "fp_apa", 1, true)
		end
	end
end)