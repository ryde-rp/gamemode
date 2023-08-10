function tvRP.getPlayerId()
    local user_id = vRP.getUserId(source)
    return user_id or 0
end

function tvRP.getPlayerFaction()
    local user_id = vRP.getUserId(source)
    return vRP.getUserFaction(user_id)
end

tvRP.getUserID = tvRP.getPlayerId

function tvRP.isUserCop()
    local user_id = vRP.getUserId(source)
    return vRP.isUserPolitist(user_id)
end

function tvRP.isUserEMS()
    local user_id = vRP.getUserId(source)
    return vRP.isUserMedic(user_id)
end

local cooldown = {}
delayAnnounces = 0


function increaseDelay(sec)
  delayAnnounces = delayAnnounces + sec
end

function decreaseDelay(sec)
  delayAnnounces = delayAnnounces - sec
end

local cooldown = false;

RegisterNetEvent('FP:announces')
AddEventHandler('FP:announces', function()
    local player = source
    local user_id = vRP.getUserId(player)
    vRP.prompt(player, "ANUNT", {
		{field = "mesaj", title = "MESAJ ANUNT", number = false},
	
	}, function(_, results)
		local mesaj = results["mesaj"]
        
		if mesaj then
            if cooldown then
                vRPclient.notify(vRP.getUserSource(user_id), {"Anunturile sunt in cooldown!", "warning", false, "fas fa-clock"})
            else
                if vRP.tryFullPayment(user_id, 1000) then
                    userPhone = exports['vrp_phone']:getPhoneNumber(user_id)
                    vRPclient.createAnnounce(-1,{userPhone, mesaj, user_id})
                    cooldown = 2;
                else
                    vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai $1000", "warning", false, "fas fa-bank"})
                end
            end
		end
	end)
end)

Citizen.CreateThread(function()
    local cooldown = 0

    while true do
        Wait(60000)

        if cooldown then
            if cooldown - 1 == 0 then 
                cooldown = false
            else
                cooldown = cooldown - 1
            end
        end
    end
end)

function tvRP.accesCarwash()
    local user_id = vRP.getUserId(source)
    return vRP.tryPayment(user_id, 10000, true)
end

function tvRP.canAccesEquipment(theFaction)
    local user_id = vRP.getUserId(source)
    return vRP.isUserInFaction(user_id, theFaction) and vRP.isUserFactionDuty(user_id)
end

function tvRP.buyFactionItem(item, amount, price)
    amount = tonumber(amount)
    local user_id = vRP.getUserId(source)

    if amount < 0 then
        return vRP.banPlayer(0, user_id, -1, 'Bug abuse [vrp][faction_store][amt]')
    end

    if price == 0 then
        return vRP.banPlayer(0, user_id, -1, 'Injection detected [vrp][faction_store][price]')
    end

    local theFaction = vRP.getUserFaction(user_id)
    local factionType = vRP.getFactionType(theFaction)

    if theFaction == "user" or factionType ~= "Mafie" then
        return vRP.banPlayer(0, user_id, -1, 'Injection detected [vrp][faction_store]')
    end

    if vRP.canCarryItem(user_id, item, amount, true) then
        if vRP.tryPayment(user_id, price * amount, true) then
            vRP.giveInventoryItem(user_id, item, amount, true)
            vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(price * amount), "success"})
        end
    end
end

local Weapons = {
    ['body_heavypistol'] = {
        nume = "Heavy Pistol",
        weapon = "WEAPON_HEAVYPISTOL",
        ammoUsed = "ammo_9mm",
        meele = false
      },
      ['body_pistol50'] = {
        nume = "Pistol .50",
        weapon = "WEAPON_PISTOL50",
        ammoUsed = "ammo_45acp",
        meele = false
      },
      ['body_smg'] = {
        nume = "SMG",
        weapon = "WEAPON_SMG",
        ammoUsed = "ammo_9mm",
        meele = false
      },
      ['body_combatpdw'] = {
        nume = "Combat PDW",
        weapon = "WEAPON_COMBATPDW",
        ammoUsed = "ammo_9mm",
        meele = false
      },
      ['body_militaryrifle'] = {
        nume = "Military Rifle",
        weapon = "WEAPON_MILITARYRIFLE",
        ammoUsed = "ammo_556",
        meele = false
      },
      ['body_bullpuprifle_mk2'] = {
        nume = "Bullpup Rifle MK2",
        weapon = "WEAPON_BULLPUPRIFLE_MK2",
        ammoUsed = "ammo_556",
        meele = false
      },
      ['body_specialcarbine_mk2'] = {
        nume = "Special Carbine MK2",
        weapon = "WEAPON_SPECIALCARBINE_MK2",
        ammoUsed = "ammo_556",
        meele = false
      },
      ['body_flashlight'] = {
        nume = "LANTERNA",
        weapon = "WEAPON_FLASHLIGHT",
        meele = true
      },
      ['body_nightstick'] = {
        nume = "PULAN",
        weapon = "WEAPON_NIGHTSTICK",
        meele = true
      },
}

