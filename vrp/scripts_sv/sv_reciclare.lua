RegisterServerEvent("fp-garbage:recicleazaGunoaie", function()
	local user_id = vRP.getUserId(source)
	local peturiPlastic = vRP.getInventoryItemAmount(user_id, "petdeplastic")
	local conserveStricate = vRP.getInventoryItemAmount(user_id, "conserva")
	local totalWin = 0

	if peturiPlastic > 0 then
		if vRP.tryGetInventoryItem(user_id, "petdeplastic", peturiPlastic, true) then
			totalWin = totalWin + (peturiPlastic * 35)
		end
	end

	if conserveStricate > 0 then
		if vRP.tryGetInventoryItem(user_id, "conserva", conserveStricate, true) then
			totalWin = totalWin + (conserveStricate * 35)
		end
	end

	if totalWin > 0 then
		vRP.giveMoney(user_id, totalWin, "reciclarePeturi")
		vRPclient.notify(source, {"💴 Ai castigat $"..vRP.formatMoney(totalWin)})
	else
		vRPclient.notify(source, {"Nu ai gunoaie de reciclat!", "error", false, "fas fa-trash"})
	end
end)