local gunshopPrices = {
	["body_knuckle"] = 15000,
	["body_bat"] = 17000,
	["body_flashlight"] = 1000,
	["body_knife"] = 12000,
}

function tvRP.purchaseOneGun(item)
	local user_id = vRP.getUserId(source)
	local weapPrice = gunshopPrices[item]

	if weapPrice then

		if vRP.canCarryItem(user_id, item, 1, true) then
			if vRP.tryPayment(user_id, weapPrice, true) then
				vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(weapPrice), "info", false, "fas fa-gun"})
				vRP.giveInventoryItem(user_id, item, 1, true)
			end
		end
	end
end