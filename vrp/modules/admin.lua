local titles = { "Helper in Teste", "Helper", "Helper Avansat", "Moderator", "Super Moderator", "Lider Moderator", "Administrator", "Super Admin", "Supervizor", "Head Of Staff", "Co-Fondator", "Fondator", "Manager", "Ryde Regal", "Co-Owner", "Owner Ryde","Developer"}
local coloredTitles = {"^gHelper in Teste", "^2Helper", "^2Helper Avansat", "^tModerator", "^tSuper Moderator", "^tLider Moderator", "^3Administrator", "^5Super Admin", "^5Supervizor", "^1Head Of Staff", "^5Co-Fondator", "^2Fondator", "^5Manager", "^1Ryde Regal", "^3Co-Owner", "^1Owner Ryde", "Developer"}
local adminCalls = {}
local lastTk = {}
local activeTickets = 0

--[[
	Admin Levels
	1: Trial Helper
	2: Helper
	3: Helper Avansat
	4: Moderator
	5: Super Moderator
	6: Lider Moderator
	7: Admin
	8: Super Admin
	9: Supervizor
	10: Head Of Staff
	11: Co-Fondator
	12: Fondator
	13: Manager 
	14: Ryde Regal
	15: Co-Owner
	16: Owner Ryde
]]

