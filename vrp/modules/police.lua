local sPunishes = {
-- Cap 1 --
["Art 01. Viteza legală"] = 1200000,
["Art 02. Parcare ilegală"] = 800000,
["Art 03. Conducere imprudenta"] = 1000000,
["Art 04. Claxonare excesivă"] = 600000,
["Art 05. Geamuri fumurii"] = 400000,
["Art 06. Neoane"] = 400000,
["Art 07. Traversarea interzisă"] = 650000,
["Art 08. Nerespectarea culorii rosii a semaforului"] = 750000,
["Art 09. Claxon Custom"] = 0,
["Art 10. Nerespectarea marcajelor rutiere"] = 800000,
["Art 11. Acoperirea fetei la volan"] = 750000,
["Art 12. Autorizatie Camioane"] = 0 ,
["Art 13. Nerespectarea semnelor de circulatie a Politistului"] = 600000,
["Art 14. Utilizarea Nos-ului pe drumurile publice"] = 1200000,
["Art 15. Nerespectarea semnalelor luminoase si sonore"] = 700000,
-- Cap 2 --
["Art 01. Condusul fără permis"] = 850000,
["Art 02. Evadarea de un ofiţer cu un autovehicul"] = 650000,
["Art 03. Scoaterea placutelor de inmatriculare"] = 450000,
-- Cap 3 --
["Art 01. Deranjarea liniştii publice"] = 400000,
["Art 02. Instigarea unei revolte"] = 600000,
["Art 03. Eșecul de a părăsi un loc"] = 450000,
-- Cap 4 --
["Art 01. Asalt"] = 1300000,
["Art 02. Asalt cu o armă mortală"] = 3000000,
["Art 03. Tentativă de omor"] = ,
["Art 04. Ameninţări criminale"] = 2000000,
["Art 05. Răpire"] = 1500000,
["Art 06. Crimă"] = 5000000,
["Art 07. Codul Muncii ( Licente / Atestate )"] = 600000,
["Art 08. Codul Muncii ( Angajari )"] = 0,
["Art 09. Evadarea din custodie"] = 900000,
-- Cap 5 --
["Art 01. Posesia unei arme de foc de calibru mic fără permis PORT-ARMĂ"] = 750000,
["Art 02. Posesia unei arme automate de foc"] = 855000,
["Art 03. Traficul de armament"] = 2000000,
["Art 04. Posesia de explozibil"] = 2500000,
["Art 05. Îndreptarea unei arme asupra unui obiect"] = 700000,
["Art 06. Posesia unei arme albe"] = 7200000,
-- Cap 6 --
["Art 02. Folosirea de substanțe ilegale"] = 755000,
["Art 03. Terorism"] = 1500000,
-- Cap 7 --
["Art 01. Furt auto"] = 750000,
["Art 02. Jaf"] = 0,
["Art 03. Jaf armat"] = 2500000 ,
["Art 04. Jaf Banca / Bijuterie"] = 1400000,
["Art 05. Esecul de a parasii o institutie a statului"] = 500000,
["Art 06. Bani nemarcati (TIP I)"] = 550000,
["Art 07. Fals in declaratii"] = 1400000,
["Art 09. Rezistență la Arest"] = 540000,
["Art 10. Eşecul identificarii"] = 7500000,
["Art 11. Obstrucția unui ofiţer"] = 9000000,
["Art 12. Limbaj Vulgar la adresa ogranului de politie."] = 1200000,
-- Cap 8 --
["Art 01. Expunere indecenta"] = 650000,
["Art 02. Acoperirea fetei"] = 1200000,
["Art 03. Prostitutie"] = 4500000,
["Art 04. Viol"] = 900000,
["Art 05. Urmariea unei persoane fara aprobare/imputernicire"] = 350000,
-- Caziere --
["1.1 Legislaţia rutieră ."] = 0,
["1.2 Infracţiuni în trafic."] = 0,
["1.3 Infracţiuni asupra liniştii publice."] = 0,
["1.4 Infracţiuni asupra persoanelor."] = 0,
["1.5 Controlul armelor mortale."] = 0,
["1 6 Infracţiuni asupra sănătăţii şi siguranţei publice"] = 0,
["1.7 Infracţiuni asupra proprietăţilor"] = 0,
["1.8 Infractiuni asupra bunelor moravuri"] = 0,
}

local function choosePunishReason(source, cb)	
	vRP.buildMenu("copChoicesPunishReason", {player = source}, function(menu)
		menu.onclose = function(player)
			vRPclient.executeCommand(source, {"e c"})
		end

		vRPclient.executeCommand(source, {"e clipboard"})

		for punish, punishPrice in pairs(sPunishes) do
			menu[punish] = {function()
				cb(punish, punishPrice)
				vRP.closeMenu(source)
			end}
		end

		vRP.openMenu(source, menu)
	end)
