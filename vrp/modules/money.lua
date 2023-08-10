local flowLimit = 500000000

local playerMoney = {}

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

function vRP.getMoney(user_id)
	if(playerMoney[user_id])then
		return playerMoney[user_id].wallet
	else
		return 0
	end
end

function vRP.getUserBankAccount(user_id)
	local document = {
		bankMoney = vRP.getBankMoney(user_id),
		walletMoney = vRP.getMoney(user_id),
	}
	
	return document
end

function vRP.setCoins(user_id,value)
	if(playerMoney[user_id])then
		playerMoney[user_id].xzCoins = value
	end

	exports.oxmysql:execute("UPDATE users SET premiumCoins = @premiumCoins WHERE id = @id",{
		['@id'] = user_id,
		['@premiumCoins'] = value
	})

	local source = vRP.getUserSource(user_id)
	if source then
  		TriggerClientEvent("fp-hud:setData", source, vRP.getMoney(user_id), vRP.getBankMoney(user_id), value)
	end
end

function vRP.tryCoinsPayment(user_id, amount, notif)
	local xzs = tonumber(vRP.getXZCoins(user_id))
	if tonumber(amount) <= xzs and tonumber(amount) > 0 then
		vRP.setCoins(user_id, xzs-amount)
		if notif then
			vRPclient.notify(vRP.getUserSource(user_id), {"Ai platit "..amount.." Coins", "success"})
		end
		return true
	else
		if notif then
			vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai "..amount.." Coins", "error"})
		end
		return false
	end
end

function vRP.getCoins(user_id)
	if(playerMoney[user_id])then
		return playerMoney[user_id].xzCoins
	else
		return 0
	end
end

function vRP.getXZCoins(user_id)
	return vRP.getCoins(user_id)
end

function vRP.detectMoneyExploit(user_id, value)
	if tonumber(value) > 6000000000 then
		if vRP.getUserHoursPlayed(user_id) < 2 then
			return false
		end
	end
	return false
end

function vRP.setMoney(user_id, value)
	if tonumber(value) >= 0 then
		if(playerMoney[user_id])then
			playerMoney[user_id].wallet = value
		end
		
		if vRP.detectMoneyExploit(user_id, value) then
			vRP.banPlayer(0, user_id, -1, 'Money Exploit Detected [vRPmoney:tLimitReached]')
		end

		exports.oxmysql:execute("UPDATE users SET walletMoney = @walletMoney WHERE id = @id",{
			['@id'] = user_id,
			['@walletMoney'] = value
		})

	    local source = vRP.getUserSource(user_id)
	    if source then
	    	TriggerClientEvent("fp-hud:setData", source, value, vRP.getBankMoney(user_id), vRP.getXZCoins(user_id))
	    end
 	end
end

function vRP.tryTransfer(user_id, to_id, amount)
	if not user_id or not to_id then return end
	local to_src = vRP.getUserSource(to_id)
	local src = vRP.getUserSource(user_id)
	if not to_src then return vRPclient.notify(src, {"Destinatarul nu este online pe server in acest moment!", "error"}) end
	amount = tonumber(amount)
	if vRP.tryBankPayment(user_id, amount, true) then
		vRP.logMoney(user_id, to_id, amount, "transfer")
		vRP.giveBankMoney(to_id, amount)
		return true
	else
		return false
	end
end

function vRP.tryPayment(user_id,amount,notify)
	if amount then
		if amount == 0 then return true end
		amount = math.floor(amount)
		local money = vRP.getMoney(user_id)
		if (money >= amount) and (amount >= 0) then
			vRP.setMoney(user_id,money-amount)
			return true
		else
			if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai $"..vRP.formatMoney(amount), "error"}) end
			return false
		end
	end
end

function vRP.hasPlayerRestante(user_id)
	local money = vRP.getBankMoney(user_id)
	if money < 0 then
		local player = vRP.getUserSource(user_id)
		vRPclient.notify(player, {"Ai restante, trebuie sa le platesti inainte sa poti cumpara ceva!", "error"})
		return true
	end
	return false
end

function vRP.tryBankPayment(user_id,amount,notify, noLimit)
	local money = vRP.getBankMoney(user_id)
	amount = math.floor(amount)
	
	if amount == 0 then return true end

	if noLimit then
		vRP.setBankMoney(user_id, money - amount)
		return true
	else
		if (money >= amount) and (amount >= 0) then
			vRP.setBankMoney(user_id,money-amount)
			return true
		else
			if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai $"..vRP.formatMoney(amount), "error"}) end
			return false
		end
	end