function vRP.setUserAdminLevel(user_id,admin)
	local source = vRP.getUserSource(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		tmp.adminLevel = admin
	end
	exports.oxmysql:execute("UPDATE users SET adminLvl = @adminLvl WHERE id = @id",{
		['@id'] = user_id,
		['@adminLvl'] = admin
	})

	if admin > 0 and source then
		local sx = staffUsers[user_id]

		if not sx then
			staffUsers[user_id] = {lvl = admin, src = source}
		else
			staffUsers[user_id].lvl = admin
		end
	elseif staffUsers[user_id] then
		staffUsers[user_id] = nil
	end
end

function vRP.getUserAdminLevel(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	if tmp then
		adminLevel = tmp.adminLevel
	end
	return adminLevel or 0
end

function vRP.getUserAdminTitle(user_id)
    local text = titles[vRP.getUserAdminLevel(user_id)] or "Helper in Teste"
    return text
end

function vRP.getUserColoredAdminTitle(user_id)
    local text = coloredTitles[vRP.getUserAdminLevel(user_id)] or "^2Helper in Teste"
    return text
end

function vRP.getAdminTitle(rank)
	return titles[rank] or "Helper in Teste"
end

function vRP.getColoredAdminTitle(rank)
	return coloredTitles[rank] or "^2Helper in Teste"
end

function vRP.getAdminTitles()
	return titles
end

function vRP.isUserStaffMember(user_id)
	return staffUsers[user_id] ~= nil
end

function vRP.isUserTrialHelper(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 1)then
		return true
	else
		return false
	end
end

function vRP.isUserHelper(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 2)then
		return true
	else
		return false
	end
end

function vRP.isUserHelperAvansat(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 3)then
		return true
	else
		return false
	end
end

function vRP.isUserMod(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 4)then
		return true
	else
		return false
	end
end

function vRP.isUserSuperMod(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 5)then
		return true
	else
		return false
	end
end

function vRP.isUserLiderMod(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 6)then
		return true
	else
		return false
	end
end


function vRP.isUserAdministrator(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 7)then
		return true
	else
		return false
	end
end

function vRP.isUserSuperAdministrator(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 8)then
		return true
	else
		return false
	end
end

function vRP.isUserSupervizor(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 9)then
		return true
	else
		return false
	end
end

function vRP.isUserHeadOfStaff(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 10)then
		return true
	else
		return false
	end
end

function vRP.isUserCoFondator(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 11)then
		return true
	else
		return false
	end
end

function vRP.isUserFondator(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 12)then
		return true
	else
		return false
	end
end

function vRP.isUserManager(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 13)then
		return true
	else
		return false
	end
end

function vRP.isUserRydeRegal(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 14)then
		return true
	else
		return false
	end
end

function vRP.isUserCoOwner(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 15)then
		return true
	else
		return false
	end
end

function vRP.isUserOwner(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 16)then
		return true
	else
		return false
	end
end

function vRP.isUserDeveloper(user_id)
	local adminLevel = vRP.getUserAdminLevel(user_id)
	if(adminLevel >= 17)then
		return true
	else
		return false
	end
end


function vRP.countOnlineStaff()
    local online = 0
    local users = vRP.getStaffUsers()

    for uid, udata in pairs(users) do
    	online = online + 1
    end

    return online
end

function vRP.doStaffFunction(minAdminLvl, cb)
    if not minAdminLvl then
    	minAdminLvl = 1
    end
  
    local users = vRP.getStaffUsers()
    for uid, udata in pairs(users) do
        if udata.lvl >= minAdminLvl then
            cb(udata.src)
        end
    end
end

vRP.executaPentruStaff = vRP.doStaffFunction

function vRP.sendStaffMessage(msg, minLvl)
	if not minLvl then
		minLvl = 1
	end

    vRP.doStaffFunction(minLvl, function(src)
        TriggerClientEvent("chatMessage", src, msg)
    end)
end

function tvRP.tryNoclipToggle(src)
	if not src then src = source end
    local user_id = vRP.getUserId(src)
    
    if vRP.isUserMod(user_id) then
        vRPclient.toggleNoclip(src, {})
    end
end

local function checkTickets()
	if activeTickets < 0 then
		activeTickets = 0
	end
	local users = vRP.getUsers()
	for user_id, source in pairs(users) do
		if vRP.getUserAdminLevel(user_id) > 0 then
			TriggerClientEvent("vRP:setTicketsAmm", source, activeTickets)
		else
			TriggerClientEvent("vrp_hud:hidetickets", source)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Wait(2000)
		checkTickets()
	end
end)

local function updateTickets()
	local expiredOne = false

	for ticketId, ticketData in pairs(adminCalls) do
		if ticketData.expire <= os.time() then
			adminCalls[ticketId] = nil
			expiredOne = true
			activeTickets = activeTickets - 1

			vRPclient.notify(ticketData.player, {"Ticketul tau a expirat, in cazul in care mai ai nevoie de ajutor, poti face un alt ticket!", "warning", false, "fas fa-ticket"})
		end
	end

	if expiredOne then
		checkTickets()
	end

	SetTimeout(60000, updateTickets)
end
updateTickets()

local function ch_answerTicket(source, user_id, ticket)
	local ticketData = adminCalls[ticket]
	if not vRP.isUserTrialHelper(user_id) then
		return vRPclient.denyAcces(source, {})
	end

	if ticketData then
		adminCalls[ticket] = nil
		activeTickets = activeTickets - 1
		checkTickets()

		local adminUsername = GetPlayerName(source)
		local targetSrc = ticketData.player
		ticketData.username = GetPlayerName(targetSrc)

		vRPclient.getPosition(targetSrc, {}, function(x, y, z)
			vRPclient.teleport(source, {x, y, z})
			vRPclient.notify(targetSrc, {adminUsername.." ti-a preluat ticketul, explica-i problema intampinata!", "info", false, "fas fa-ticket"})
			vRP.sendStaffMessage("^5Tickets: ^7Ticketul lui ^5"..ticketData.username.." ^7(^5"..ticket.."^7) a fost luat de ^5"..adminUsername, 3)

			local userWorld = GetPlayerRoutingBucket(targetSrc)
        	SetPlayerRoutingBucket(source, userWorld)

        	vRPclient.msg(source, {"^5Tickets: ^7Ai preluat ticketul lui ^5"..ticketData.username.." ^7[^5"..ticket.."^7].\nPentru a te intoarce la ticket foloseste comanda ^5/lasttk"})
        	lastTk[user_id] = ticket
		end)
	end
end

local function openTicketsMenu(source, user_id)
	vRP.buildMenu('currentTickets', {player = source}, function(menu)
		menu.onclose = function(player)
			vRP.closeMenu(player)
		end

		local ticketId = 0
		for theUser, ticketData in pairs(adminCalls) do
			if GetPlayerName(ticketData.player) then
				ticketId = ticketId + 1
				local username = GetPlayerName(ticketData.player).." ("..theUser..")"

				menu["#"..ticketId.." - "..username] = {function()
					ch_answerTicket(source, user_id, theUser)
					vRP.closeMenu(source)
				end}
			end
		end

		if ticketId == 0 then
			menu["Nu sunt tickete momentan."] = {function() end}
		end

		vRP.openMenu(source,menu)
	end)
end

local TicketsCooldown = {}
local function ch_calladmin(source)
	local user_id = vRP.getUserId(source)

	if vRP.isUserTrialHelper(user_id) then
		return openTicketsMenu(source, user_id)
	end

	if TicketsCooldown[user_id] then
		if TicketsCooldown[user_id] > os.time() then
			return vRPclient.notify(source, {"Asteapta "..math.floor(TicketsCooldown[user_id] - os.time()).." secunde pana sa poti face alt ticket!", "warning", false, "fas fa-ticket"})
		end
	end

	if not adminCalls[user_id] then
		adminCalls[user_id] = {
			player = source,
			expire = os.time() + 120,
		}

		TicketsCooldown[user_id] = os.time() + 120

		activeTickets = activeTickets + 1
		checkTickets()

		vRPclient.notify(source, {"Ai facut un ticket, acesta expira la " ..os.date("%H:%M:%S", adminCalls[user_id].expire).." (120 sec.)", "info", false, "fas fa-ticket"})
	elseif adminCalls[user_id].expire <= os.time() then
		adminCalls[user_id] = nil
		
		activeTickets = activeTickets - 1
		checkTickets()

		TicketsCooldown[user_id] = os.time() + 120

		Citizen.CreateThread(function()
			Citizen.Wait(200)
			ch_calladmin(source)
		end)
	else
		vRPclient.notify(source, {"Ai un ticket activ, trebuie sa mai astepti "..(adminCalls[user_id].expire - os.time()).." (de) secunde pentru a face un alt ticket!", "warning", false, "fas fa-ticket"})
	end
end

RegisterCommand("canceltk", function(source)
	local user_id = vRP.getUserId(source)

	if adminCalls[user_id] then
		adminCalls[user_id] = nil
		activeTickets = activeTickets - 1
		checkTickets()

		vRPclient.notify(source, {"Ai anulat ticketul!", "info", false, "fas fa-ticket"})
	end
end)

local function ch_tptocoords(source)
	local user_id = vRP.getUserId(source)
	if vRP.isUserAdministrator(user_id) then
       	vRP.prompt(source,"TELEPORT TO COORDS",{{field = "fcoords", title = "Coordonate"}},function(player,responses)
			local fcoords = responses["fcoords"]
       		
			if not fcoords then
				return false
			end

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
       	
       	    vRPclient.teleport(player,{x,y,z})
       	end)
	else
		vRPclient.denyAcces(source)
	end
end

local canUseWeapons = true
local function ch_toggleWeaps(player, choice)
	canUseWeapons = not canUseWeapons
	vRPclient.toggleAllWeapons(-1, {canUseWeapons})

	if not canUseWeapons then
		vRPclient.notify(-1, {"Un administrator a dezactivat folosirea armelor!", "warning", false, "fas fa-gun"})
	else
		vRPclient.notify(-1, {"Un administrator a activat folosirea armelor!", "info", false, "fas fa-gun"})
	end
end

local function ch_coords(player)
	local user_id = vRP.getUserId(player)
	if vRP.isUserTrialHelper(user_id) then
      	vRPclient.getPosition(player,{},function(x,y,z)

			vRP.prompt(player,"COPY COORDS",{{field = "worldcds", title = "Foloseste CTRL-A + CTRL-C", text = (x..","..y..","..z)}},function(player,responses)
			end)
      	end)
    else
      	vRPclient.denyAcces(player)
	end
end

local function ch_creategarage(player)
	local user_id = vRP.getUserId(player)
	if vRP.isUserDeveloper(user_id) then
		vRP.prompt(player, "CREATE GARAGE", {{field = "type", title = "Tip garaj creat"}}, function(_, responses)
			local tipGaraj = responses["type"]

			if tipGaraj then
				vRPclient.getPosition(player, {}, function(x,y, z)
					vRP.createGarage(player, x, y, z, tipGaraj)
				end)
			end
		end)
	else
		vRPclient.notify(player, {"Nu poti creea garaje.", "error"})
	end
end

local function ch_createmarket(player)
	local user_id = vRP.getUserId(player)
	if vRP.isUserDeveloper(user_id) then
		vRP.prompt(player, "CREATE MARKET", {{field = "type", title = "Tip magazin creat"}}, function(_, responses)
			local tipMagazin = responses["type"]

			if tipMagazin then
				vRPclient.getPosition(player, {}, function(x,y, z)
					vRP.createMarket(player, x, y, z, tipMagazin)
				end)
			end
		end)
	else
		vRPclient.notify(player, {"Nu poti creea magazine.", "error"})
	end
end

local function ch_alertPlayers(player)
	local user_id = vRP.getUserId(player)
	if vRP.isUserTrialHelper(user_id) then
		vRP.prompt(player, "ADMIN ANNOUNCEMENT", {{field = "message", title = "Mesaj anunt"}}, function(_, responses)
			local alert_message = responses["message"]

			if alert_message then
				local admin_name = GetPlayerName(player)
				local alert_message = tostring(alert_message)
				
				TriggerClientEvent("vRP:adminAnnouncement", -1, admin_name:upper(), alert_message)
			end
		end)
	else
		vRPclient.notify(player, {"Nu poti folosii anunturile adminilor!", "error"})
	end
end

local function ch_giveStats(player)
	local user_id = vRP.getUserId(player)
	vRP.setHunger(user_id,0)
	vRP.setThirst(user_id,0)
	vRPclient.notify(player,{"Ai primit 100% foame si sete.", "info"})
end

local function ch_giveitem(player)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then

		vRP.prompt(player, "GIVE ITEM", {
			{field = "target_id", title = "UTILIZATOR SELECTAT", number = true},
			{field = "idname", title = "ITEM OFERIT"},
			{field = "amount", title = "SUMA OFERITA", number = true},
		}, function(player, responses)

			local target_id = responses["target_id"]
			local idname = responses["idname"]
			local amount = responses["amount"]

			if not target_id or not idname or not amount then
				return false
			end

			local target_src = vRP.getUserSource(target_id)
			if target_src then
				vRP.giveInventoryItem(target_id, idname, amount, true)
				local itemName = vRP.getItemName(idname)
				--vRP.createLog(user_id, "A oferit jucatorului cu id "..target_id.." din Give Item "..amount.." "..itemName, "AdminActions", "Give-Item", "fa-solid fa-bag-shopping", 0, "info");
				--vRP.createLog(target_id, "A primit din Give Item "..amount.." "..itemName.." de la Adminul "..GetPlayerName(player).."("..user_id..")", "Items", "Receive-Admin", "fa-solid fa-bag-shopping", 0, "info")

				vRPclient.notify(player, {idname.." ("..amount..") a fost adaugat in invetar la ID-ul "..target_id.." (online)", "info"})
			else -- offline
				exports.oxmysql:query("SELECT dvalue FROM uData WHERE user_id = @user_id AND dkey = @dkey",{['@user_id'] = target_id,['@dkey'] = "vRP:datatable"}, function(result)
					if result[1] then
						local val = json.decode(result[1].dvalue)

						if not val.inventory then
							val.inventory = {}
						end
						
						if val.inventory[idname] then
							val.inventory[idname].amount = (val.inventory[idname].amount or 0) + amount
						else
							val.inventory[idname] = {amount = amount}
						end
						
						exports.oxmysql:execute("UPDATE uData SET dvalue = @dvalue WHERE user_id = @user_id AND dkey = @dkey",{
							['@user_id'] = target_id,
							['@dkey'] = "vRP:datatable",
							['@dvalue'] = json.encode(val)
						})

						local itemName = vRP.getItemName(idname)
						--vRP.createLog(user_id, "A oferit jucatorului cu id "..target_id.." din Give Item "..amount.." "..itemName, "AdminActions", "Give-Item", "fa-solid fa-bag-shopping", 0, "info");
						--vRP.createLog(target_id, "A primit din Give Item "..amount.." "..itemName.." de la Adminul "..GetPlayerName(player).."("..user_id..")", "Items", "Receive-Admin", "fa-solid fa-bag-shopping", 0, "info")
						vRPclient.notify(player, {idname.." ("..amount..") a fost adaugat in invetar la ID-ul "..target_id.." (offline)", "info"})
					end
				end)
			end
		end)
	end
end

local function ch_unjailPlayer(player)
	local user_id = vRP.getUserId(player)
	vRP.prompt(player, "ADMIN UNJAIL", {{field = "target_id", title = "UTILIZATOR SELECTAT", number = true}}, function(_, results)
		local target_id = results["target_id"]

		if target_id then
			local target = vRP.getUserSource(tonumber(target_id))
			if target then
				vRPclient.sendInfo(-1, {("Adminul ^5%s (%d) ^7i-a scos jailul lui ^5%s (%d)"):format(GetPlayerName(player), user_id, GetPlayerName(target), target_id)})
				vRP.removeUserAjail(target_id)
				vRPclient.teleport(target, {-490.65594482422,-691.13708496094,33.21192932129})
			end
		end
	end)
end

local function ch_jailPlayer(player)
	vRP.prompt(player, "ADMIN JAIL", {
		{field = "target_id", title = "UTILIZATOR SACTIONAT", number = true},
		{field = "trees", title = "NR. DE COPACI", number = true},
		{field = "reason", title = "MOTIVUL SANCTIUNII"},
	}, function(_, results)

		local target_id = results["target_id"]
		local durata = results["trees"]
		local motiv = results["reason"]

		if target_id and durata and motiv then
			local adminId = vRP.getUserId(player)

			if durata > 0 then
				vRP.setInAdminJail(target_id, durata, player, motiv)
				exports.oxmysql:execute("INSERT INTO punishLogs (user_id,time,type,text) VALUES(@user_id,@time,@type,@text)",{
					['@user_id'] = tonumber(target_id),
					['@time'] = os.time(),
					['@type'] = "jail",
					['@text'] = "A primit Admin Jail "..durata.."CP de la"..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv
				})
			end

		end
	end)
end

local function ch_banPlayer(player)
	vRP.prompt(player, "BAN PLAYER", {
		{field = "target_id", title = "UTILIZATOR SELECTAT", number = true},
		{field = "durata", title = "DURATA BANULUI (-1 = permanent)", number = true},
		{field = "reason", title = "MOTIVUL BANULUI"},
		{field = "canPay", title = "DREPT DE PLATA (0 - Da / 1 - Nu)"},
	}, function(_, results)

		local target_id = results["target_id"]
		local durata = results["durata"]
		local motiv = results["reason"]
		local canPay = results["canPay"]

		if target_id and durata and motiv and canPay then
			local adminId = vRP.getUserId(player)
			local drept = (canPay ~= "1")
			local textpermanent = "A primit Ban Permanent de la"..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv..""
			local texttemporar = "A primit Ban Temporar timp de "..durata.." zile de la"..GetPlayerName(player).." ("..adminId.."). Motiv: "..motiv..""
					
			if(durata > 0)then
				vRP.banPlayer(adminId, target_id, durata, motiv, drept)
				exports.oxmysql:execute("INSERT INTO punishLogs (user_id,time,type,text) VALUES(@user_id,@time,@type,@text)",{
					['@user_id'] = tonumber(target_id),
					['@time'] = os.date("%d/%m/%Y : %H:%M:%S"),
					['@type'] = "ban",
					['@text'] = json.encode(texttemporar)
				})
			elseif(durata == -1)then
				vRP.banPlayer(adminId, target_id, -1, motiv, drept)
				exports.oxmysql:execute("INSERT INTO punishLogs (user_id,time,type,text) VALUES(@user_id,@time,@type,@text)",{
					['@user_id'] = tonumber(target_id),
					['@time'] = os.date("%d/%m/%Y : %H:%M:%S"),
					['@type'] = "banPermanent",
					['@text'] = json.encode(textpermanent)
				})
			end

		end
	end)
end


local function ch_createCreatorCode(player)
	vRP.prompt(player, "CREATE CREATOR CODE", {
		{field = "code", title = "CODE"},
		{field = "creator", title = "ID CREATOR", number = true},
	}, function(_, res)
		local code = res["code"]
		local creator = res["creator"]

		if code and creator then
			exports.oxmysql:execute("INSERT INTO creatorCodes (code,id) VALUES(@code,@id)",{
				['@id'] = creator,
				['@code'] = string.upper(code)
			})
			vRPclient.notify(player, {"Ai creat Creator Code-ul cu success!"})
		end
	end)
end

local function ch_managemap(source)
	local user_id = vRP.getUserId(source)
	vRP.buildMenu('manageMap', {player = source}, function(menu)
		menu.onclose = function(player) end

		menu["🏎️ Creaza Garaj"] = {ch_creategarage}
		menu["🏪 Creaza Magazin"] = {ch_createmarket}

		vRP.openMenu(source,menu)
	end)
end

local function ch_newSprites(player)
	TriggerClientEvent("vRP:showSprites", player)
end

local function ch_adminmenu(source)
	local user_id = vRP.getUserId(source)
	vRP.buildMenu('adminUtilities', {player = source}, function(menu)
		menu.onclose = function(player) end

		menu["🌎 Coordonate"] = {ch_coords}
		menu["📢 Anunt Admin"] = {ch_alertPlayers}

		if vRP.isUserHelper(user_id) then
			menu["⛓  ADMIN JAIL"] = {ch_jailPlayer}
			menu["📸 SPRITES"] = {ch_newSprites}
		end
		
		if vRP.isUserMod(user_id) then
			menu["⛔️ BANEAZA JUCATOR"] = {ch_banPlayer}
			menu["☁️ Noclip ON/OFF"] = {tvRP.tryNoclipToggle}
		end

		if vRP.isUserAdministrator(user_id) then
			menu["🖼  Give Item"] = {ch_giveitem}
			menu["🗺️ TP-Coords"] = {ch_tptocoords}
			menu["🔫 Toggle Arme"] = {ch_toggleWeaps}
			menu["📡 Full Stats"] = {ch_giveStats}
		end

		if vRP.isUserDeveloper(user_id) then
			menu["🗺️ Map Manager"] = {ch_managemap}
			menu["📝 Creaza Creator Code"] = {ch_createCreatorCode}
		end

		vRP.openMenu(source,menu)
	end)
end

vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id ~= nil then
    local choices = {}

    choices[" Admin Ticket "] = {ch_calladmin}

    if vRP.isUserTrialHelper(user_id) then
    	choices[" Admin Utils"] = {ch_adminmenu}
	end

    add(choices)
  end
end)