end

RegisterCommand("radar", function(player)
	local user_id = vRP.getUserId(player)
	if vRP.isUserPolitist(user_id) then
		TriggerClientEvent("fp-toggleRadar", player)
	else
		vRPclient.notify(player, {"Doar politistii pot folosi radarul.", "error"})
	end
end)

local function createPoliceReport(source)
	local user_id = vRP.getUserId(source)
	if not vRP.isUserPolitist(user_id) then
		return
	end

    vRPclient.getNearestPlayer(source, {2}, function(nplayer)
	    local nuser_id = vRP.getUserId(nplayer)

	    if not nuser_id then
	      return vRPclient.notify(source, {"Niciun jucator prin preajma!", "error"})
	    end

	    choosePunishReason(source, function(reason)
		    vRP.getUserIdentity(user_id, function(userIdentity)
		    	if userIdentity then
		    		vRP.addPoliceReport(nuser_id, userIdentity.firstname.." "..userIdentity.name, reason)
		    		vRPclient.notify(source, {"Ai oferit un cazier judiciar!", "success", false, "fas fa-folder-open"})
		    	end
		    end)
		end)
  	end)
end

local function putInVehicle(player)
  local user_id = vRP.getUserId(player)
  
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)

	if not nuser_id then
	  return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
	end

    vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
	    if not handcuffed and not vRP.isUserMedic(user_id) then
	    	return vRPclient.notify(player, {"Nu este incatusat!", "warning", false, "fas fa-handcuffs"})
	    end

    	vRPclient.putInNearestVehicleAsPassenger(nplayer, {5}, function(inVehicle)
    		if not inVehicle then
    			return vRPclient.notify(player, {"A intervenit o eroare, incearca iar!", "warning"})
    		end

    		vRPclient.notify(player, {"L-ai pus in vehicul cu succes.", "success", false, "fas fa-car"})
  		end)
    end)
  end)
end

local function ejectFromVehicle(player)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)

	if not nuser_id then
	  return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
	end

    vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
	    if not handcuffed and not vRP.isUserMedic(user_id) then
	    	return vRPclient.notify(player, {"Nu este incatusat!", "warning", false, "fas fa-handcuffs"})
	    end

    	vRPclient.ejectVehicle(nplayer, {}, function(inVehicle)
    		if not inVehicle then
    			return vRPclient.notify(player, {"A intervenit o eroare, incearca iar!", "warning"})
    		end

    		vRPclient.notify(player, {"L-ai scos din vehicul cu succes.", "success", false, "fas fa-car"})
  		end)
    end)
  end)
end

local function unjailPlayer(source)
	local user_id = vRP.getUserId(source)
	if not vRP.isUserPolitist(user_id) then
		return
	end

    vRPclient.getNearestPlayer(source, {2}, function(nplayer)
	    local nuser_id = vRP.getUserId(nplayer)

	    if not nuser_id then
	      return vRPclient.notify(source, {"Niciun jucator prin preajma!", "error"})
	    end


		vRPclient.getJailTime(nplayer, {}, function(jailTime)
			if jailTime <= 0 then
				vRPclient.notify(source, {"Jucatorul nu este inchis!", "error", false, "fas fa-handcuffs"})
			else
				vRPclient.notify(source, {"L-ai scos din inchisoare!", "success", false, "fas fa-handcuffs"})

				vRP.setUData(nuser_id, "policeJail", 0)
				vRPclient.breakJail(nplayer, {})
			end
	    end)
  	end)
end

local sItems = {}
local meeleeItems = {
  'WEAPON_KNUCKLE',
  'WEAPON_SWITCHBLADE',
  'WEAPON_KNIFE',
  'WEAPON_NIGHTSTICK',
  'WEAPON_HAMMER',
  'WEAPON_BAT',
  'WEAPON_GOLFCLUB',
  'WEAPON_CROWBAR',
  'WEAPON_HATCHET',
  'WEAPON_POOLCUE',
  'WEAPON_WRENCH',
  'WEAPON_FLASHLIGHT',
  'WEAPON_BOTTLE',
  'WEAPON_DAGGER',
  'WEAPON_MACHETE',
  'WEAPON_BATTLEAXE',
  'WEAPON_WRENCH',
  'WEAPON_STONE_HATCHET',
  'WEAPON_MOLOTOV',
}

