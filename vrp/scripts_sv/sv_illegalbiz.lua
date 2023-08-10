local bizs = {}
local cfg = module("cfg/illegalbiz")

local function getWashersConfig()
    exports.oxmysql:execute("SELECT * FROM washers", function(results)
        local bizs = {}

        for _, bizData in ipairs(results) do
            bizData.dateOfTax = os.date("%d.%m.%Y", bizData.nextPay)
            bizData.desc = cfg.biz_descriptions[bizData.type]
            bizData.type = cfg.biz_types[bizData.type]
            bizData.pos = vec3(bizData.pos_x, bizData.pos_y, bizData.pos_z)

            bizs[bizData.bizId] = bizData
        end

        -- Utilizați variabila "bizs" în continuare pentru a accesa datele afacerilor de spălătorii
    end)
end

AddEventHandler("onDatabaseConnect", function(db)
	Citizen.Wait(500)
	getWashersConfig()
end)

RegisterCommand("loadwashers", function(player)
	local granted = false
	if (player ~= 0) and vRP.isUserAdministrator(vRP.getUserId(player)) then
		granted = true
	end

	if (player == 0) or granted then
		bizs = {}
	    getWashersConfig()

	    return
	end

	vRPclient.denyAcces(player, {})
end)

ExecuteCommand("loadwashers")
local function build_client_washers(player, rebuild)
	TriggerClientEvent("vRP:setWashersData", player, bizs, rebuild)
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
		build_client_washers(source)
	end
end)

RegisterServerEvent("vRP:payWasherBiz")
AddEventHandler("vRP:payWasherBiz", function(oneBiz)
	local player = source
	local user_id = vRP.getUserId(player)
	local userFaction = vRP.getUserFaction(user_id)
	local bizData = bizs[oneBiz]

	if userFaction ~= bizData.faction then
		return vRPclient.notify(player, {"Nu deții această afacere.", "error"})
	end

	if not bizData.nextPay then
		return vRPclient.notify(player, {"Această afacere nu trebuie plătită.", "error"})
	end

	local granted = vRP.isFactionLeader(user_id) or vRP.isFactionCoLeader(user_id)
	if not granted then
		return vRPclient.notify(player, {"Nu poți plăti întreținerea afacerii.", "error"})
	end

	local totalPrice = 100000 -- 100.000$
	if bizData.suspended then
		totalPrice = totalPrice * 2
	end

	if bizData.blocked then
		return vRPclient.notify(player, {"Afacerea a fost blocată de către Sindicat și nu poate fi deblocată.", "error"})
	end

	local sameDay = (os.date("%d.%m.%Y", bizData.nextPay) == os.date("%d.%m.%Y")) or (bizData.nextPay <= os.time())
	if not sameDay then
		return vRPclient.notify(player, {"Nu poți plăti întreținerea acum.", "error"})
	end

	vRP.request(player, "Prețul pentru întreținerea afacerii este de $"..vRP.formatMoney(totalPrice)..", vrei să plătești?", false, function(_, ok)
		if ok then
			local paidOne = vRP.tryPayment(user_id, totalPrice, true)
			if paidOne then
				if bizData.suspended then
					exports.oxmysql:execute("UPDATE washers SET suspended = 0 WHERE faction = ?", {userFaction})
					bizs[oneBiz].suspended = false
				end

				local oneWeek = os.time() + daysToSeconds(7)
				bizs[oneBiz].nextPay = oneWeek
				bizs[oneBiz].dateOfTax = os.date("%d.%m.%Y", oneWeek)

				exports.oxmysql:execute("UPDATE washers SET nextPay = ? WHERE faction = ?", {oneWeek, userFaction})

				build_client_washers(-1)
			end
		end
	end)
end)


local washSecret = {}

RegisterServerEvent("vRP:washMoney")
AddEventHandler("vRP:washMoney", function(oneBiz)
	local player = source
	local user_id = vRP.getUserId(player)
	local userFaction = vRP.getUserFaction(user_id)
	local bizData = bizs[oneBiz]

	if not bizData then
		return vRPclient.notify(player, {"Afacere inexistenta.", "error"})
	end

	if userFaction ~= bizData.faction then
		return vRPclient.notify(player, {"Nu deții această afacere.", "error"})
	end

	if bizData.suspended then
		return vRPclient.notify(player, {"Această afacere este suspendată și nu poate fi folosită.", "error"})
	end

	local muchHave = vRP.getInventoryItemAmount(user_id, "bani_murdari")
	local muchTaken = cfg.minMoney

	if muchHave >= 50000 then
		muchTaken = 35000
	elseif muchHave >= 25000 then
		muchTaken = 25000
	end

	if vRP.tryGetInventoryItem(user_id, "bani_murdari", muchTaken, true) then
		local newSecret = math.random(1, user_id) + ((os.time() % 60) + 1)
		washSecret[user_id] = newSecret

		TriggerClientEvent("vRP:washMoney", player, washSecret[user_id], muchTaken)
	end
end)