-- [ADMIN COMMANDS]

local JobSkills = {
	["Electrician"] = {
		[1] = 0,
		[2] = 301,
		[3] = 422,
	},
	["Pescar"] = {
		[1] = 0,
		[2] = 252,
		[3] = 755, 
	},
	["Sofer de Autobuz"] = {
		[1] = 0,
		[2] = 61,
		[3]= 122,
	},
	["Constructor"] = {
		[1] = 0,
		[2] = 202,
		[3] = 502,
	},
	["Taietor de Lemne"] = {
		[1] = 0,
		[2] = 301,
		[3] = 422,
	},
	["Miner"] = {
		[1] = 0,
		[2] = 252,
		[3] = 1001,
	},
}

RegisterCommand("setjobskill", function(player, args)
	local user_id = vRP.getUserId(player)

	if vRP.isUserDeveloper(user_id) then
		if args[1] and args[2] and args[3] then
			local target_id = parseInt(args[1])
			local job = args[2]
			local skill = parseInt(args[3])

			if not JobSkills[job] then
				return vRPclient.notify(player, {"Acest job nu exista!", "error"})
			end

			if not JobSkills[job][skill] then
				return vRPclient.notify(player, {"Acest skill nu exista!", "error"})
			end

			vRP.setUserJobSkill(user_id, job, JobSkills[job][skill])
			vRPclient.notify(player, {"Ai setat skill-ul "..skill.." pentru job-ul "..job.." pentru jucatorul cu ID-ul "..target_id})
		else
			vRPclient.notify(player, {"Comanda este: /setjobskill [id] [job] [skill]", "error"})
		end
	end
end)