local function seizeObjects(source)
	local user_id = vRP.getUserId(source)
	if not vRP.isUserPolitist(user_id) then
		return
	end

    vRPclient.getNearestPlayer(source, {2}, function(nplayer)
	    local nuser_id = vRP.getUserId(nplayer)

	    if not nuser_id then
	      return vRPclient.notify(source, {"Niciun jucator prin preajma!", "error"})
	    end

		vRPclient.isHandcuffed(nplayer, {}, function(handcuffed)
			if not handcuffed then
				return vRPclient.notify(source, {"Nu este incatusat!", "error", false, "fas fa-handcuffs"})
			end

			vRPclient.getWeapons(nplayer, {}, function(uWeapons)
				local keepWeapons = {}

				local weaponsNum = table.len(uWeapons or {});
				if weaponsNum > 0 then

					local hasBag, theBag = checkIfBag(nuser_id)
				    if hasBag then
				      if theBag == "Borseta" or theBag == "Ghiozdan Mic" then
				        hasBag = false
				      end
				    end

					for _, weaponData in pairs(uWeapons) do
						local theWeapon = weaponData.model
						local keepWeapon = true

						if theWeapon:find("PISTOL") or theWeapon:find("REVOLVER") or meeleeItems[theWeapon] then
							keepWeapon = false
						elseif hasBag then
							keepWeapon = false
						end

						if keepWeapon then
							table.insert(keepWeapons, weaponData)
						end
					end

					Citizen.CreateThread(function()
						TriggerClientEvent("vRP:setWeapons", nplayer, keepWeapons)
					end)

					vRPclient.notify(source, {"Ai confiscat armele!", "info", false, "fas fa-gun"})
				end
			end)

			for _, theItem in pairs(sItems) do
				local amount = vRP.getInventoryItemAmount(user_id, theItem)

				if vRP.tryGetInventoryItem(nuser_id, theItem, amount, true) then
					vRP.giveInventoryItem(user_id, theItem, amount, true)
				end
			end

			vRPclient.notify(source, {"Ai confiscat obiectele ilegale!", "info", false, "fas fa-cannabis"})
	    end)
  	end)
end

local function spawnStretcher(source)
	TriggerClientEvent("medic$spawnStretcher", source)
end

local function spawnChair(source)
	TriggerClientEvent("medic$spawnChair", source)
end

local function deleteStretcher(source)
	TriggerClientEvent("medic$deleteStretcher", source)
end

local function deleteChair(source)
	TriggerClientEvent("medic$deleteChair", source)
end

local function ch_medicmenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildMenu("medici", {user_id = user_id, player = player, 0}, function(menu)
			menu.name="Meniu Smurd"
			menu.css={top="75px",header_color="rgba(255,125,0,0.75)"}

			menu["Spawn Targa"] = {spawnStretcher}
			menu["Sterge Targa"] = {deleteStretcher}
			menu["Spawn Scaun"] = {spawnChair}
			menu["Sterge Scaun"] = {deleteChair}

			if menu then vRP.openMenu(player,menu) end
		end)
	end
end

local function ch_fine(player)
    vRPclient.getNearestPlayers(player, {15}, function(nplayers)
		local user_list = ""
		for k, v in pairs(nplayers) do
			user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. vRP.getPlayerName({k}) .. " | "
		end
			vRP.prompt(player, "AMENDA", {
				{field = "target_id", title = "UTILIZATOR SELECTAT", number = true},
				{field = "motiv", title = "MOTIVUL AMENZII"},
				{field = "amount", title = "SUMA AMENDEI", number = true},
			}, function(_, results)
				local target_id = results["target_id"]
				local motiv = results["motiv"]
				local amount = results["amount"]
				if target_id and motiv and amount then
					local adminId = vRP.getUserId(player)
					if ((tonumber(amount) >= 10000000) and (amount ~= nil) and (amount ~= "")) then
						amount = 10000000
					end
					if ((tonumber(amount) <= 100) and (amount ~= nil) and (amount ~= "")) then
						amount = 100
					end
					local target = vRP.getUserSource(tonumber(target_id))
					if vRP.tryFullPayment(tonumber(target_id), tonumber(amount)) then
						vRPclient.notify(player, {"Ai amendat cu succes utilizatorul cu ID-ul " .. target_id .. " cu suma de " .. amount .. "$. Motiv: " .. motiv})
						vRPclient.notify(target, {"Ai primit o amenda de " .. amount .. "$ de la " .. GetPlayerName(player) .. " (" .. adminId .. "). Motiv: " .. motiv})
						local user_id = vRP.getUserId({player})
						vRP.closeMenu({player})
					else
						vRPclient.notify(player, {"Jucatorul nu are destui bani!"})
					end
				end
			end)
	end)
