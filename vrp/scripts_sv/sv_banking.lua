
function tvRP.tryBankDeposit(amount)
	local user_id = vRP.getUserId(source)

	if amount > 0 then
		local doneOne = vRP.tryDeposit(user_id,amount)

		if doneOne then
			return {1, "Ai depozitat $"..vRP.formatMoney(amount).." in contul tau bancar."}
		end

		return {2, "Nu ai $"..vRP.formatMoney(amount).." in buzunar."}
	end
end

function tvRP.tryBankWithdraw(amount)
	local user_id = vRP.getUserId(source)

	if amount > 0 then
		local doneOne = vRP.tryWithdraw(user_id,amount,0)

		if doneOne then
			return {1, "Ai retras $"..vRP.formatMoney(amount).." din balanta contului tau."}
		end

		return {2, "Nu ai $"..vRP.formatMoney(amount).." in contul tau bancar."}
	end
end

function tvRP.tryFactionDeposit(amount)
	local player = source
	local user_id = vRP.getUserId(player)

	local userFaction = vRP.getUserFaction(user_id)

	if amount > 0 then
		if vRP.tryPayment(user_id,amount) then
			local done = vRP.depositFactionBudget(userFaction, amount)
			if done then

				return {1, "Ai depozitat $"..vRP.formatMoney(amount).." in bugetul factiuni tale."}
			end
		else
			return {2, "Nu ai $"..vRP.formatMoney(amount).." in buzunar."}
		end
	end
end

function tvRP.tryFactionWithdraw(amount)
	local player = source
	local user_id = vRP.getUserId(player)

	local userFaction = vRP.getUserFaction(user_id)

	if amount > 0 then
		local done = vRP.withdrawFactionBudget(userFaction, user_id, amount)

		if done then 
			return {1, "Ai retras $"..vRP.formatMoney(amount).." din balanta bugetului factiunii."}
		end

		return {2, "Nu ai $"..vRP.formatMoney(amount).." in bugetul factiunii tale."}
	end
end

local exchangeRewards = {
	[5] = 25000,
	[10] = 50000,
	[20] = 100000,
	[40] = 300000,
	[80] = 1000000,
}

function tvRP.exchangeCoins(amount)
	local user_id = vRP.getUserId(source)

	if amount > 0 then

		local rewardMoney = exchangeRewards[amount]
		if not rewardMoney then
			return {2, "Schimbul este inexistent si nu poate fi efectuat."}
		end

		local doneOne = vRP.tryCoinsPayment(user_id, amount, false)

		if doneOne then
			vRP.giveBankMoney(user_id, rewardMoney)
			return {1, "Ai schimbat "..amount.." rydeCoins in $"..vRP.formatMoney(rewardMoney)}
		end

		return {2, "Nu detii "..amount.." rydeCoins pentru a schimba in bani."}
	end
end

function tvRP.tryBankTransfer(iban, amount)
	local user_id = vRP.getUserId(source)
	amount = tonumber(amount)

	if amount > 0 then

		if not user_id or not iban then return end
		local to_src = vRP.getUserByIban(iban)

		if to_src then
			local to_id = vRP.getUserId(to_src)

			if to_id then
			
				if vRP.tryBankPayment(user_id, amount, true) then
					vRP.giveBankMoney(to_id, amount)
					return {1, "Ai transferat suma de $"..vRP.formatMoney(amount).." contului cu IBAN "..iban}
				else
					return {2, "Nu ai $"..vRP.formatMoney(amount).." in contul tau bancar."}
				end

			else
				return {2, "Nu a fost gasita nici o persoana cu IBAN-ul "..iban.." in baza de date a bancii."}
			end
		else
			return {2, "Nu a fost gasita nici o persoana cu IBAN-ul "..iban.." in baza de date a bancii."}
		end
	end
end

function tvRP.getFactionBudget()
	local player = source
	local user_id = vRP.getUserId(player)
	local userFaction = vRP.getUserFaction(user_id)
	return vRP.getFactionBudget(userFaction)
end

function tvRP.getBankingData()
	local user_id = vRP.getUserId(source)
	local userIdentity = vRP.getIdentity(user_id) or {firstname = "Nume", name = "Prenume"}
	local budget = 0;
	local factionLeader = false;

	local hasFaction = vRP.hasUserFaction(user_id)
	if hasFaction then
		factionLeader = (vRP.isFactionLeader(user_id) or vRP.isFactionCoLeader(user_id))
		local userFaction = vRP.getUserFaction(user_id)
		budget = vRP.getFactionBudget(userFaction)
	end
	
	return {
		identity = {userIdentity.firstname.." "..userIdentity.name, vRP.getUserIban(user_id) or 0},
		money = vRP.getBankMoney(user_id),
		faction = hasFaction,
		factionLeader = factionLeader,
		budget = vRP.formatMoney(budget)
	}
end



RegisterCommand('newcomer', function(source, args)
	local src = source
	local user_id = vRP.getUserId(src)

	local result = exports.oxmysql:executeSync("SELECT * FROM cmdinfo")
	local result2 = exports.oxmysql:executeSync('SELECT * FROM users WHERE id = ?', {user_id})
	if result[1].uses <= 100 and result2[1].newcomer == 1 then
		vRPclient.notify(source, {"Ai primit un Audi Q4", "info", false, "fas fa-warehouse"})

			local carPlate = "LS 69APX"
			carPlate = vRP.generatePlateNumber()
		  
			local newVehicle = {
                user_id = user_id,
                vehicle = 'aaq4',
                vtype = 'ds',
				name = "Audi Q4",
				carPlate = carPlate,
                state = 1,
			}

			if category == "premium" then
				newVehicle.premium = true
			end

			local uses = result[1].uses + 1
			exports.oxmysql:execute("UPDATE cmdinfo SET uses = ? WHERE id = ?", {uses, 1})
			exports.oxmysql:execute("UPDATE users SET newcomer = ? WHERE id = ?", {0, user_id})

			exports.oxmysql:execute("INSERT INTO userVehicles (user_id,vehicle,vtype,name,carPlate,state) VALUES(@user_id,@vehicle,@vtype,@name,@carPlate,@state)",{
				['@user_id'] = newVehicle.user_id,
				['@vehicle'] = newVehicle.vehicle,
				['@vtype'] = newVehicle.vtype,
				['@name'] = newVehicle.name,
				['@carPlate'] = newVehicle.carPlate,
				['@state'] = newVehicle.state
			})
            vRP.addCacheVehicle(user_id, newVehicle)
	end
end)