RegisterCommand('tptocoords',function(src)
	if src == 0 then return end
	ch_tptocoords(src)
end)

RegisterCommand('coords',function(src)
	if src == 0 then return end
	ch_coords(src)
end)

RegisterCommand("nc",function(source,args)
	if source == 0 then return end
   tvRP.tryNoclipToggle(source)
end)

RegisterCommand("de", function(player)

	local ped = GetPlayerPed(player)
	local pedPos = GetEntityCoords(ped)
	local user_id = vRP.getUserId(player)
  
	if vRP.isUserTrialHelper(user_id) then
  
		vRPclient.getNearestVehicle(player, {3.0, true}, function(vehNetworkId)
			if vehNetworkId then
				local vehicle = NetworkGetEntityFromNetworkId((vehNetworkId == 0) and GetVehiclePedIsIn(ped, false) or vehNetworkId)

				if DoesEntityExist(vehicle) then
					DeleteEntity(vehicle)
					vRPclient.notify(player, {"Vehiculul a fost sters.", "info", false, "fas fa-car"})
				else
			  		vRPclient.notify(player, {"Vehiculul nu poate fi sters.", "error"})
				end
			end
			
		end)
	else
		vRPclient.noAccess(player)  
	end
end)
  
RegisterCommand("dv", function(player)
	vRPclient.executeCommand(player, {"de"})
end)