end
function ch_arrest(player)
    vRP.prompt(player, "ARESTEAZA", {
        {field = "target_id", title = "UTILIZATOR SACTIONAT", number = true},
        {field = "duration", title = "DURATA ARESTULUI (minute)", number = true},
        {field = "reason", title = "MOTIVUL ARESTULUI"},
    }, function(player, res)
        local target_id = res["target_id"]
        local duration = res["duration"]
        local reason = res["reason"]

        if target_id ~= nil and duration ~= nil and reason ~= nil then
            local target = vRP.getUserSource(tonumber(target_id))
            if target ~= nil then
                -- set the user in police jail
                vRP.setInPJail(target_id, duration)

                -- log the arrest
                local adminId = vRP.getUserId(player)
                -- exports.oxmysql:execute("INSERT INTO punishLogs (user_id, time, type, text) VALUES (@user_id, @time, @type, @text)", {
                --     ['@user_id'] = tonumber(target_id),
                --     ['@time'] = os.time(),
                --     ['@type'] = "arrest",
                --     ['@text'] = "A fost arestat de "..GetPlayerName(player).." ("..adminId..") pentru "..duration.." minute. Motiv: "..reason
                -- })

                -- notify the player
                vRPclient.notify(target, {"Ai fost arestat de "..GetPlayerName(player).." pentru "..duration.." minute. Motiv: "..reason, "warning", false, "fas fa-handcuffs"})
                vRPclient.notify(player, {"Ai arestat cu succes jucatorul cu ID-ul "..target_id, "success"})
            else
                vRPclient.notify(player, {"Jucatorul cu ID-ul "..target_id.." nu este conectat la server", "error"})
            end
        else
            vRPclient.notify(player, {"Introdu toate detaliile necesare pentru a efectua arestarea", "error"})
        end
    end)
end
local function ch_poliemenu(player, choice)
	local user_id = vRP.getUserId(player)
	if user_id then
		vRP.buildMenu("politie", {user_id = user_id, player = player, 0}, function(menu)
			menu.name="Meniu Politie"
			menu.css={top="75px",header_color="rgba(255,125,0,0.75)"}
			menu['Pune intr-un vehicul'] = {putInVehicle}
			menu['Scoate din vehicul'] = {ejectFromVehicle}
			menu['Confisca ilegale'] = {seizeObjects}
			menu['Amendeaza'] = {ch_fine}
			menu['Aresteaza'] = {ch_arrest}
			if menu then vRP.openMenu(player,menu) end
		end)
	end
end

vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
	  -- add vehicle entry
	  local choices = {}

	  if vRP.isUserPolitist(user_id) then
		choices["👮 Meniu Politie"] = {ch_poliemenu}
	  end

	  if vRP.isUserMedic(user_id) then
		choices["🚑 Meniu Medic"] = {ch_medicmenu}
	  end
  
	  add(choices)
	end
  end)

local inWork = {}
local inJail = {}

local function checkIfJail(source, user_id)
	vRP.getUData(user_id, "policeJail", function(jailTime)
		jailTime = tonumber(jailTime)

		if (jailTime or 0) > 0 then
			TriggerClientEvent("jail$onCellEnter", source, jailTime)
			SetPlayerRoutingBucket(source, 0)
		end
	end)
end

function vRP.setInPJail(user_id, minutes)
	local source = vRP.getUserSource(user_id)
	vRP.setUData(user_id, "policeJail", minutes)

	if source then
		Citizen.Wait(500)

		checkIfJail(source, user_id)
		vRPclient.notify(source, {"Ai fost trimis la inchisoare!", "warning", false, "fas fa-handcuffs"})
	end
end

local function passJailTime(source, user_id)
	vRPclient.getJailTime(source, {}, function(jailTime)
		if jailTime <= 0 then
			jailTime = 0
			inJail[user_id] = nil
		end

		vRP.setUData(user_id, "policeJail", jailTime)
	end)
end

RegisterServerEvent("jail$onMinutePassed", function()
	local user_id = vRP.getUserId(source)

	if not inJail[user_id] then
		inJail[user_id] = os.time() + 45
		passJailTime(source, user_id)
	elseif inJail[user_id] < os.time() then
		inJail[user_id] = os.time() + 45
		passJailTime(source, user_id)
	end
end)

function tvRP.onJailWork()
	local user_id = vRP.getUserId(source)

	if not inWork[user_id] then
		inWork[user_id] = os.time() + 8
		passJailTime(source, user_id)
	elseif inWork[user_id] < os.time() then
		inWork[user_id] = os.time() + 8
		passJailTime(source, user_id)
	-- else
		-- vRP.banPlayer(user_id, 0, -1, "Injection detected [vrp][jailWork]")
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, thePlayer, first_spawn)
	if first_spawn then
		Citizen.CreateThread(function()
			Citizen.Wait(2000)

			checkIfJail(thePlayer, user_id)
		end)
	end
end)