end

local flowStack = {}

local function checkFlowStack(forced)
	if #flowStack >= 20 or forced then
		exports.oxmysql:execute("INSERT INTO moneyFlow (flowStack) VALUES(@flowStack)",{['@flowStack'] = json.encode(flowStack)})
		flowStack = {}
	end
end

function vRP.giveMoney(user_id,amount,from)
  local money = vRP.getMoney(user_id)
  if (tonumber(amount) or 0) < 0 then amount = 0 end

  amount = math.floor(tonumber(amount))
  
  if from then
		if type(from) == "string" then
			if tonumber(amount) >= flowLimit then
				table.insert(flowStack, {user_id = user_id, amount = amount, from = from})
				checkFlowStack()
			end
		end
  end
  
  vRP.setMoney(user_id,money+amount)
end

function vRP.giveCoins(user_id, amount, notif)
  local xzCoins = vRP.getXZCoins(user_id)
  if notif then
  	vRPclient.notify(vRP.getUserSource(user_id), {"Ai primit "..amount.." Coins"})
  end
  vRP.setCoins(user_id,xzCoins+amount)
end

function vRP.getBankMoney(user_id)
	if(playerMoney[user_id])then
		return playerMoney[user_id].bank
	else
		return 0
	end
end

function vRP.setBankMoney(user_id,value)
	if (tonumber(value) or 0) >= 0 then
		if(playerMoney[user_id])then
			playerMoney[user_id].bank = value
		end

		exports.oxmysql:execute("UPDATE users SET bankMoney = @bankMoney WHERE id = @id",{
			['@id'] = user_id,
			['@bankMoney'] = value
		})

	    local source = vRP.getUserSource(user_id)
	    if source then
	    	TriggerClientEvent("fp-hud:setData", source, vRP.getMoney(user_id), value, vRP.getXZCoins(user_id))
	    end
	end
end

function vRP.giveBankMoney(user_id,amount,from)
  if amount > 0 then

  	amount = math.floor(amount)

  	if from then
		if amount >= flowLimit then
			table.insert(flowStack, {user_id = user_id, amount = amount, from = from})
			checkFlowStack()
		end
	end

    local money = vRP.getBankMoney(user_id)
    vRP.setBankMoney(user_id,money+amount)
  end
end

function vRP.tryWithdraw(user_id,amount,tax)
  local money = vRP.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    vRP.setBankMoney(user_id,money-amount)
    
    if tax then
    	vRP.giveMoney(user_id,amount)
    else
    	vRP.giveMoney(user_id,amount)
    end

    vRP.logMoney(user_id, user_id, amount, "withdraw")
    return true
  else
    return false
  end
end


function vRP.tryWithdraw(user_id, amount, tax)
	if amount < 0 then return false end;
	if tax then
		local taxAmount = math.floor(amount * tax / 100)
		if vRP.getUserVipRank(user_id) == 2 then
			taxAmount = math.floor(taxAmount * 50 / 100)
		elseif vRP.getUserVipRank(user_id) == 3 then
			taxAmount = 0
		end
		local extractAmount = amount + taxAmount

		local money = vRP.getBankMoney(user_id)
		if money >= extractAmount then
			vRP.setBankMoney(user_id, money - extractAmount)
			vRP.giveMoney(user_id, amount)
			vRP.logMoney(user_id, user_id, amount, "withdraw")
			return true
		else
			return false
		end
	else
		local money = vRP.getBankMoney(user_id)
		if money >= amount then
			vRP.setBankMoney(user_id, money - amount)
			vRP.giveMoney(user_id, amount)
			vRP.logMoney(user_id, user_id, amount, "withdraw")
			return true
		else
			return false
		end
	end
end

function vRP.tryDeposit(user_id,amount)
  if amount > 0 and vRP.tryPayment(user_id,amount) then
    vRP.giveBankMoney(user_id,amount)
    vRP.logMoney(user_id, user_id, amount, "deposit")
    return true
  else
    return false
  end
end