RegisterCommand("fix", function(source)
	local user_id = vRP.getUserId(source)
	if not vRP.isUserTrialHelper(user_id) then
		return vRPclient.denyAcces(source)
	end

	vRPclient.fixCar(source, {3}, function(fixedOne)
		if fixedOne then
			vRPclient.notify(source, {"Vehiculul a fost reparat.", "info", false, "fas fa-car"})
		else
			vRPclient.notify(source, {"Vehiculul nu a putut fi reparat.", "error"})
		end
	end)
end)

RegisterCommand("dearea", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.isUserTrialHelper(user_id) then
	  local radius = tonumber(args[1])
	  if radius and radius > 0 and radius <= 100 then

		vRPclient.getNearestVehicles(player, {radius}, function(nearestVehciles)
			local deletedEnts = 0
			for _, vehNetworkId in pairs(nearestVehciles) do
				if vehNetworkId and vehNetworkId ~= 0 then 
					local vehicle = NetworkGetEntityFromNetworkId(vehNetworkId)

					if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == 0 then
						DeleteEntity(vehicle)
						deletedEnts += 1
					end
				end
			end

			vRPclient.msg(player, {"^2Succes: ^7Ai sters in total ^1"..deletedEnts.." ^7(de) vehicule."})
		end)
	  else
		vRPclient.sendSyntax(player, {"/dearea <raza (1-100)>"})
	  end
	else
	  vRPclient.noAccess(player)
	end
end)
  