RegisterServerEvent("vRP:checkWashSkill")
AddEventHandler("vRP:checkWashSkill", function(cb, muchTaken)
	local player = source
	local user_id = vRP.getUserId(player)

	if not washSecret[user_id] or (washSecret[user_id] ~= cb) then
		return false
	end

	washSecret[user_id] = nil
	local reward = math.ceil(muchTaken * 0.95)
	vRP.giveMoney(user_id, reward)
	vRPclient.notify(player, {"💴 Ai primit $"..vRP.formatMoney(reward)})
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if washSecret[user_id] then
		washSecret[user_id] = nil
	end
end)

local theInterval = os.time() + cfg.checkDuration

function suspendCheck()
	Citizen.CreateThread(function()
		SetTimeout(5000, suspendCheck)
	end)
	

	if os.time() >= theInterval then
		theInterval = os.time() + cfg.checkDuration
		Citizen.CreateThread(function()
			local suspendedOne = false
			for biz_id, data in pairs(bizs) do
				
				if (os.time() > (data.nextPay or 0)) and not data.suspended then
					if data.faction ~= "Sindicat" then
					
						data.suspended = true
						suspendedOne = true

						exports.mongodb:updateOne({collection = "washers", query = {faction = data.faction}, update = {
							["$set"] = {suspended = true}
						}})

						-- print("suspended biz with id: "..biz_id)
					
					end
				end

				Citizen.Wait(150)
			end

			if suspendedOne then
				build_client_washers(-1)
			end
		end)
	end
end

suspendCheck()