function vRP.tryFullPayment(user_id, amount, notify)
  local money = vRP.getMoney(user_id)
  if amount then
	  if money >= amount and (amount >= 0) then
	    return vRP.tryPayment(user_id, amount, notify)
	  else
	    if vRP.tryWithdraw(user_id, amount-money) then
	      return vRP.tryPayment(user_id, amount, notify)
	    end
	  end
  end

  return false
end

function vRP.tryMurdarPayment(user_id, amount)
	local murdari = vRP.getInventoryItemAmount(user_id, "dirty_money")
	if murdari >= amount then
		return vRP.tryGetInventoryItem(user_id,"dirty_money",amount,true)
	elseif murdari > 0 then
		vRP.tryGetInventoryItem(user_id,"dirty_money",murdari,true)
		return vRP.tryFullPayment(user_id, amount-murdari)
	else
		return vRP.tryFullPayment(user_id, amount)
	end

	return false
end

local econLogs = {}

local function uploadEconomyLogs(forced)
	if #econLogs >= 20 or forced then
		exports.oxmysql:execute("INSERT INTO moneyLogs (econLogs) VALUES(@econLogs)",{['@econLogs'] = json.encode(econLogs)})
		econLogs = {}
	end
end

function vRP.logMoney(accountFrom, accountTo, amount, lType)
	table.insert(econLogs, {fromAccount = accountFrom, toAccount = accountTo, amount = amount, time = os.time(), type = lType})
	uploadEconomyLogs()
end

RegisterCommand("economylogs", function(src)
	uploadEconomyLogs(true)
	checkFlowStack(true)
end)

AddEventHandler("vRP:playerJoin",function(user_id, source, name)
	local rows = exports.oxmysql:querySync("SELECT bankMoney, walletMoney, premiumCoins FROM users WHERE id = @id", {['@id'] = user_id})
	if #rows > 0 then
		playerMoney[user_id] = {bank = rows[1].bankMoney, wallet = rows[1].walletMoney, xzCoins = rows[1].premiumCoins}
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source)
	Citizen.Wait(5500)
	TriggerClientEvent("fp-hud:setData", source, vRP.getMoney(user_id), vRP.getBankMoney(user_id), vRP.getXZCoins(user_id))
end)

AddEventHandler("vRP:playerLeave",function(user_id,source)
	playerMoney[user_id] = nil
end)

function tvRP.tryPayment(ammount)
	local amm = tonumber(ammount)
	if amm then
		local player = source
		local user_id = vRP.getUserId(player)

		if vRP.getMoney(user_id) - amm >= 0 then
			vRP.tryPayment(user_id, amm)
			return true
		end
	end
	return false
end

RegisterServerEvent("fp-inventory:OferaBani", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		vRPclient.getNearestPlayer(player, {2}, function(nPlayer)
			if nPlayer then
				vRP.prompt(player, "GIVE MONEY", {
					{field = "amount", title = "SUMA OFERITA", number = true},
				  }, function(player,res)
					local amount = res["amount"]

					if amount then
						local nUser = vRP.getUserId(nPlayer)
						
						if nUser then
							if vRP.tryPayment(user_id, amount, true) then
								if vRP.detectMoneyExploit(user_id, amount) then
									return vRP.banPlayer(0, user_id, -1, 'Money Exploit Detected [vRP:gMaxMoney]')
								end

								vRP.giveMoney(nUser, amount);
								--- General Money Logs


								vRPclient.notify(nPlayer, {("Ai primit $%s"):format(vRP.formatMoney(amount))})
								vRPclient.notify(player, {("Ai oferit $%s"):format(vRP.formatMoney(amount))})
							end
						end
					end
				end)
			else
				vRPclient.notify(player, {"Niciun jucator in preajma!", "error"})
			end
		end)
	end
end)

RegisterCommand("coins", function(src)
	if src == 0 then return end

	local user_id = vRP.getUserId(src)
	local userCoins = vRP.getXZCoins(user_id)

	vRPclient.notify(src, {"Acum detii "..userCoins.." rydeCoins!"})
	vRPclient.sendInfo(src, {"^7Poti achizitiona ^5rydeCoins ^7de pe shopul nostru!\nPentru a accesa shopul foloseste: ^5discord.gg/ryde"})
end)

function tvRP.getMoney()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		return vRP.getMoney(user_id)
	end
	return 0
end

function tvRP.getBankMoney()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		return vRP.getBankMoney(user_id)
	end
	return 0
end

tvRP.getPlayerBankMoney = tvRP.getBankMoney