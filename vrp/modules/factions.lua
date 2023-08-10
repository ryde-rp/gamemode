
local factions = {}
local factionMembers = {}
local memberDuty = {}

local function getFactionsConfig()
	exports.oxmysql:query("SELECT * FROM factions", function(result)
		for _, fdata in pairs(result) do
			if type(_) ~= 'number' then _ = tonumber(_) end
			factions[fdata.name] = {
				fType = fdata.type,
				fSlots = fdata.slots,
				fRanks =  json.decode(result[_].ranks),
				fBlip = json.decode(result[_].blip),
				budget = fdata.budget or 0,
				fOffice = json.decode(result[_].office) or {},
			}

			if fdata.type == "Mafie" then
				factions[fdata.name].fColor = fdata.color
				factions[fdata.name].fHome = json.decode(result[_].home)
			end
		end

		for i, v in pairs(factions) do
			exports.oxmysql:query("SELECT id,username,userFaction,last_login FROM users WHERE faction = @faction",{['@faction'] = tostring(i)}, function(result)
				factionMembers[tostring(i)] = result
			end)

			Citizen.Wait(30)
		end
	end)
end

--[[
	Weapons Packs
	1: Silver Pack
	2: Gold Pack
	3: Platinum Pack
]]

local fWeaponPacks = {
	{
		-- Pistoale -- -- silver pack ( 0 )
		{id = "body_vintagepistol", name = "Vintage Pistol", price = 1000000},
	},

	{
		-- Pistoale -- -- gold pack ( 2 )
		{id = "body_vintagepistol", name = "Vintage Pistol", price = 1000000},
		{id = "body_minismg", name = "Mini SMG", price = 3000000},
		-- Rifles --
		{id = "body_gusenberg", name = "Gusenberg", price = 3000000},
			-- AMMO --
			{id = "ammo_9mm", name = "Munitie 9mm", price = 10000},
			{id = "ammo_762", name = "Munitie 762", price = 10000},
			{id = "ammo_45acp", name = "Munitie ammo_45acp", price = 10000},
		-- Diverse --
		-- {id = "body_molotov", name = "Molotov", price = 2000},
		-- {id = "body_molotov", name = "Munitie Molotov", price = 600},
	},
	{
		-- Pistoale -- platinum pack ( 3 )
		{id = "body_doubleaction", name = "Double Action", price = 50000000},
		{id = "body_navyrevolver", name = "Navy Revolver", price = 105000000},
		{id = "body_gadgetpistol", name = "Gadget Pistol", price = 115000000},
		{id = "body_machinepistol", name = "Tec9", price = 15000000},
		{id = "body_appistol", name = "APPISTOL", price = 85000000},
		{id = "sfoara", name = "Sfoara", price = 1500000},
		-- Rifles--
		
			-- AMMO --
			{id = "ammo_9mm", name = "Munitie 9mm", price = 10000},
			{id = "ammo_762", name = "Munitie 762", price = 10000},
			{id = "ammo_45acp", name = "Munitie ammo_45acp", price = 10000},
		{id = "body_minismg", name = "Mini SMG", price = 3000000},
		-- Rifles--
		{id = "body_gusenberg", name = "Gusenberg", price = 3000000},
		{id = "body_mg", name = "MG", price = 40000000},
		{id = "body_combatmg", name = "Combat MG", price = 35000000},
		-- Diverse --
		-- {id = "body_stickybomb", name = "Sticky Bomb", price = 75000},
		-- {id = "ammo_stickybomb", name = "Munitie Sticky Bomb", price = 50000},
		-- {id = "body_molotov", name = "Molotov", price = 2000},
		-- {id = "ammo_molotov", name = "Munitie Molotov", price = 600},
	},
}

local fHealPack = {
	{id = "body_armor", name = "Vesta Anti-Glont", price = 2000000},
	{id = "medkit", name = "Trusa Medicala", price = 1000000},
	{id = "adrenalina", name = "Injectie Adrenalina", price = 500000},
	{id = "bandajmic", name = "Bandaj Mic", price = 200000},
	{id = "bandajmare", name = "Bandaj Mare", price = 280000},
}

AddEventHandler("onDatabaseConnect", function(db)
	Citizen.Wait(500)
	getFactionsConfig()
end)

RegisterCommand("loadfactions", function(player)
	local granted = false
	if (player ~= 0) and vRP.isUserAdministrator(vRP.getUserId(player)) then
		granted = true
	end

	if (player == 0) or granted then
		factions = {}
	    factionMembers = {}
	    getFactionsConfig()
	    print("Factions Reloaded")
	    return
	end

	vRPclient.denyAcces(player, {})
end)

ExecuteCommand("loadfactions");