local function ch_sindicatemenu(source)
	local user_id = vRP.getUserId(source)
	vRP.buildMenu('sindicatMenu', {player = source}, function(menu)
		menu.onclose = function(player) end

		menu["💲 Create Business"] = {function()
			vRPclient.getPosition(source, {}, function(x, y, z)
				vRP.prompt(source, "CREATE BUSINESS", {
					{field = "bizType", title = "Tip afacere"},
					{field = "bizName", title = "Nume afacere"},
					{field = "faction", title = "Factiune"},
				}, function(player, res)
					local bizType = res["bizType"]
					local bizName = res["bizName"]
					local faction = res["faction"]

					if bizType and bizName and faction then
						bizType = bizType:lower()

						if not cfg.biz_types[bizType] then
							local allTypes = table.concat(cfg.biz_types, ", ")
							return vRPclient.notify(source, {"Tipul afacerii este invalid, tipurile disponibile sunt: "..allTypes, "info", 8000})
						end

						local oneWeek = os.time() + daysToSeconds(7)
						local newBusiness = {
							pos = {x, y, z},
							faction = faction,
							name = bizName,
							type = bizType,
							nextPay = oneWeek,
						}

						exports.oxmysql:insert('INSERT INTO washers (pos, faction, name, type, nextPay) VALUES (?, ?, ?, ?, ?)', {json.encode(newBusiness.pos), faction, bizName, bizType, oneWeek}, function(affectedRows)
							if affectedRows > 0 then
								vRPclient.notify(source, {"Ai creat afacerea factiunii: "..faction, "info"})

								-- refresh local storage
								Citizen.Wait(500)
								getWashersConfig()

								Citizen.Wait(1024)
								build_client_washers(-1, true)
							else
								vRPclient.notify(source, {"A apărut o eroare la crearea afacerii.", "error"})
							end
						end)
					end
				end)
			end)
		end}

		menu["📛 Delete Business"] = {function()
			vRPclient.getNearestWasher(source, {}, function(oneBiz)
				if oneBiz == 0 then
					return vRPclient.notify(source, {"Nici o afacere ilegala in apropiere.", "error"})
				end

				local bizData = bizs[oneBiz]

				vRP.request(source, "Ești sigur că vrei să ștergi afacerea deținută de facțiunea "..bizData.faction.."?", false, function(player, ok)
					if ok then
						-- delete from local storage
						bizs[oneBiz] = nil

						exports.oxmysql:execute('DELETE FROM washers WHERE faction = ?', {bizData.faction}, function(affectedRows)
							if affectedRows > 0 then
								vRP.doFactionFunction(bizData.faction, function(src)
									TriggerClientEvent("vRP:requestKey", src, false)
								end)

								TriggerClientEvent("vRP:requestKey", source, false)

								vRPclient.notify(source, {"Ai șters afacerea factiunii: "..bizData.faction, "info"})
								build_client_washers(-1)
							else
								vRPclient.notify(source, {"A apărut o eroare la ștergerea afacerii.", "error"})
							end
						end)
					end
				end)
			end)
		end}

		menu["🔱 Set Business Faction"] = {function()
			vRPclient.getNearestWasher(source, {}, function(oneBiz)
				if oneBiz == 0 then
					return vRPclient.notify(source, {"Nici o afacere ilegala in apropiere.", "error"})
				end

				vRP.prompt(source, "SET BIZ FACTION", {
					{field = "faction", title = "Faction"},
				}, function(player, res)
					local faction = res["faction"]

					if faction then
						local bizData = bizs[oneBiz]
						local lastFaction = bizData.faction
						local oneWeek = os.time() + daysToSeconds(7)

						-- replace table values
						bizs[oneBiz].nextPay = oneWeek
						bizs[oneBiz].dateOfTax = os.date("%d.%m.%Y", oneWeek)
						bizs[oneBiz].faction = faction

						if bizData.suspended then
							bizs[oneBiz].suspended = false
						end

						exports.oxmysql:execute('UPDATE washers SET faction = ?, nextPay = ? WHERE faction = ?', {faction, oneWeek, lastFaction}, function(affectedRows)
							if affectedRows > 0 then
								vRPclient.notify(source, {"Ai setat afacerea factiunii: "..faction, "success"})
								build_client_washers(-1)
							else
								vRPclient.notify(source, {"A apărut o eroare la modificarea factiunii afacerii.", "error"})
							end
						end)
					end
				end)
			end)
		end}

		menu["🪓 Suspend Business"] = {function()
			vRPclient.getNearestWasher(source, {}, function(oneBiz)
				if oneBiz == 0 then
					return vRPclient.notify(source, {"Nici o afacere ilegala in apropiere.", "error"})
				end

				local bizData = bizs[oneBiz]
				local faction = bizData.faction

				vRP.request(source, "Ești sigur că vrei să blochezi afacerea deținută de facțiunea "..faction.."?", false, function(player, ok)
					if ok then
						bizs[oneBiz].suspended = true
						bizs[oneBiz].blocked = true

						exports.oxmysql:execute('UPDATE washers SET suspended = true, blocked = true WHERE faction = ?', {faction}, function(affectedRows)
							if affectedRows > 0 then
								vRPclient.notify(source, {"Ai blocat afacerea factiunii: "..faction, "success"})
								Citizen.Wait(500)
								build_client_washers(-1)
							else
								vRPclient.notify(source, {"A apărut o eroare la blocarea afacerii.", "error"})
							end
						end)
					end
				end)
			end)
		end}

		menu["🔑 Unsuspend Business"] = {function()
			vRPclient.getNearestWasher(source, {}, function(oneBiz)
				if oneBiz == 0 then
					return vRPclient.notify(source, {"Nici o afacere ilegala in apropiere.", "error"})
				end

				local bizData = bizs[oneBiz]
				if not bizData.blocked then
					return vRPclient.notify(source, {"Afacerea nu este blocata.", "error"})
				end

				local faction = bizData.faction
				vRP.request(source, "Ești sigur că vrei să deblochezi afacerea deținută de facțiunea "..faction.."?", false, function(player, ok)
					if ok then
						bizs[oneBiz].suspended = false
						bizs[oneBiz].blocked = false

						local oneWeek = os.time() + daysToSeconds(7)
						bizs[oneBiz].nextPay = oneWeek
						bizs[oneBiz].dateOfTax = os.date("%d.%m.%Y", oneWeek)

						exports.oxmysql:transaction(function()
							exports.oxmysql:execute('UPDATE washers SET suspended = ?, blocked = ?, nextPay = ? WHERE faction = ?', {false, false, oneWeek, faction}, function(affectedRows)
								if affectedRows > 0 then
									vRPclient.notify(source, {"Ai deblocat afacerea factiunii: "..faction, "success"})
									Citizen.Wait(500)
									build_client_washers(-1)
								else
									vRPclient.notify(source, {"A apărut o eroare la deblocarea afacerii.", "error"})
								end
							end)
						end)
					end
				end)
			end)
		end}

		vRP.openMenu(source, menu)
	end)
end


vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id ~= nil then
    local choices = {}

    if vRP.hasGroup(user_id, "Sindicat") then
    	choices[" ⚔️  Meniu Sindicat "] = {ch_sindicatemenu}
    end

    add(choices)
  end
end)