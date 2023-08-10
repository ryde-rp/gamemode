local Vehicles = module("cfg/cars")

local cfg = {
	vippaycheck = { -- [vipLevel] = payday
		[1] = 1500000,
		[2] = 3500000,
		[3] = 6500000,
	},
	paydayDuration = 1800 -- secunde
}

local function GivePayday(user_id)
	local totalPayday = 0;

	if vRP.hasUserFaction(user_id) then
		local theFaction = vRP.getUserFaction(user_id) or ""
		local theRank = vRP.getFactionRank(user_id) or ""
		local thePay = vRP.getFactionRankSalary(theFaction, theRank) or 0
		local factionPayday = 0;

		if thePay > 0 then
			factionPayday = thePay
		
			if not vRP.isUserFactionDuty(user_id) then
				factionPayday = math.floor(factionPayday * 50 / 100)
			end
		end

		totalPayday = totalPayday + factionPayday;
	end

	local vipLevel = vRP.getUserVipRank(user_id) or 0
	if vipLevel > 0 then
		local vipPayday = cfg.vippaycheck[vipLevel] or 0

		if vipPayday > 0 then
			totalPayday = totalPayday + vipPayday
		end
	end

	local player = vRP.getUserSource(user_id)
	local currentTime = os.date("%d/%m/%Y %H:%M")
	TriggerEvent("fp-phone:addMail", {
		sender = "Primaria Ryde",
		subject = "Salariu",
		message = [[
			La data de ]]..currentTime..[[ v-a fost virat in contul dvs. bancar salariul in valoare de $]]..vRP.formatMoney(totalPayday)..[[ 💵
			<hr>
			<span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">Banca Nationala Ryde</span>
			<br>
			<span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">ryde-rp.com</span>
		]],
	}, player)
	vRP.giveBankMoney(user_id, totalPayday, "Payday")
end

local function TakePlayerTaxes(user_id)
	local userVehs = vRP.GetUserVehicles(user_id)
	local totalTax = 0;

	if type(userVehs) ~= "table" then
		return
	end

	for vehicle,data in pairs(userVehs) do
		if not data.premium and not data.vip then
			if Vehicles.masiniDealership[vehicle] then
				local vehPrice = Vehicles.masiniDealership[vehicle][2]

				if vehPrice > 0 then
					local vehTax = math.floor(vehPrice * 0.10 / 100)
					totalTax = totalTax + vehTax
				end
			end
		end
	end

	if vRP.getUserVipRank(user_id) == 2 then
		-- Calculam 80% din suma initiala
		totalTax = math.floor(totalTax * 80 / 100)
	end

	if vRP.getUserVipRank(user_id) == 3 then
		-- Calculam 40% din suma initiala
		totalTax = math.floor(totalTax * 40 / 100)
	end

	if totalTax > 0 then
		local player = vRP.getUserSource(user_id)
		local currentTime = os.date("%d/%m/%Y %H:%M")
		TriggerEvent("fp-phone:addMail", {
			sender = "Primaria Ryde",
			subject = "Faction Payday",
			message = [[
				La data de ]]..currentTime..[[ contul dvs. bancar a fost debitat cu suma de $]]..vRP.formatMoney(totalTax)..[[ 💵 pentru achitarea taxelor si impozitelor.
				<hr>
				<span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">Banca Ryde</span>
				<br>
				<span style="font-size: .8em; opacity: .8; float: right; right: 1vw; position: relative;">ryde-rp.com</span>
			]],
		}, player)
		vRP.tryBankPayment(user_id, totalTax, false, true)
	end

end

local thePaydayTime = os.time() + cfg.paydayDuration

function paydayCheck()
	Citizen.CreateThread(function()
		SetTimeout(5000, paydayCheck)
	end)
	

	if os.time() >= thePaydayTime then
		thePaydayTime = os.time() + cfg.paydayDuration
		Citizen.CreateThread(function()
			local users = vRP.getUsers()
			for user_id, player in pairs(users) do
				GivePayday(user_id)
				TakePlayerTaxes(user_id)
				Citizen.Wait(150)
			end
		end)

		TriggerEvent("vRP:onPayday")
	end
end paydayCheck()


RegisterCommand("forcepayday", function(player)
	if player == 0 then
		Citizen.CreateThread(function()
			local users = vRP.getUsers()
			for user_id, player in pairs(users) do
				GivePayday(user_id)
				TakePlayerTaxes(user_id)
				Citizen.Wait(150)
			end
		end)
	end
end)

RegisterCommand("setpayday", function(player, args)
	local granted = (player == 0)
	if not granted then
		local user_id = vRP.getUserId(player)
		granted = vRP.isUserDeveloper(user_id)
	end

	if granted then
		local durr = 60
		if args[1] then
			durr = tonumber(args[1])
		end

		thePaydayTime = os.time() + durr
	else
		vRPclient.denyAcces(player)
	end
end)

RegisterCommand("getpayday", function(player)
	local granted = (player == 0)
	if not granted then
		local user_id = vRP.getUserId(player)
		granted = vRP.isUserDeveloper(user_id)
	end

	if granted then
		local remainingSec = thePaydayTime - os.time()
		if player == 0 then
			print("PayDay remaining time: "..math.floor(remainingSec / 60).." minutes "..(remainingSec % 60).." seconds")
		else
			vRPclient.msg(player, {"^5Debug: ^7There are ^5"..math.floor(remainingSec / 60).." minutes "..(remainingSec % 60).." seconds^7 remaining until payday."})
		end
	else
		vRPclient.denyAcces(player)
	end
end)