local vipCars = module("cfg/vip")
local vipLevels = {'Silver Account', 'Gold Account', 'Platinum Account'}
local JobBoosts = {5, 10, 15}

function vRP.getUserVipRank(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return (tmp.vipRank or 0)
	end
	return 0
end

function vRP.isUserVip(user_id)
    local pVip = vRP.getUserVipRank(user_id)
	if(pVip > 0)then
		return true
	else
		return false
	end
end

function vRP.hasUserSilverAccount(user_id)
    local pVip = vRP.getUserVipRank(user_id)
    return (pVip or 0) >= 1
end

function vRP.hasUserGoldAccount(user_id)
    local pVip = vRP.getUserVipRank(user_id)
    return (pVip or 0) >= 2
end

function vRP.hasUserPlatinumAccount(user_id)
    local pVip = vRP.getUserVipRank(user_id)
    return (pVip or 0) >= 3
end

vRP.isUserVipSilver = vRP.hasUserSilverAccount
vRP.isUserVipGold = vRP.hasUserGoldAccount
vRP.isUserVipPlatinum = vRP.hasUserPlatinumAccount

function vRP.setUserVipLevel(user_id,vip)
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp then
        tmp.vipRank = vip
    end
	exports.oxmysql:execute("UPDATE users SET vipLvl = @vipLvl WHERE id = @id",{
		['@id'] = user_id,
		['@vipLvl'] = vip
	})
end

function vRP.getUserVipTitle(user_id, rank)
    local text = vipLevels[rank or vRP.getUserVipRank(user_id)] or "V.I.P"
    return text
end

function vRP.getOnlineVips()
    local oUsers = {}
    for k,v in pairs(vRP.rusers) do
        if vRP.isUserVip(tonumber(k)) then table.insert(oUsers, tonumber(k)) end
    end
    return oUsers
end

function vRP.GiveJobBoostMoney(user_id, amount)
	local userVip = vRP.getUserVipRank(user_id)
	if userVip > 0 then
		local boost = JobBoosts[userVip]
		local boostAmount = math.floor(amount * boost / 100)
		vRP.giveMoney(user_id, boostAmount, "Job Boost")
	end
end

function vRP.getPlateVouchers(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return (tmp.plateVouchers or 0)
	end
	return 0
end

function vRP.setPlateVouchers(user_id, amount)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.plateVouchers = amount
	end
	exports.oxmysql:execute("UPDATE users SET plateVouchers = @plateVouchers WHERE id = @id",{
		['@id'] = user_id,
		['@plateVouchers'] = vip
	})
end

-- [LOCAL FUNCTIONS]

local function hasBoughtGrade(user_id, theGrade, cbr)
	local task = Task(cbr, {false, 0})
    exports.oxmysql:query("SELECT userGrades FROM users WHERE id = @id",{['@id'] = user_id}, function(result)
		local ownedGrades = json.decode(result[1].userGrades) or {}
		for k, v in pairs(ownedGrades) do
			if v.grade == theGrade then
				task({true, v.expireTime})
			end
		end
		task()
	end)
end

local function getIdentifierByPhoneNumber(phone_number, cbr) 
	local task = Task(cbr, {0}, 2000)
  
	exports.oxmysql:query("SELECT * FROM users WHERE phone = @phone",{['@phone'] = phone_number},function(result)
		task({result})
	end)
  end

local function GetUserByCreatorCode(creatorCode, cbr)
	local task = Task(cbr, {false,0})
	exports.oxmysql:query("SELECT id FROM creatorCodes WHERE code = @code",{['@code'] = creatorCode}, function(result)
		if result[1] then
			task({true, result[1].id})
		end
		task()
	end)
end

local function removeGivenCars(user_id, carsCategory)
	exports.oxmysql:query("DELETE FROM userVehicles WHERE user_id = @user_id AND premium = @premium AND vip = @vip",{
		['@user_id'] = user_id,
		['@premium'] = 1,
		['@vip'] = 1
	})
    
    for theModel,_ in pairs(vipCars[carsCategory]) do
        vRP.removeCacheVehicle(user_id, theModel)
    end
end

function is_valid_format(str)
	return string.match(str, "^%d%d%d%-%d%d%d%d$") ~= nil
 end

local function RewardCreator(user_id, coins)
	local player = vRP.getUserSource(user_id)
	if player then
		vRP.giveCoins(user_id, coins, true)
		vRPclient.msg(player, {"^3CREATOR CODE: ^7Cineva tocmai a folosit Creator Code-ul tau si ai primit ^3"..coins.." ^7Ryde Coins!"})
	else
		exports.oxmysql:execute("UPDATE users SET premiumCoins = @premiumCoins WHERE id = @id",{
			['@id'] = user_id,
			['@premiumCoins'] = coins
		})
	end
end

-- [BUY EVENT]
RegisterServerEvent("FP:BuyPremiumThing", function(whatBuyed, creatorCode)
	local player = source
	local user_id = vRP.getUserId(player)
	local name = GetPlayerName(player)

	-- [SILVER ACCOUNT]
	if whatBuyed == "silver_account" then
		if vRP.isUserVip(user_id) then return vRPclient.notify(player, {"Detii deja un Premium Account, asteapta ca acesta sa iti expire"}) end
		if vRP.tryCoinsPayment(user_id, 4, true) then
			-- Set User Vip
		    vRP.setUserVipLevel(user_id, 1)
			local vipData = {
				grade = "vipAccount:1",
				expireTime = (os.time() + daysToSeconds(30)),
				buyTime = os.time(),
			}
			exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
				['@id'] = user_id,
				['@userGrades'] = json.encode(vipData),
				['@expireTime'] = vipData.expireTime
			})
			--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Silver Account cu 5 Coins", "premiumShop", "gold-account")

			-- Give User Bonus
			vRP.giveMoney(user_id, 3500000, "VIPShop")
			vRP.giveUserPremiumVehicles(user_id, "Silver Account")
			vRPclient.notify(player, {"🪙 Ai cumparat Silver Account", "info"})
		else
			vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
		end

	-- [Gold Account]	
	elseif whatBuyed == "gold_account" then
		if vRP.isUserVip(user_id) then return vRPclient.notify(player, {"Detii deja un Premium Account, asteapta ca acesta sa iti expire"}) end
		GetUserByCreatorCode(creatorCode, function(exist, creator)
			if exist then
				if vRP.tryCoinsPayment(user_id, 13, true) then
					-- Set User Vip
					vRP.setUserVipLevel(user_id, 2)
					local vipData = {
						grade = "vipAccount:2",
						expireTime = (os.time() + daysToSeconds(30)),
						buyTime = os.time(),
					}
					exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
						['@id'] = user_id,
						['@userGrades'] = json.encode(vipData),
						['@expireTime'] = vipData.expireTime
					})
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Gold Account cu 13 FPC", "premiumShop", "gold-account")
					-- Give User Bonus
					vRP.giveMoney(user_id, 10500000, "VIPShop")
					vRP.giveUserPremiumVehicles(user_id, "Gold Account")
					local currentVouchers = vRP.getPlateVouchers(user_id)
					vRP.setPlateVouchers(user_id, currentVouchers + 1)
					vRPclient.notify(player, {"🪙 Ai cumparat Gold Account Account", "info"})

					-- Give Creator Bonus
					RewardCreator(creator, 2)
					local CreatorCode = {
						usedBy = user_id,
						creator = creator,
						amount = 2,
						code = creatorCode,
						text = name.." ["..user_id.."] si-a cumparat: Gold Account cu 13 FPC",
						time = os.time(),
						date = os.date("%d/%m/%Y %H:%M"),
					}
					exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
						['@usedBy'] = CreatorCode.usedBy,
						['@creator'] = CreatorCode.creator,
						['@amount'] = CreatorCode.amount,
						['@code'] = CreatorCode.code,
						['@text'] = CreatorCode.text,
						['@time'] = CreatorCode.time,
						['@date'] = CreatorCode.date
					})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			else
				if vRP.tryCoinsPayment(user_id, 15, true) then
					-- Set User Vip
					vRP.setUserVipLevel(user_id, 2)
					local vipData = {
						grade = "vipAccount:2",
						expireTime = (os.time() + daysToSeconds(30)),
						buyTime = os.time(),
					}
					exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades WHERE id = @id",{
						['@id'] = user_id,
						['@userGrades'] = json.encode(vipData),
						['@expireTime'] = vipData.expireTime
					})
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Gold Account cu 15 FPC", "premiumShop", "gold-account")
					-- Give User Bonus
					vRP.giveMoney(user_id, 10500000, "VIPShop")
					vRP.giveUserPremiumVehicles(user_id, "Gold Account")
					local currentVouchers = vRP.getPlateVouchers(user_id)
					vRP.setPlateVouchers(user_id, currentVouchers + 1)
					vRPclient.notify(player, {"🪙 Ai cumparat Gold Account", "info"})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			end
		end)
		
		-- [Platinum Account]
	elseif whatBuyed == "platinum_account" then
		if vRP.isUserVip(user_id) then return vRPclient.notify(player, {"Detii deja un Premium Account, asteapta ca acesta sa iti expire"}) end
		GetUserByCreatorCode(creatorCode, function(exist, creator)
			if exist then
				if vRP.tryCoinsPayment(user_id, 36, true) then
					-- Set User Vip
					vRP.setUserVipLevel(user_id, 3)
					local vipData = {
						grade = "vipAccount:3",
						expireTime = (os.time() + daysToSeconds(30)),
						buyTime = os.time(),
					}
					exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
						['@id'] = user_id,
						['@userGrades'] = json.encode(vipData),
						['@expireTime'] = vipData.expireTime
					})
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Platinum Account cu 40 Ryde Coins", "premiumShop", "platinum-account")				
					-- Give User Bonus
					vRP.giveMoney(user_id, 17000000, "VIPShop")
					vRP.giveUserPremiumVehicles(user_id, "Platinum Account")
					local currentVouchers = vRP.getPlateVouchers(user_id)
					vRP.setPlateVouchers(user_id, currentVouchers + 2)
					vRPclient.notify(player, {"🪙 Ai cumparat Ryde King", "info"})

					-- Give Creator Bonus
					RewardCreator(creator, 4)
					local CreatorCode = {
						usedBy = user_id,
						creator = creator,
						amount = 4,
						code = creatorCode,
						text = name.." ["..user_id.."] si-a cumparat: Platinum Account cu 36 Ryde Coins",
						time = os.time(),
						date = os.date("%d/%m/%Y %H:%M"),
					}
					exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
						['@usedBy'] = CreatorCode.usedBy,
						['@creator'] = CreatorCode.creator,
						['@amount'] = CreatorCode.amount,
						['@code'] = CreatorCode.code,
						['@text'] = CreatorCode.text,
						['@time'] = CreatorCode.time,
						['@date'] = CreatorCode.date
					})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			else
				if vRP.tryCoinsPayment(user_id, 40, true) then
					-- Set User Vip
					vRP.setUserVipLevel(user_id, 3)
					local vipData = {
						grade = "vipAccount:3",
						expireTime = (os.time() + daysToSeconds(30)),
						buyTime = os.time(),
					}
					exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
						['@id'] = user_id,
						['@userGrades'] = json.encode(vipData),
						['@expireTime'] = vipData.expireTime
					})
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Platinum Account cu 40 Ryde Coins", "premiumShop", "platinum-account")
					-- Give User Bonus
					vRP.giveMoney(user_id, 17000000, "VIPShop")
					vRP.giveUserPremiumVehicles(user_id, "Platinum Account")
					local currentVouchers = vRP.getPlateVouchers(user_id)
					vRP.setPlateVouchers(user_id, currentVouchers + 2)
					vRPclient.notify(player, {"🪙 Ai cumparat Ryde King", "info"})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			end
		end)

		-- [Number Plate]
	elseif whatBuyed == "car_plate" then
		if vRP.tryCoinsPayment(user_id, 5) then
			local currentVouchers = vRP.getPlateVouchers(user_id)
			vRP.setPlateVouchers(user_id, currentVouchers + 1)
			vRPclient.notify(player, {"🪙 Ai cumparat 1x Number Plate Voucher", "info"})
			--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: 1x Plate Number Voucher cu 5 Premium Coins", "premiumShop", "plate-vouchers")	
		end

		-- [Phone Number]
	elseif whatBuyed == "phone_number" then
		vRP.prompt(player, "CUSTOM PHONE NUMBER", {{field = "phone", title = "NUMAR DE TELEFON (XXX-XXXX)"}}, function(_, ret)
			local phone_number = ret['phone']
			if is_valid_format(phone_number) then
				getIdentifierByPhoneNumber(tostring(phone_number), function(hasPhone)
					if not next(hasPhone) then
						if vRP.tryCoinsPayment(user_id, 5) then
							vRP.setPhoneNumber(user_id, tostring(phone_number))
						else
							vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
						end
					else
						return vRPclient.notify(player, {"Acest număr este deja deținut de către o persoană, alege alt număr!", "error"})
					end
				end)
			else
				return vRPclient.notify(player, {"Formatul nu a fost respectat!", "error"})
			end
		end)
		-- [Starter Pack]
	elseif whatBuyed == "starter_pack" then
		GetUserByCreatorCode(creatorCode, function(exist, creator)
			if exist then
				if vRP.tryCoinsPayment(user_id, 9) then
					if not vRP.isUserVip(user_id) then
						vRP.setUserVipLevel(user_id, 1)
						local vipData = {
							grade = "vipAccount:1",
							expireTime = (os.time() + daysToSeconds(15)),
							buyTime = os.time(),
						}
						exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
							['@id'] = user_id,
							['@userGrades'] = json.encode(vipData),
							['@expireTime'] = vipData.expireTime
						})
						-- Give User Bonus
						vRP.giveMoney(user_id, 3500000, "VIPShop")
						vRP.giveUserPremiumVehicles(user_id, "Silver Account")
						vRPclient.notify(player, {"🪙 Ai primit Silver Account 15 zile", "info"})
					end
					vRP.giveMoney(user_id, 3500000, "VIPShop")
					vRP.giveInventoryItem(user_id, "geanta",1)
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Starter Pack cu 9 Premium Coins", "premiumShop", "starter-pack")
					
					-- Give Creator Bonus
					RewardCreator(creator, 3)
					local CreatorCode = {
						usedBy = user_id,
						creator = creator,
						amount = 4,
						code = creatorCode,
						text = name.." ["..user_id.."] si-a cumparat: Starter Pack cu 9 Ryde Coins",
						time = os.time(),
						date = os.date("%d/%m/%Y %H:%M"),
					}
					exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
						['@usedBy'] = CreatorCode.usedBy,
						['@creator'] = CreatorCode.creator,
						['@amount'] = CreatorCode.amount,
						['@code'] = CreatorCode.code,
						['@text'] = CreatorCode.text,
						['@time'] = CreatorCode.time,
						['@date'] = CreatorCode.date
					})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			else
				if vRP.tryCoinsPayment(user_id, 12) then
					if not vRP.isUserVip(user_id) then
						vRP.setUserVipLevel(user_id, 1)
						local vipData = {
							grade = "vipAccount:1",
							expireTime = (os.time() + daysToSeconds(15)),
							buyTime = os.time(),
						}
						exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades, expireTime = @expireTime WHERE id = @id",{
							['@id'] = user_id,
							['@userGrades'] = json.encode(vipData),
							['@expireTime'] = vipData.expireTime
						})
						-- Give User Bonus
						vRP.giveMoney(user_id, 3500000, "VIPShop")
						vRP.giveUserPremiumVehicles(user_id, "Silver Account")
						vRPclient.notify(player, {"🪙 Ai primit Silver Account 15 zile", "info"})
					end
					vRP.giveMoney(user_id, 3500000, "VIPShop")
					vRP.giveInventoryItem(user_id, "geanta",1)
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Starter Pack cu 12 Premium Coins", "premiumShop", "starter-pack")	
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			end
		end)
		-- [Maybach Pack]
	elseif whatBuyed == 'maybach_pack' then
		if vRP.getUserVipRank(user_id) >= 2 then
			GetUserByCreatorCode(creatorCode, function(exist, creator)
				if exist then
					if vRP.tryCoinsPayment(user_id, 18) then
						-- Give User Vehicles
						vRP.giveUserPackVehicles(user_id, "maybach_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Maybach Pack cu 18 Ryde Coins", "premiumShop", "maybach-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Maybach Pack cu 18 Ryde Coins", "info"})
						-- Give Creator Bonus
						RewardCreator(creator, 2)
						local CreatorCode = {
							usedBy = user_id,
							creator = creator,
							amount = 2,
							code = creatorCode,
							text = name.." ["..user_id.."] si-a cumparat: Maybach Pack cu 18 Ryde Coins",
							time = os.time(),
							date = os.date("%d/%m/%Y %H:%M"),
						}
						exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
							['@usedBy'] = CreatorCode.usedBy,
							['@creator'] = CreatorCode.creator,
							['@amount'] = CreatorCode.amount,
							['@code'] = CreatorCode.code,
							['@text'] = CreatorCode.text,
							['@time'] = CreatorCode.time,
							['@date'] = CreatorCode.date
						})
					end
				else
					if vRP.tryCoinsPayment(user_id, 20) then
						vRP.giveUserPackVehicles(user_id, "maybach_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Maybach Pack cu 20 Ryde Coins", "premiumShop", "maybach-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Maybach Pack cu 20 Ryde Coins", "info"})
					else
						vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
					end
				end
			end)
		else
			return vRPclient.notify(player, {"Ai nevoie de minim Gold Account pentru a putea achizitiona acest Pack.", "error"})
		end

		-- [Audi Pack]
	elseif whatBuyed == 'audi_pack' then
		if vRP.getUserVipRank(user_id) >= 2 then
			GetUserByCreatorCode(creatorCode, function(exist, creator)
				if exist then
					if vRP.tryCoinsPayment(user_id, 13) then
						-- Give User Vehicles
						vRP.giveUserPackVehicles(user_id, "audi_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Audi Pack cu 13 Ryde Coins", "premiumShop", "audi-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Audi Pack cu 13 Ryde Coins", "info"})
						-- Give Creator Bonus
						RewardCreator(creator, 2)
						local CreatorCode = {
							usedBy = user_id,
							creator = creator,
							amount = 2,
							code = creatorCode,
							text = name.." ["..user_id.."] si-a cumparat: Audi Pack cu 13 Ryde Coins",
							time = os.time(),
							date = os.date("%d/%m/%Y %H:%M"),
						}
						exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
							['@usedBy'] = CreatorCode.usedBy,
							['@creator'] = CreatorCode.creator,
							['@amount'] = CreatorCode.amount,
							['@code'] = CreatorCode.code,
							['@text'] = CreatorCode.text,
							['@time'] = CreatorCode.time,
							['@date'] = CreatorCode.date
						})
					end
				else
					if vRP.tryCoinsPayment(user_id, 15) then
						vRP.giveUserPackVehicles(user_id, "audi_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Audi Pack cu 15 Ryde Coins", "premiumShop", "audi-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Audi Pack cu 15 Ryde Coins", "info"})
					else
						vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
					end
				end
			end)
		else
			return vRPclient.notify(player, {"Ai nevoie de minim Gold Account pentru a putea achizitiona acest Pack.", "error"})
		end

		-- [Bmw Pack]
	elseif whatBuyed == "bmw_pack" then 
		if vRP.getUserVipRank(user_id) >= 2 then
			GetUserByCreatorCode(creatorCode, function(exist, creator)
				if exist then
					if vRP.tryCoinsPayment(user_id, 13) then
						-- Give User Vehicles
						vRP.giveUserPackVehicles(user_id, "bmw_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Bmw Pack cu 13 Ryde Coins", "premiumShop", "bmw-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Bmw Pack cu 13 Ryde Coins", "info"})
						-- Give Creator Bonus
						RewardCreator(creator, 2)
						local CreatorCode = {
							usedBy = user_id,
							creator = creator,
							amount = 2,
							code = creatorCode,
							text = name.." ["..user_id.."] si-a cumparat: Bmw Pack cu 13 Ryde Coins",
							time = os.time(),
							date = os.date("%d/%m/%Y %H:%M"),
						}
						exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
							['@usedBy'] = CreatorCode.usedBy,
							['@creator'] = CreatorCode.creator,
							['@amount'] = CreatorCode.amount,
							['@code'] = CreatorCode.code,
							['@text'] = CreatorCode.text,
							['@time'] = CreatorCode.time,
							['@date'] = CreatorCode.date
						})
					end
				else
					if vRP.tryCoinsPayment(user_id, 15) then
						vRP.giveUserPackVehicles(user_id, "bmw_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Bmw Pack cu 15 Ryde Coins", "premiumShop", "bmw-pack")
						vRPclient.notify(player, {"Ti-ai cumparat BMW Pack cu 15 Ryde Coins", "info"})
					else
						vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
					end
				end
			end)
		else
			return vRPclient.notify(player, {"Ai nevoie de minim Gold Account pentru a putea achizitiona acest Pack.", "error"})
		end

		-- [Rolls Royce Pack]
	elseif whatBuyed == 'rolls_pack' then
		if vRP.getUserVipRank(user_id) >= 2 then
			GetUserByCreatorCode(creatorCode, function(exist, creator)
				if exist then
					if vRP.tryCoinsPayment(user_id, 23) then
						-- Give User Vehicles
						vRP.giveUserPackVehicles(user_id, "rolls_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Rolls Royce Pack cu 23 Ryde Coins", "premiumShop", "rolls-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Rolls Royce Pack cu 23 Ryde Coins", "info"})
						-- Give Creator Bonus
						RewardCreator(creator, 2)
						local CreatorCode = {
							usedBy = user_id,
							creator = creator,
							amount = 2,
							code = creatorCode,
							text = name.." ["..user_id.."] si-a cumparat: Rolls Royce Pack cu 23 Ryde Coins",
							time = os.time(),
							date = os.date("%d/%m/%Y %H:%M"),
						}
						exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
							['@usedBy'] = CreatorCode.usedBy,
							['@creator'] = CreatorCode.creator,
							['@amount'] = CreatorCode.amount,
							['@code'] = CreatorCode.code,
							['@text'] = CreatorCode.text,
							['@time'] = CreatorCode.time,
							['@date'] = CreatorCode.date
						})
					end
				else
					if vRP.tryCoinsPayment(user_id, 25) then
						vRP.giveUserPackVehicles(user_id, "rolls_pack")
						--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Rolls Royce Pack cu 25 Ryde Coins", "premiumShop", "rolls-pack")
						vRPclient.notify(player, {"Ti-ai cumparat Rolls Royce Pack cu 25 Ryde Coins", "info"})
					else
						vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
					end
				end
			end)
		else
			return vRPclient.notify(player, {"Ai nevoie de minim Gold Account pentru a putea achizitiona acest Pack.", "error"})
		end

		-- [Exclusive Pack]
	elseif whatBuyed == "exclusive_pack" then
		if vRP.getUserVipRank(user_id) < 3 then
			return vRPclient.notify(player, {"Ai nevoie de minim Ryde King Account pentru a putea achizitiona acest Pack.", "error"})
		end
		GetUserByCreatorCode(creatorCode, function(exist, creator)
			if exist then
				if vRP.tryCoinsPayment(user_id, 108) then
					-- Give User Vehicles
					vRP.giveUserPackVehicles(user_id, "exclusive_pack")
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Exclusive Pack cu 108 Ryde Coins", "premiumShop", "exclusive-pack")
					vRPclient.notify(player, {"Ti-ai cumparat Exclusive Pack cu 108 Ryde Coins", "info"})
					-- Give Creator Bonus
					RewardCreator(creator, 2)
					local CreatorCode = {
						usedBy = user_id,
						creator = creator,
						amount = 2,
						code = creatorCode,
						text = name.." ["..user_id.."] si-a cumparat: Exclusive Pack cu 108 Ryde Coins",
						time = os.time(),
						date = os.date("%d/%m/%Y %H:%M"),
					}
					exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
						['@usedBy'] = CreatorCode.usedBy,
						['@creator'] = CreatorCode.creator,
						['@amount'] = CreatorCode.amount,
						['@code'] = CreatorCode.code,
						['@text'] = CreatorCode.text,
						['@time'] = CreatorCode.time,
						['@date'] = CreatorCode.date
					})
				end
			else
				if vRP.tryCoinsPayment(user_id, 120) then
					vRP.giveUserPackVehicles(user_id, "exclusive_pack")
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Exclusive Pack cu 120 Ryde Coins", "premiumShop", "exclusive-pack")
					vRPclient.notify(player, {"Ti-ai cumparat Exclusive Pack cu 120 Ryde Coins", "info"})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			end
		end)
	elseif whatBuyed == 'plane_pack' then
		GetUserByCreatorCode(creatorCode, function(exist, creator)
			if exist then
				if vRP.tryCoinsPayment(user_id, 27) then
					-- Give User Vehicles
					vRP.giveUserPackVehicles(user_id, "plane_pack")
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Planes Pack cu 27 Ryde Coins", "premiumShop", "planes-pack")
					vRPclient.notify(player, {"Ti-ai cumparat Planes Pack cu 27 Ryde Coins", "info"})
					-- Give Creator Bonus
					RewardCreator(creator, 3)
					local CreatorCode = {
						usedBy = user_id,
						creator = creator,
						amount = 2,
						code = creatorCode,
						text = name.." ["..user_id.."] si-a cumparat: Planes Pack cu 27 Ryde Coins",
						time = os.time(),
						date = os.date("%d/%m/%Y %H:%M"),
					}
					exports.oxmysql:execute("INSERT INTO usedCreatorCodes (usedBy,creator,amount,code,text,time,date) VALUES(@usedBy,@creator,@amount,@code,@text,@time,@date)", {
						['@usedBy'] = CreatorCode.usedBy,
						['@creator'] = CreatorCode.creator,
						['@amount'] = CreatorCode.amount,
						['@code'] = CreatorCode.code,
						['@text'] = CreatorCode.text,
						['@time'] = CreatorCode.time,
						['@date'] = CreatorCode.date
					})
				end
			else
				if vRP.tryCoinsPayment(user_id, 30) then
					vRP.giveUserPackVehicles(user_id,"plane_pack")
					--vRP.createLog(user_id, name.." ["..user_id.."] si-a cumparat: Planes Pack cu 30 Ryde Coins", "premiumShop", "planes-pack")
					vRPclient.notify(player, {"Ti-ai cumparat Planes Pack cu 30 Ryde Coins", "info"})
				else
					vRPclient.notify(player, {"🪙 Nu ai destui Ryde Coins", "error"})
				end
			end
		end)
	end