function vRP.getFactionByColor(color)
	for i, v in pairs(factions) do
		if v.fColor == color then
			return tostring(i)
		end
	end
	return false
end

function vRP.getFactions()
	local factionsList = {}
	for i, v in pairs(factions) do
		factionsList[i] = v
	end
	return factionsList
end

function vRP.getUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return tmp.fName
	end
end

function vRP.getFactionRanks(faction)
	local ngroup = factions[faction]

	if ngroup then
		return ngroup.fRanks
	end
end

function vRP.getFactionRankSalary(faction, rank)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		for i, v in pairs(factionRanks) do
			if (v.rank == rank)then
				return v.payday
			end
		end
		return 0
	end
end

function vRP.getFactionSlots(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionSlots = ngroup.fSlots
		return factionSlots
	end
end

function vRP.getFactionColor(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionColor = ngroup.fColor
		return factionColor
	end
end

function vRP.getFactionType(faction)
	local ngroup = factions[faction]
	if ngroup then
		return tostring(ngroup.fType)
	end
end

function vRP.getFactionBlip(faction)
	local ngroup = factions[faction]
	if ngroup then
		return tostring(ngroup.fBlip)
	end
end

function vRP.getFactionBudget(faction)
	local factionObj = factions[faction] or {budget = 0}
	
	if factionObj.budget then
		return factionObj.budget
	end

	return 0
end

function vRP.depositFactionBudget(faction, money)
	if factions[faction].budget then
		factions[faction].budget = factions[faction].budget + money

		exports.oxmysql:execute("UPDATE factions SET budget = @budget WHERE name = @name",{
			['@name'] = faction,
			['@budget'] = factions[faction].budget
		})
		return true
	else
		factions[factions].budget = money
		exports.oxmysql:execute("UPDATE factions SET budget = @budget WHERE name = @name",{
			['@name'] = faction,
			['@budget'] = factions[faction].budget
		})
		return true
	end
	return false
end

function vRP.withdrawFactionBudget(faction, user_id, amount)
	if amount == 0 then return true end;
	local budget = vRP.getFactionBudget(faction)
	if (budget >= amount) and (amount >= 0) then
		factions[faction].budget = factions[faction].budget - amount
		vRP.giveMoney(user_id, amount, "Seiful Factiunii")
		exports.oxmysql:execute("UPDATE factions SET budget = @budget WHERE name = @name",{
			['@name'] = faction,
			['@budget'] = factions[faction].budget
		})
		return true
	end		
	return false
end

function vRP.hasUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		if tmp.fName == "user" then
			return false
		else
			return true
		end
	end
	return false
end

function vRP.isUserInFaction(user_id,group)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		if tmp.fName == group then
			return true
		else
			return false
		end
	end
end

function vRP.isUserFactionDuty(user_id)
	return memberDuty[user_id] == nil
end

function tvRP.isUserFactionDuty()
	return vRP.isUserFactionDuty(vRP.getUserId(source))
end

function vRP.isUserPolitist(user_id)
	return vRP.isUserInFaction(user_id, "Politia Romana")
end

function vRP.isUserMedic(user_id)
	return vRP.isUserInFaction(user_id, "Smurd")
end

function vRP.getFactionOffice(faction)
	local ngroup = factions[faction]
	if ngroup then
		return ngroup.fOffice
	end
end

function vRP.getFactionHome(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionHome = ngroup.fHome
		return factionHome[1], factionHome[2], factionHome[3]
	end
end

function vRP.spawnAtFactionHome(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local x, y, z = vRP.getFactionHome(vRP.getUserFaction(user_id))
		vRPclient.teleport(player, {x, y, z})
		vRPclient.setHealth(player, {200})
	end
end

function vRP.setFactionLeader(user_id,theFaction,leaderRank)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		local userFaction = vRP.getUserFaction(user_id)
		local factionRanks = vRP.getFactionRanks(userFaction)
		local newRank = factionRanks[#factionRanks].rank

		if leaderRank == 1 then
			newRank = factionRanks[#factionRanks-1].rank
		end

		tmp.fRank = newRank
		tmp.fLeader = leaderRank;

		local groupUsers = factionMembers[theFaction]
		if groupUsers then
			exports.oxmysql:execute("UPDATE users SET rank = @rank, leader = @leader WHERE id = @id",{
				['@id'] = user_id,
				['@rank'] = newRank,
				["leader"] = leaderRank
			})
		end
	end
end

function vRP.isFactionLeader(user_id)
	local faction = vRP.getUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)

	if faction then
		if tmp.fLeader == 2 then
			return true
		end
	end

	return false
end

function vRP.getFactionRank(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		return tmp.fRank
	end
end

vRP.getUserFactionRank = vRP.getFactionRank

function vRP.isFactionCoLeader(user_id)
	local faction = vRP.getUserFaction(user_id)
	local tmp = vRP.getUserTmpTable(user_id)

	if faction then
		if tmp.fLeader == 1 then return true end
	end

	return false
end

function vRP.setFactionRank(user_id, rank, theFaction)
	if vRP.getUserSource(user_id) then
		local tmp = vRP.getUserTmpTable(user_id)
		tmp.fRank = rank
		local groupUsers = factionMembers[theFaction]
		if groupUsers then
			for i, v in pairs(groupUsers) do
				if v.id == user_id then
					v.userFaction.rank = rank
				end
			end
		end
		exports.oxmysql:execute("UPDATE users SET rank = @rank, leader = @leader WHERE id = @id",{
			['@id'] = user_id,
			['@rank'] = rank
		})
	else
		local groupUsers = factionMembers[theFaction]
		if groupUsers then
			for i, v in pairs(groupUsers) do
				if v.id == user_id then
					v.userFaction.rank = rank
				end
			end
		end
		exports.oxmysql:execute("UPDATE users SET rank = @rank, leader = @leader WHERE id = @id",{
			['@id'] = user_id,
			['@rank'] = rank
		})
	end
end

function vRP.addUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local ngroup = factions[theGroup]
		if ngroup then
			local factionRank = ngroup.fRanks[1].rank
			local tmp = vRP.getUserTmpTable(user_id)
			if tmp then
				tmp.fName = theGroup
				tmp.fRank = factionRank

				exports.oxmysql:execute("UPDATE users SET faction = @faction, rank = @rank WHERE id = @id",{
					['@id'] = user_id,
					['@faction'] = theGroup,
					['@rank'] = factionRank
				}, function()
					exports.oxmysql:query("SELECT id,username,userFaction FROM users WHERE id = @id",{['@id'] = user_id}, function(result)
						table.insert(factionMembers[theGroup], result[1])
					end)
				end)

				if vRP.getFactionType(theGroup) == "Mafie" then
					local fOffice = vRP.getFactionOffice(theGroup)

					if next(fOffice) ~= nil then
						TriggerClientEvent("vRP:setFactionOffice", player, fOffice)
					end
				end

				if theGroup == "Smurd" or theGroup == "Politia Romana" then
					local userGroup = vRP.getUserJob(user_id)
					
					if userGroup ~= "Somer" then
						TriggerEvent("vRP:removeJob", userGroup, player)
					end
				end
				TriggerClientEvent('vrp-hud:updateBottom', player, {name = GetPlayerName(player), faction = theGroup});
				TriggerClientEvent("vRP:onFactionChange", player, theGroup)
			end
		end
	end
end

function vRP.getUsersByFaction(group)
	return factionMembers[group] or {}
end

function vRP.getOnlineUsersByFaction(group)
	local oUsers = {}

	for k,v in pairs(vRP.rusers) do
		if vRP.isUserInFaction(k, group) then
			oUsers[#oUsers + 1] = k
		end
	end

	return oUsers
end

function vRP.removeUserFaction(user_id, theGroup, transfer)
	local player = vRP.getUserSource(user_id)
	if player then
		local tmp = vRP.getUserTmpTable(user_id)
		if tmp then
			local groupUsers = factionMembers[theGroup]
			if groupUsers then
				for i, v in pairs(groupUsers) do
					if v.id == user_id then
						factionMembers[theGroup][i] = nil
					end
				end
			end

			tmp.fName = "user"
			tmp.fRank = 'none'
		end

		if vRP.getFactionType(theGroup) == "Mafie" then
			TriggerClientEvent("vRP:unsetFactionOffice", player)
		end
		TriggerClientEvent('vrp-hud:updateBottom', player, {name = GetPlayerName(player), faction = 'Civil'});
		TriggerClientEvent("vRP:onFactionChange", player, uFaction)
	else
		local groupUsers = factionMembers[theGroup]
		if groupUsers then
			for i, v in pairs(groupUsers)do
				if (v.id == user_id) then
					factionMembers[theGroup][i] = nil
				end
			end
		end
	end

	exports.oxmysql:execute("UPDATE users SET faction = @faction, rank = @rank WHERE id = @id",{
		['@id'] = user_id,
		['@faction'] = "user",
		['@rank'] = "none"
	})
end

local function ch_inviteFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local members = vRP.getUsersByFaction(theFaction)
	local fSlots = factions[theFaction].fSlots
	if user_id ~= nil then
		vRP.prompt(player,"FACTION INVITE",{
			{field = "id", title = "UTILIZATOR SELECTAT", number = true},
		},function(player,res)
			local id = res['id']

			if id and (id < 1) then
				return
			end

			if tonumber(#members) < tonumber(fSlots) then
				local target = vRP.getUserSource(id)
				if target then
					local name = GetPlayerName(target)
					if vRP.hasUserFaction(id) then
						vRPclient.notify(player, {name.." este deja intr-o factiune!", "error"})
						return
					end

					vRP.request(target, "Jucatorul "..(GetPlayerName(player) or "Necunoscut").." ("..user_id..") te-a invitat in factiunea "..theFaction..", vrei sa intri?", false, function(_, ok)
						if not ok then
							vRPclient.notify(target, {"Ai refuzat invitatia in factiunea "..theFaction, "info"})
							return vRPclient.notify(player, {name.." a refuzat invitatia in factiune!", "warning"})
						end

						vRPclient.notify(player, {"L-ai adaugat pe "..name.." in "..theFaction.."!"})
						vRPclient.notify(target, {"Ai fost adaugat in "..theFaction.." de "..(GetPlayerName(player) or "Necunoscut").."!"})
						vRP.addPanelHistory(tonumber(id), "A fost adaugat in factiunea "..theFaction.." de catre "..GetPlayerName(player), "add")
						vRP.addUserFaction(id, theFaction)
					end)
				else
					vRPclient.notify(player, {"Nu sa gasit nici un jucator online cu ID-ul "..id.."!", "error"})
				end
			else
				vRPclient.notify(player, {"Maximul de jucatori in factiune a fost atins!", "error"})
			end
		end)
	end
end

vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}

		if vRP.hasUserFaction(user_id) then
			local theFaction = vRP.getUserFaction(user_id) or "Civil"
			local rank = vRP.getFactionRank(user_id) or "Unknown"
			local leader = vRP.isFactionLeader(user_id) or false
			local coLeader = vRP.isFactionCoLeader(user_id) or false
			local members = vRP.getUsersByFaction(theFaction) or 0
			local fType = vRP.getFactionType(theFaction) or "Civil"
			local fSlots = vRP.getFactionSlots(theFaction) or 0

			choices["🎩 Faction Menu"] = {function(player,choice)
				vRP.buildMenu(theFaction, {player = player}, function(menu)
					menu.name = theFaction
					menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}

					menu["1. 📋 DESPRE FACTIUNE"] = {function()
						local fInfo = {name = "", css = {top="75px", header_color="rgba(0,125,255,0.75)"}}

						fInfo["1. Nume: "..theFaction] = {}
						fInfo["2. Locuri libere/ocupate: "..#members.."/"..fSlots] = {}
						fInfo["3. Tip factiune: "..fType] = {}
						fInfo["4. DATE DESPRE TINE 📃"] = {}
						fInfo["5. Rank: "..rank] = {}
						vRP.openMenu(player, fInfo)
					end}

					menu["2. 📂 LISTA MEMBRII"] = {function()
						local membersMenu = {name = "", css = {
							top="75px",
							header_color="rgba(0, 125, 255, 0.75"}
						}

						local user_id = vRP.getUserId(player)
						local theFaction = vRP.getUserFaction(user_id)
						local members = vRP.getUsersByFaction(theFaction)

						for i, v in pairs(members or {}) do
							if v.userFaction then
								
								local userID = v.id
								local rank = v.userFaction.rank or "unknown"
								local lLogin = tostring(v.last_login)
								
								local lastLogin = "Eroare"
								for word in lLogin:gmatch("%S+") do
									lastLogin = word
								end
								
								if not lastLogin then
									lastLogin = "Eroare"
								else
									lastLogin = os.date("%d/%m/%Y %H:%M", tonumber(lastLogin))
								end
								
								membersMenu[v.username] = {function(player, choice)
									local usr_id = vRP.getUserId(player)
									local controlMember = {name = "", css = {
										top="75px",
										header_color="rgba(0, 125, 255, 0.75"}
									}

									controlMember["1. USER ID: "..userID] = {}
									controlMember["2. Rang: "..rank] = {}
									controlMember["3. Ultima logare: "..lastLogin] = {}

									if leader or coLeader then
										controlMember["⛔️ SCOATE DIN FACTIUNE"] = {function()
											local target = vRP.getUserSource(userID)
											
											vRP.request(player, ("Esti sigur ca vrei sa-l scoti pe jucatorul %s din factiunea %s?"):format((target and (GetPlayerName(target).." ["..userID.."]") or ("ID "..userID)), theFaction), false, function(_, ok_confirm)
												if ok_confirm then
													local cTime = os.date("%d/%m/%Y %H:%M")

													if target then
														local name = GetPlayerName(target)

														vRPclient.notify(player,{"L-ai scos pe "..name.." din factiunea "..theFaction.." la data de "..cTime, "info", false, "fas fa-user"})
														vRPclient.notify(target,{"Ai fost scos din factiunea "..theFaction.." la data de "..cTime, "info", false, "fas fa-user"})

														vRP.closeMenu(target)
														vRP.removeUserFaction(userID, theFaction)

														vRP.addPanelHistory(tonumber(userID), "A fost scos din factiunea "..theFaction.." de catre "..GetPlayerName(player), "uninvite")
													else
														vRPclient.notify(player,{"L-ai scos pe ID "..userID.." din factiunea "..theFaction.." la data de "..cTime, "info", false, "fas fa-user"})
														vRP.removeUserFaction(userID, theFaction)

														vRP.addPanelHistory(tonumber(userID), "A fost scos din factiunea "..theFaction.." de catre "..GetPlayerName(player), "uninvite")
													end
												end
											end)
										end}

										controlMember["🔰 SCHIMBA RANK"] = {function()
											local actualRank = vRP.getFactionRank(userID)
											local ranks = factions[theFaction].fRanks

											local rankMenu = {name = "", css = {
												top="75px",
												header_color="rgba(0, 125, 255, 0.75"}
											}

											for k, v in pairs(ranks) do
												local rank = v.rank
												rankMenu[rank] = {function(player)
													vRP.setFactionRank(userID, rank, theFaction)
													vRPclient.notify(player, {"Rank-ul "..rank.." a fost setat cu succes!", "info"})
													vRP.closeMenu(player)
												end}
											end
											vRP.openMenu(player, rankMenu)
										end}
									end
									vRP.openMenu(player, controlMember)
								end}
							end
						end

						vRP.openMenu(player, membersMenu)
					end}

					if fType == "Lege" then
						menu["3. 💵 Rankuri & Salarii"] = {function()
							local ranksMenu = {name = "", css = {
								top="75px",
								header_color="rgba(0, 125, 255, 0.75"}
							}

							local ranks = vRP.getFactionRanks(theFaction) or {}
							table.sort(ranks, function(a, b)
								return a.rank:upper() < b.rank:upper()
							end)
							
							for i, v in pairs(ranks) do
								local facRank = v.rank
								local salary = tonumber(v.payday)
								
								ranksMenu[facRank.." 💸 "..vRP.formatMoney(salary)] = {function() end}
							end

							vRP.openMenu(player,ranksMenu)
						end}
					end

					if coLeader or leader then
						menu["✖️ INVITA MEMBRU"] = {ch_inviteFaction}
					end

					vRP.openMenu(player,menu)
				end)
			end}
		end
		add(choices)
	end
end)

RegisterServerEvent("vRP:openFactionChest", function(x)
	local user_id = vRP.getUserId(source)

	if x ~= "Marabunta Grande" then
		return vRP.banPlayer(0, user_id, -1, 'Injection detected [vrp][faction_chest]')
	end

	if vRP.hasUserFaction(user_id) then
		local theFaction = vRP.getUserFaction(user_id)
		local factionType = vRP.getFactionType(theFaction)

		if factionType == "Mafie" then
			vRP.openChest(source, "chest:fChest_"..theFaction, 10000,"Cufar",false)
		end
	end
end)

RegisterServerEvent("vRP:openFactionStore", function(storeType)
	local user_id = vRP.getUserId(source)
	local theFaction = vRP.getUserFaction(user_id) or "user"
	
	if theFaction ~= "user" then
		local fOffice = vRP.getFactionOffice(theFaction)

		if storeType == "weapon" then
			if not fOffice.weaponPack then
				return vRPclient.notify(source, {"Factiunea ta nu detine un pachet de arme activ!", "error"})
  			end

  			local weaponsPack = fWeaponPacks[fOffice.weaponPack]
		    print(fOffice.weaponPack)
  			if weaponsPack then
  				TriggerClientEvent("vRP:openFactionStore", source, "weapon", weaponsPack, theFaction)
  			end
  		elseif storeType == "heal" then
  			if not fOffice.healPack then
  				return vRPclient.notify(source, {"Factiunea ta nu detine pachetul de utilitati!", "error"})
  			end

			TriggerClientEvent("vRP:openFactionStore", source, "heal", fHealPack, theFaction)
		end
	end
end)
AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(5000)
		local uFaction = vRP.getUserFaction(user_id)

		if (uFaction or "user") ~= "user" then
			local fType = vRP.getFactionType(uFaction)
			local fOffice = vRP.getFactionOffice(uFaction)

			if fType == "Mafie" and next(fOffice) ~= nil then
				TriggerClientEvent("vRP:setFactionOffice", player, fOffice)
			end
		end

		TriggerClientEvent("vRP:onFactionChange", player, uFaction)
	end
end)

AddEventHandler("vRP:playerJoin", function(user_id, source, name, extraData)
	Citizen.Wait(5000)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		local rows = exports.oxmysql:querySync('SELECT `faction`, `rank`, `leader` FROM users WHERE id = '..user_id)
    	if #rows > 0 then
			--local userFaction = extraData.userFaction or {faction = "user", rank = "none"}

			Citizen.CreateThread(function()
				TriggerClientEvent("discord:setUserData", source, user_id, (rows[1].faction ~= "user" and rows[1].faction or nil))
			end)

			if factions[rows[1].faction] or rows[1].faction == "user" then
				tmp.fName = rows[1].faction
				tmp.fRank = rows[1].rank
				tmp.fLeader = rows[1].leader
			elseif rows[1].faction ~= "user" then
				vRP.removeUserFaction(user_id, rows[1].faction, 0)
			end
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	memberDuty[user_id] = nil
end)

local function ch_addfaction(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"SET FACTION",{
			{field = "id", title = "UTILIZATOR SELECTAT", number = true},
			{field = "group", title = "FACTIUNE"},
			{field = "lider", title = "STATUT (0-1-2)", text = "0 = membru | 1 = co-lider | 2 = lider"},
		},function(player,res)
			local id = res["id"]
			local group = res["group"]
			local lider = res["lider"]

			if factions[group] then
				local members = vRP.getUsersByFaction(group)
				local fSlots = factions[group].fSlots

				if fSlots > #members or user_id <= 3 then
					local theTarget = vRP.getUserSource(id)

					if theTarget then
						local name = GetPlayerName(theTarget)
						if(lider == 2) then
							vRP.addUserFaction(id,group)
							Citizen.Wait(500)

							vRP.setFactionLeader(id,group,2)
							vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat ca lider in factiunea "..group})

							vRP.addPanelHistory(tonumber(id), "A fost adaugat in calitate de Lider in Factiunea "..group.." de catre "..GetPlayerName(player), "add")
							return								
						elseif(lider == 1) then
							vRP.addUserFaction(id,group)
							Citizen.Wait(500)

							vRP.setFactionLeader(id,group,1)
							vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat ca si colider in factiunea "..group})

							vRP.addPanelHistory(tonumber(id), "A fost adaugat in calitate de Co-Lider in Factiunea "..group.." de catre "..GetPlayerName(player), "add")
							return
						else
							vRP.addUserFaction(id,group)
							vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat in factiunea "..group})

							vRP.addPanelHistory(tonumber(id), "A fost adaugat in Factiunea "..group.." de catre "..GetPlayerName(player), "add")
						end
					else
						vRPclient.notify(player, {"Utilizatorul selectat nu este conectat pe server.", "error"})
					end
				else
					vRPclient.notify(player, {"Factiunea nu are locuri disponibile!", "error"})
				end
			else
				vRPclient.notify(player, {"Factiunea este inexistenta!", "error"})
			end
		end)
	end
end

local function ch_removefaction(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"UNSET FACTION",{
			{field = "id", title = "UTILIZATOR SELECTAT", number = true},
		},function(player, res)
			local target_id = res["id"]
			if not target_id then return end

			local target_faction = vRP.getUserFaction(target_id)
			if target_id == 0 then
				return
			end

			if target_faction ~= "user" then
				local target = vRP.getUserSource(target_id)
				if target then
					local name = GetPlayerName(target)
					vRPclient.notify(player, {"L-ai scos pe "..name.." din factiunea "..target_faction.."!", "info", false, "fas fa-user"})
					vRPclient.notify(target, {"Ai fost scos din factiunea "..target_faction.."!", "info", false, "fas fa-user"})

					vRP.closeMenu(target)
					
					vRP.removeUserFaction(target_id,target_faction)
					TriggerClientEvent('vrp-hud:updateBottom', player, {name = GetPlayerName(player), faction = 'Civil'});
					vRP.addPanelHistory(tonumber(id), "A fost scos din Factiunea "..target_faction.." de catre "..GetPlayerName(player), "uninvite")
				else
					vRPclient.notify(player,{"L-ai scos pe ID "..target_id.." din factiunea "..target_faction.."!", "info", false, "fas fa-user"})
					vRP.removeUserFaction(target_id,target_faction)

					vRP.addPanelHistory(tonumber(id), "A fost scos din Factiunea "..target_faction.." de catre "..GetPlayerName(player), "uninvite")
				end
			else
				vRPclient.notify(player, {"Jucatorul nu face parte din nici o factiune", "error"})
			end
		end)
	end
end

local function ch_factionleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"FACTION LEADER",{
			{field = "id", title = "UTILIZATOR SELECTAT", number = true},
		},function(player,res)
			local id = res["id"]
			if not id then return end

			local theTarget = vRP.getUserSource(id)
			if not theTarget then
				return vRPclient.notify(player, {"Jucatorul nu este conectat!"})
			end

			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)

			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul nu este in nici o factiune!", "error"})
			else
				vRP.setFactionLeader(id,theFaction,2)
				vRPclient.notify(player,{name.." a fost adaugat ca lider in factiunea "..theFaction})

				vRP.addPanelHistory(id, "A fost adaugat in calitate de Lider in Factiunea "..theFaction.." de catre "..GetPlayerName(player), "add")
			end
		end)
	end
end

local function ch_factioncoleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"FACTION COLEADER",{
			{field = "id", title = "UTILIZATOR SELECTAT", number = true},
		},function(player,res)
			local id = res["id"]
			if not id then return end

			local theTarget = vRP.getUserSource(id)
			if not theTarget then
				return vRPclient.notify(player, {"Jucatorul nu este conectat!"})
			end

			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)

			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul nu este in nici o factiune!", "error"})
			else
				vRP.setFactionLeader(id,theFaction,1)
				vRPclient.notify(player,{name.." a fost adaugat ca si co-lider in factiunea "..theFaction})

				vRP.addPanelHistory(tonumber(id), "A fost adaugat in calitate de Co-Lider in Factiunea "..theFaction.." de catre "..GetPlayerName(player), "add")
			end
		end)
	end
end

local function ch_createFaction(player, choice)
	vRP.prompt(player,"CREATE FACTION",{
		{field = "faction", title = "NUME FACTIUNE"},
		{field = "slots", title = "SLOTURI", number = true},
		{field = "coords", title = "COORDS SEDIU"},
		{field = "chestCoords", title = "COORDS CUFAR"},
		{field = "healPack", title = "COORDS HEALTH PACH", text='0 == FALSE | COORDS == TRUE'},
		{field = "weaponPack", title = "WEAPONS PACK", number = true},
	},function(player,res)
		local numeFactiune = res["faction"]
		local slots = res["slots"]
		local color = 4
		local fcoords = res["coords"]
		local factionChest = res["chestCoords"]
		local fhealthCoords = res["healPack"]
		local weaponPack = res["weaponPack"]

		if fhealthCoords == "0" then
			local coords = {}
			for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
				table.insert(coords,tonumber(coord))
			end
			local x,y,z = 0,0,0
			if coords[1] then
				x = coords[1]
			end
			if coords[2] then
				y = coords[2]
			end
			if coords[3] then
				z = coords[3]
			end

			local chestCoords = {}
			for coord in string.gmatch(factionChest or "0,0,0","[^,]+") do
				table.insert(chestCoords,tonumber(coord))
			end
			local cx,cy,cz = 0,0,0
			if chestCoords[1] then
				cx = chestCoords[1]
			end
			if chestCoords[2] then
				cy = chestCoords[2]
			end
			if chestCoords[3] then
				cz = chestCoords[3]
			end

			local newFaction = {
				name = numeFactiune,
				type = "Mafie",
				slots = slots,
				color = color,
				blip = 310,
				ranks = {
					[1] = {
						rank = "Membru",
						payday = 0,
					},
					[2] = {
						rank = "Co-Lider",
						payday = 0,
					},
					[3] = {
						rank = "Lider",
						payday = 0,
					},
				},
				home = {
					[1] = x,
					[2] = y,
					[3] = z,
				},
				office = {
					healPack = false,
					chestPos = {
						[1] = cx,
						[2] = cy,
						[3] = cz,
					},
					healPos = {
						[1] = 0,
						[2] = 0,
						[3] = 0,
					},
					weaponPack = weaponPack,
				}
			}
			exports.oxmysql:execute("INSERT INTO factions (name,type,slots,color,ranks,home,office, blip) VALUES(@name,@type,@slots,@color,@ranks,@home,@office, @blip)",{
				['@name'] = newFaction.name,
				['@type'] = newFaction.type,
				['@slots'] = newFaction.slots,
				['@color'] = newFaction.color,
				['@ranks'] = json.encode(newFaction.ranks),
				['@home'] = json.encode(newFaction.home),
				['@office'] = json.encode(newFaction.office),
				['@blip'] = json.encode(newFaction.blip)
			})
			vRPclient.notify(player,{"Factiunea a fost creata cu succes!", "info"})
		else
			local coords = {}
			for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
				table.insert(coords,tonumber(coord))
			end
			local x,y,z = 0,0,0
			if coords[1] then
				x = coords[1]
			end
			if coords[2] then
				y = coords[2]
			end
			if coords[3] then
				z = coords[3]
			end

			local chestCoords = {}
			for coord in string.gmatch(factionChest or "0,0,0","[^,]+") do
				table.insert(chestCoords,tonumber(coord))
			end
			local cx,cy,cz = 0,0,0
			if chestCoords[1] then
				cx = chestCoords[1]
			end
			if chestCoords[2] then
				cy = chestCoords[2]
			end
			if chestCoords[3] then
				cz = chestCoords[3]
			end

			local healCoords = {}
			for coord in string.gmatch(fhealthCoords or "0,0,0","[^,]+") do
				table.insert(healCoords,tonumber(coord))
			end
			local hx,hy,hz = 0,0,0
			if healCoords[1] then
				hx = healCoords[1]
			end
			if healCoords[2] then
				hy = healCoords[2]
			end
			if healCoords[3] then
				hz = healCoords[3]
			end

			local newFaction = {
				name = numeFactiune,
				type = "Mafie",
				slots = slots,
				color = color,
				ranks = {
					[1] = {
						rank = "Membru",
						payday = 0,
					},
					[2] = {
						rank = "Co-Lider",
						payday = 0,
					},
					[3] = {
						rank = "Lider",
						payday = 0,
					},
				},
				home = {
					[1] = x,
					[2] = y,
					[3] = z,
				},
				office = {
					healPack = true,
					chestPos = {
						[1] = cx,
						[2] = cy,
						[3] = cz,
					},
					healPos = {
						[1] = hx,
						[2] = hy,
						[3] = hz,
					},
					weaponPack = weaponPack,
				}
			}
			exports.oxmysql:execute("INSERT INTO factions (name,type,slots,color,ranks,home,office, blip) VALUES(@name,@type,@slots,@color,@ranks,@home,@office,@blip)",{
				['@name'] = newFaction.name,
				['@type'] = newFaction.type,
				['@slots'] = newFaction.slots,
				['@color'] = newFaction.color,
				['@ranks'] = json.encode(newFaction.ranks),
				['@home'] = json.encode(newFaction.home),
				['@office'] = json.encode(newFaction.office),
				['@blip'] = json.encode(newFaction.blip)
			})
			vRPclient.notify(player,{"Factiunea a fost creata cu succes!", "info"})
		end
		SetTimeout(1000, function()
			ExecuteCommand('loadFactions')
		end)
	end)
end

vRP.registerMenuBuilder("adminUtilities", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		
		if vRP.isUserAdministrator(user_id) then
			choices["🪖 FACTION MANAGEMENT"] = {function(player)
				local fManagementMenu = {name = "", css = {top="75px", header_color="rgba(0,125,255,0.75)"}}

				fManagementMenu["Adauga in Factiune"] = {ch_addfaction}
				fManagementMenu["Adauga Lider Factiune"] = {ch_factionleader}
				fManagementMenu["Adauga Co-Lider Factiune"] = {ch_factioncoleader}
				fManagementMenu["Scoate din Factiune"] = {ch_removefaction}
				fManagementMenu["Creaza Factiune"] = {ch_createFaction}
				vRP.openMenu(player, fManagementMenu)
			end}
		end

		add(choices)
	end
end)

--- -- Utils -- Functions -- ---
function tvRP.setFactionDuty()
	local user_id = vRP.getUserId(source)
	local theFaction = vRP.getUserFaction(user_id)
	if theFaction ~= "user" then
		local fType = vRP.getFactionType(theFaction)
		if fType ~= "Lege" then
			return false
		end

		if not memberDuty[user_id] then
			vRPclient.notify(source, {"Te-ai pus Off Duty!"})
			memberDuty[user_id] = true

			if vRP.isUserPolitist(user_id) or vRP.isUserMedic(user_id) then
				vRPclient.clearWeapons(source, {})
			end
		else
			memberDuty[user_id] = nil
			vRPclient.notify(source, {"Te-ai pus On Duty!", "success"})
		end
	end
end

function vRP.doFactionFunction(faction, fnct, exceptSrc)
	if not exceptSrc then exceptSrc = 0 end
	local members = vRP.getUsersByFaction(faction)
	for k, v in pairs(members) do
		local memberId = v.id
		local src = vRP.getUserSource(memberId)

		if src then
			if src ~= exceptSrc and not memberDuty[memberId] then
				fnct(src)
			end
		end
	end
end

function vRP.doFactionTypeFunction(ftype, fnct, exceptFaction)
	if not exceptFaction then exceptFaction = "" end
	for i, v in pairs(factions) do
		if tostring(i) ~= exceptFaction then
			if v.fType == ftype then
				vRP.executaPentruFactiune(tostring(i), function(src)
					fnct(src)
				end)
			end
		end
	end
end

vRP.executaPentruFactiune = vRP.doFactionFunction
vRP.executaPentruFType = vRP.doFactionTypeFunction