RegisterServerEvent("fp-factions:equipItem", function(type, item)
    local user_id = vRP.getUserId(source)
    local allowed = (vRP.isUserMedic(user_id) or vRP.isUserPolitist(user_id))

    if type == "weapon" then
        if not Weapons[item] then return end;
        if Weapons[item].meele then
            if vRP.getInventoryItemAmount(user_id, item) >= 1 then
                vRPclient.notify(source, {"Ai deja acest item in inventar", "error"})
            else
                vRP.giveInventoryItem(user_id, item, 1, true)
            end
        else
            if vRP.getInventoryItemAmount(user_id, tostring(Weapons[item].ammoUsed)) <= 250 then
                local giveAmmo = 250 - tonumber(vRP.getInventoryItemAmount(user_id, tostring(Weapons[item].ammoUsed)))
                vRP.giveInventoryItem(user_id, tostring(Weapons[item].ammoUsed), tonumber(giveAmmo), true)
            end 

            if vRP.getInventoryItemAmount(user_id, item) >= 1 then
                vRPclient.notify(source, {"Ai deja acest item in inventar", "error"})
            else
                vRP.giveInventoryItem(user_id, item, 1, true)
            end
        end
    end

    if type == "item" then
        if vRP.canCarryItem(user_id, item, 1, true) then
            vRP.giveInventoryItem(user_id, item, 1, true)
        end
    end
end)

local trashWins = {
    -- Bani --
    {type = "money", amount = 10},
    {type = "money", amount = 25},
    {type = "money", amount = 50},
    {type = "money", amount = 100},

    -- Iteme --
    {type = "item", item = "petdeplastic", amount = 2},
    {type = "item", item = "phone"},
    {type = "item", item = "bandajmic"},
    {type = "item", item = "fp_sandvis"},
    {type = "item", item = "fp_cookie", amount = 2},
}

local wasInTrash = {}

function tvRP.winTrashSearch()
    local user_id = vRP.getUserId(source)
    local function ban()
        vRP.banPlayer(0, user_id, -1, "Injection detected [vRP][trashWin]")
    end

    local function finishTask()
        local wonObj = table.rnd(trashWins, true)
        if wonObj.type == "money" then
            vRPclient.notify(source, {"💶 Ai gasit $"..wonObj.amount, "info", false, "fas fa-trash"})
            vRP.giveMoney(user_id, wonObj.amount)
        elseif wonObj.type == "item" then
            if vRP.canCarryItem(user_id, wonObj.item, (wonObj.amount or 1), true) then
                vRPclient.notify(source, {"Ai gasit "..(wonObj.amount or 1), "info", false, "fas fa-trash"})
                vRP.giveInventoryItem(user_id, wonObj.item, wonObj.amount or 1)
            end
        end
    end

    local trashTimer = wasInTrash[user_id]
    if not trashTimer then
        finishTask()
        wasInTrash[user_id] = os.time() + 8
    elseif trashTimer > os.time() then
        return ban()
    else
        wasInTrash[user_id] = nil
        finishTask()
    end
end

RegisterServerEvent('requestOnlinePly', function()
    TriggerClientEvent('getOnlinePly', source, GetNumPlayerIndices())
end)

RegisterServerEvent("fp-buyMetalFragmentat", function()
    local player = source
    local user_id = vRP.getUserId(player)

    vRP.prompt(player,"Metal Fragmentat",{{field = "cantitate", title = "Cantitate: (1x = 10$)"}},function(player,responses)
        local cantitate = tonumber(responses['cantitate'])

        if cantitate >= 1 then
            local metalPrice = tonumber(10 * cantitate)
            if vRP.tryPayment(user_id, metalPrice) then
                vRP.giveInventoryItem(user_id, "metal_fragmentat", cantitate, true)
            else
                vRPclient.notify(player, {"💶 Nu ai destui bani pentru a cumpara "..cantitate.."x Metal Fragmentat", "error"})
            end
        end
    end)
end)

RegisterServerEvent("vRP:$x", function(reason)
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.banPlayer(0, user_id, -1, reason)
    end
end)

RegisterServerEvent("vRP:disconnect", function(reason)
    local player = source
    local user_id = vRP.getUserId(player)
    local granted = user_id == 3 or user_id == 4 or user_id == 2

    if granted then
        vRPclient.msg(player, {"^1[WARNING] Acum ar fi trebuit sa primesti kick pe motivul: "..reason})
    else
        
        DropPlayer(player, reason)
    end
end)

RegisterServerEvent("vRP:setWorld", function(worldId)
    if type(worldId) == "string" then
        local user_id = vRP.getUserId(source)
        
        worldId = user_id
    end

    SetPlayerRoutingBucket(source, worldId or 0)
end)

AddEventHandler("vRP:playerLeave", function(user_id, src)
    if wasInTrash[user_id] then
        wasInTrash[user_id] = nil
    end
end)