RegisterCommand("dvarea", function(player, args)
	vRPclient.executeCommand(player, {"dearea "..(args[1] or "")})
end)

RegisterCommand("givecar", function(player, args)
	local user_id = vRP.getUserId(player)
	if not vRP.isUserDeveloper(user_id) then return vRPclient.denyAcces(player, {}) end
	if not args[1] or not args[2] or not args[3] then return vRPclient.cmdUse(player, {"/givecar <user_id> <theCar> <vtype>"}) end

	local thePlayer = tonumber(args[1])
	local theCar = tostring(args[2])
	local vtype = tostring(args[3])

	if vRP.isUserDeveloper(user_id) then
		exports.oxmysql:execute("INSERT INTO userVehicles (user_id,vehicle,vtype,state,fuel) VALUES(@user_id,@vehicle,@vtype,@state,@fuel)",{
			['@user_id'] = thePlayer,
			['@vehicle'] = theCar,
			['@vtype'] = vtype,
			['@state'] = 1,
			['@fuel'] = 100
		})
		vRP.addCacheVehicle(thePlayer, {
			user_id = thePlayer,
			vehicle = theCar,
			vtype = vtype,
			state = 1,
			fuel = 100,
		})
		local playerSrc = vRP.getUserSource(thePlayer)
		if playerSrc then
			vRPclient.notify(playerSrc, {("Ai primit vehiculul %s in garaj de la %s [%d]"):format(theCar, GetPlayerName(player), user_id)})
			vRPclient.notify(player, {("I-ai dat vehiculul %s in garaj lui %s [%d]"):format(theCar, GetPlayerName(playerSrc), thePlayer)})
		else
			vRPclient.notify(player, {("I-ai dat vehiculul %s in garaj ID-ului %d"):format(theCar, thePlayer)})
		end
	else
		vRPclient.notify(player, {"Nu poti oferii masini jucatorilor!", "error"})
	end
end)