end)

-- Player Spawn Events
AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		local rows = exports.oxmysql:querySync("SELECT firstName,secondName,age,phone,iban,sex,profilePhoto,phoneBackground FROM users WHERE id = @id", {['@id'] = user_id})
		if #rows > 0 then
		local expiredOne = false

		local allGrades = rows[1].userGrades or {}
		for k, v in pairs(allGrades) do
			local expiringDateString = os.date("%d/%m/%Y %H:%M", rows[1].expireTime)

			if (tonumber(v.expireTime) or 0) <= os.time() then
				local vipLvl = tonumber(rows[1].vipLvl:sub(12))

				if vRP.getUserVipRank(user_id) == vipLvl then
					vRP.setUserVipLevel(user_id, 0)
					Citizen.SetTimeout(1000, function()
						vRPclient.notify(player, {vipLevels[vipLvl]..' ti-a expirat la data '..expiringDateString, 'warning', nil, 'fas fa-medal'})
						removeGivenCars(user_id, vipLevels[vipLvl])
					end)
				end
				expiredOne = true
			else
               local vipLvl = tonumber(rows[1].vipLvl:sub(12))
               Citizen.SetTimeout(1000, function()
               	vRPclient.notify(player, {vipLevels[vipLvl]..' iti expira la data '..expiringDateString, 'info', nil, 'fas fa-medal'})
               end)
			   TriggerClientEvent("FP:SetSecondsUntilKick", player, vipLvl)
			end
		end

		if expiredOne then
			local vipData = {
				buyTime = os.time()
			}
			exports.oxmysql:execute("UPDATE users SET userGrades = @userGrades WHERE id = @id",{
				['@id'] = user_id,
				['@userGrades'] = json.encode(vipData)
			})
	    end
	end
	end
end)

AddEventHandler("vRP:playerJoin",function(user_id, source, name, extraData)
	local rows = exports.oxmysql:querySync("SELECT firstName,secondName,age,phone,iban,sex,profilePhoto,phoneBackground FROM users WHERE id = @id", {['@id'] = user_id})
	if #rows > 0 then
	local vipRank = tonumber(rows[1].vipLvl or 0)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.vipRank = vipRank or 0
		tmp.plateVouchers = rows[1].plateVouchers or 0
	end
end
end)

function tvRP.GetUserPremiumCoins()
	local player = source
	local user_id = vRP.getUserId(player)
	return vRP.getCoins(user_id) or 0
end