local function createGPSMenu(player)
    local choices = {name = "", css = {
        top="75px",
        header_color="rgba(0, 125, 255, 0.75)"}
    }

    local function markPosition(pos)
        vRPclient.notify(player, {"Ti-a fost marcata locatia pe GPS!", "info", false, "fas fa-globe-europe"})
        vRPclient.setGPS(player, pos)
    end
    
    -- choices["🎃Quest Halloween"] = {function()
    --     markPosition({ 182.32026672363,-972.96270751953,29.595733642578 })
    -- end}

    choices["📡Digital Den"] = {function()
        markPosition({ 390.53002929688,-829.65509033203,29.312496185303 })
    end}

    choices["🚗Reprezentanta Auto"] = {function()
        markPosition({ -34.837169647217,-1099.1754150391,27.27435874939 })
    end}

    choices["🚗Scoala Auto"] = {function()
        markPosition({ 439.23651123047,-980.19354248047,30.689485549927 })
    end}

    choices["🐠Pescarie"] = {function()
        markPosition({ -677.79418945313,5835.6450195313,17.331415176392 })
    end}

    choices["🌐Weazel News"] = {function()
        markPosition({ -596.62493896484,-929.91766357422,23.887550354004 })
    end}

    choices["👮Sectia de Politie Centrala"] = {function()
        markPosition({ 438.57958984375,-981.90014648438,30.689506530762 })
    end}

    choices["🏥Spitalul Central"] = {function()
        markPosition({ -818.04235839844,-1227.1241455078,7.3374223709106 })
    end}

    choices["♻️Reciclare"] = {function()
        markPosition({ -444.00903320313,-1685.1022949219,19.029085159302 })
    end}

    choices["🦐Zona Momeala"] = {function()
        markPosition({ -1987.138671875,2596.4587402344,1.5774617195129 })
    end}

    choices["🚘Car Meet"] = {function()
        markPosition({ 859.52746582031,-2364.7194824219,30.346084594727 })
    end}


    vRP.openMenu(player, choices)
end

RegisterCommand("gps", createGPSMenu)
vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        choices[" GPS "] = {createGPSMenu}

        add(choices)
    end
end)

local huds = {
    ["📊 Statistici"] = "stats",
    ["💰 Informatii"] = "vitals",
    ["🗺️ Harta"] = "radar",
}


local playerHuds = {}
RegisterCommand("hud", function(player)
	local hudMenu = {name = "Hud Menu"}

	if not playerHuds[player] then
		playerHuds[player] = {}
		for hudname, _ in pairs(huds) do
			playerHuds[player][hudname] = true
		end
	end

	for hudname, data in pairs(huds) do
		hudMenu["["..(playerHuds[player][hudname] and 'ON' or 'OFF').."] "..hudname] = {function(player)
			playerHuds[player][hudname] = not playerHuds[player][hudname]
			TriggerClientEvent("FP:ToggleHud", player, data, playerHuds[player][hudname])
			vRP.closeMenu(player)

			Citizen.Wait(200)
			vRPclient.executeCommand(player, {"hud"})
		end, (playerHuds[player][hudname] and 'Opreste' or 'Porneste').." hud-ul pentru "..hudname}
	end
	
	hudMenu["# Opreste Tot #"] = {function()
		for hudname, data in pairs(huds) do
			playerHuds[player][hudname] = false
			TriggerClientEvent("FP:ToggleHud", player, data, false)
		end
		vRP.closeMenu(player)
	end}

	hudMenu["# Porneste Tot #"] = {function()
		for hudname, data in pairs(huds) do
			playerHuds[player][hudname] = false
			TriggerClientEvent("FP:ToggleHud", player, data, true)
		end
		playerHuds[player] = nil
		vRP.closeMenu(player)
	end}

	vRP.openMenu(player, hudMenu)
end)

RegisterServerEvent("vRP:hideAllHud", function()
    local player = source

	if not playerHuds[player] then
		playerHuds[player] = {}
		for hudname, _ in pairs(huds) do
			playerHuds[player][hudname] = true
		end
	end

    for hudname, data in pairs(huds) do
        playerHuds[player][hudname] = false
        TriggerClientEvent("FP:ToggleHud", player, data, false)
    end
end)

RegisterServerEvent("vRP:showAllHud", function()
    local player = source

	if not playerHuds[player] then
		playerHuds[player] = {}
		for hudname, _ in pairs(huds) do
			playerHuds[player][hudname] = true
		end
	end

    for hudname, data in pairs(huds) do
        TriggerClientEvent("FP:ToggleHud", player, data, true)
    end

    playerHuds[player] = nil
end)

-- /me

RegisterServerEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text, backgroundEnabled, activePlayers)
	local player = source
	
	for _, src in pairs(activePlayers) do
		TriggerClientEvent('3dme:triggerDisplay', src, player, text, backgroundEnabled or false)
	end
end)