RegisterCommand("removecar", function(player, args)
	local user_id = vRP.getUserId(player)
	if not vRP.isUserDeveloper(user_id) then return vRPclient.denyAcces(player, {}) end
	if not args[1] or not args[2] then return vRPclient.cmdUse(player, {"/removecar <user_id> <theCar>"}) end

	local thePlayer = tonumber(args[1])
	local theCar = tostring(args[2])

	if vRP.isUserDeveloper(user_id) then
		exports.oxmysql:query("DELETE FROM userVehicles WHERE user_id = @user_id AND vehicle = @vehicle",{
			['@user_id'] = thePlayer,
			['@vehicle'] = theCar
		})
		vRP.removeCacheVehicle(user_id, theCar)

		local playerSrc = vRP.getUserSource(thePlayer)
		if playerSrc then
			vRPclient.notify(playerSrc, {("Ti-a fost stearsa masina %s din garaj de catre %s [%d]"):format(theCar, GetPlayerName(player), user_id)})
			vRPclient.notify(player, {("I-ai sters vehiculul %s din garaj lui %s [%d]"):format(theCar, GetPlayerName(playerSrc), thePlayer)})
		else
			vRPclient.notify(player, {("I-ai sters vehiculul %s din garaj ID-ului %d"):format(theCar, thePlayer)})
		end
	else
		vRPclient.notify(player, {"Nu poti sterge masini jucatorilor!", "error"})
	end
end)

RegisterCommand("staff", function(src)
	local onlineStaff = vRP.countOnlineStaff()
	local msgString = "^7---------- Membrii staff online: ^5"..onlineStaff.."^7 ----------"
	if onlineStaff == 0 then msgString = msgString.."\nNu sunt membrii staff online momentan!" end
	for uid, udata in pairs(vRP.getOnlineStaff()) do
		local name = GetPlayerName(udata.src or 0)

		if name then
			msgString = msgString.."\n^5◈ ^7"..name.." ^5["..uid.."]^7 - "..vRP.getColoredAdminTitle(udata.lvl)
		end
	end
	if src == 0 then return print(msgString.."\n^7--------------------------------------------------") end
	TriggerClientEvent("chatMessage", src, msgString.."\n^7----------------------------------------------------------")
end)

RegisterCommand("tickets", function(source)
	if source == 0 then
		return print("In acest moment sunt ^5"..activeTickets.." ^7tickete active.")
	end

	local user_id = vRP.getUserId(source)
	if not vRP.isUserTrialHelper(user_id) then
		return vRPclient.denyAcces(source, {})
	end

	local ticketsList = "^7---------- Tickete disponibile: ^5"..activeTickets.."^7 ----------\n"
	local theTicket = 0
	local cTime = os.time()

	for ticketId, ticketData in pairs(adminCalls) do
		theTicket = theTicket + 1
		local expireTime = ticketData.expire

		if expireTime > cTime then
			ticketsList = ticketsList.."^5◈ "..theTicket..": ^7"..GetPlayerName(ticketData.player).." ^7[^5"..ticketId.."^7] - Expira in: ^3"..(expireTime - cTime).." secunde\n^5◈ ^7Pentru a-l prelua foloseste: ^3/tk <"..ticketId..">\n"
		end
	end

	if theTicket == 0 then
		ticketsList = ticketsList.."^1◈ Nu sunt tickete active acum. :("
		ticketsList = ticketsList.."\n^7---------- ---------- ------------ ---------- ----------\n^5Info: ^7Pentru a prelua un ticket aleatoriu foloseste comanda ^5/tk\n^5Info: ^7iar pentru a prelua un ticket specific foloseste ^5/tk <id>"
	else
		ticketsList = ticketsList.."^7---------- ---------- ------------ ---------- ----------\n^5Info: ^7Pentru a prelua un ticket aleatoriu foloseste comanda ^5/tk\n^5Info: ^7iar pentru a prelua un ticket specific foloseste ^5/tk <id>"
	end

	TriggerClientEvent("chatMessage", source, ticketsList)
end)

RegisterCommand("calladmin", ch_calladmin)

RegisterCommand("tk", function(player, args)
	local user_id = vRP.getUserId(player)
	if user_id then
		if not vRP.isUserTrialHelper(user_id) then
			return vRPclient.denyAcces(player, {})
		end
		
		if args[1] then
			local target_id = tonumber(args[1])
			if not adminCalls[target_id] then
				return vRPclient.showError(player, {"Acel jucator nu are un ticket deschis."})
			end

			ch_answerTicket(player, user_id, target_id)
		else
			local target_id = 0
			local min = os.time() + 120
			for uid, data in pairs(adminCalls) do
				if data.expire < min then
					min = data.expire
					target_id = uid
				end
			end

			if target_id ~= 0 then
				ch_answerTicket(player, user_id, target_id)
			else
				vRPclient.msg(player, {"^1Tickets: ^7Nici un ticket nu asteapta o rezolvare."})
			end 
		end
	end
end)

RegisterCommand("lasttk", function(player)
	local user_id = vRP.getUserId(player)
	local targetId = lastTk[user_id]

	if not vRP.isUserTrialHelper(user_id) then
		return vRPclient.denyAcces(player)
	end

	if targetId then
		local uSrc = vRP.getUserSource(targetId)
		if uSrc then

			vRPclient.getPosition(uSrc, {}, function(x, y, z)
				local userWorld = GetPlayerRoutingBucket(uSrc)
        		SetPlayerRoutingBucket(player, userWorld)
        		vRPclient.teleport(player, {x, y, z})

        		vRPclient.msg(player, {"^5Tickets: ^7Te-ai intors la ultimul ticket facut de ^5"..GetPlayerName(uSrc).." ^7[^5"..targetId.."^7]."})
			end)

		else
			lastTk[user_id] = nil
			vRPclient.msg(player, {"^1Tickets: ^7Jucatorul caruia i-ai preluat ultimul ticket s-a deconectat."})
		end
	else
		vRPclient.msg(player, {"^1Tickets: ^7Niciun jucator caruia i-ai preluat ticketul."})
	end
end)

-- [EVENTS]

AddEventHandler("vRP:playerJoin", function(user_id, source, name)
  local rows = exports.oxmysql:querySync("SELECT adminLvl FROM users WHERE id = @id", {['@id'] = user_id})
    if #rows > 0 then
    	local adminLevel = tonumber(rows[1].adminLvl or 0)
    	local tmp = vRP.getUserTmpTable(user_id)

		
    	if tmp then
       		tmp.adminLevel = adminLevel
   		end
	end
	local rows2 = exports.oxmysql:querySync("SELECT vipLvl FROM users WHERE id = @id", {['@id'] = user_id})
    if #rows2 > 0 then
    	local vipLvl = tonumber(rows2[1].vipLvl or 0)
    	local tmp = vRP.getUserTmpTable(user_id)
		vRP.setUserVipLevel(user_id, vipLvl)
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, src, first_spawn)
	if vRP.isUserTrialHelper(user_id) then
		Citizen.CreateThread(function()
			Citizen.Wait(2000)
			TriggerClientEvent("vRP:setClientAdmin", src)
			TriggerClientEvent("vRP:setTicketsAmm", src, activeTickets)
		end)
	end

	if first_spawn then
		if not canUseWeapons then
			vRPclient.notify(source, {"Un administrator a dezactivat folosirea armelor!", "warning", false, "fas fa-gun"})
			vRPclient.toggleAllWeapons(source, {canUseWeapons})
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if adminCalls[user_id] then
		adminCalls[user_id] = nil

		activeTickets = activeTickets - 1
		checkTickets()
	end
end)