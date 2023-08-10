
local tempWarns = {}

function vRP.getWarnsNum(user_id, cbr)
	local task = Task(cbr, {0})

	local warns = tempWarns[user_id]
	if warns then
		local warnsNr = 0
		for k, v in pairs(warns) do
			warnsNr = warnsNr + 1
		end
		task({warnsNr})
	else
		task({0})
	end
end

function vRP.getWarns(user_id)
	return tempWarns[user_id] or {}
end

function vRP.addWarn(user_id, reason, admin)
    local theWarn = {
        time = os.time(),
        reason = reason,
        admin = admin or "Necunoscut",
        date = os.date("%d/%m/%Y %H:%M"),
    }

    exports.oxmysql:transaction(function(conn)
        -- Executăm operația de actualizare "UPDATE" pentru a adăuga un nou avertisment
        exports.oxmysql:execute("UPDATE users SET userWarns = JSON_ARRAY_APPEND(userWarns, '$', @warn) WHERE id = @id", {
            ['@warn'] = json.encode(theWarn),
            ['@id'] = user_id
        }, function(success, result)
            -- Verificăm succesul execuției operației de actualizare
            if success then
                -- Executăm operația de interogare "SELECT" pentru a obține avertismentele utilizatorului
                exports.oxmysql:execute("SELECT userWarns FROM users WHERE id = @id LIMIT 1", {
                    ['@id'] = user_id
                }, function(success, result)
                    -- Verificăm succesul execuției interogării
                    if success then
                        local warns = result[1] and json.decode(result[1].userWarns) or nil
                        tempWarns[user_id] = warns

                        if warns then
                            local warnsNumber = 0
                            for _, _ in pairs(warns) do
                                warnsNumber = warnsNumber + 1
                            end

                            if warnsNumber == 3 then
                                -- Executăm operația de actualizare "UPDATE" pentru a șterge câmpul "userWarns"
                                exports.oxmysql:execute("UPDATE users SET userWarns = NULL WHERE id = @id", {
                                    ['@id'] = user_id
                                }, function(success, result)
                                    -- Verificăm succesul execuției operației de actualizare
                                    if success then
                                        -- Apelăm funcția vRP.banPlayer() aici pentru a bana utilizatorul
                                        vRP.banPlayer(0, user_id, 14, "Acumulare a 3/3 Warnuri")
                                    else
                                        -- Tratați cazul în care operația de actualizare a eșuat
                                    end
                                end)
                            end
                        end
                    else
                        -- Tratați cazul în care interogarea a eșuat
                    end
                end)
            else
                -- Tratați cazul în care operația de actualizare a eșuat
            end
        end)
    end)
end

function vRP.removeWarn(user_id)
    local warns = tempWarns[user_id]
    if warns then
        local minWarn = 0
        local minIndx = 1
        for i, v in ipairs(warns) do
            if i == 1 then
                minWarn = v.time
            else
                if v.time > minWarn then
                    minWarn = v.time
                    minIndx = i
                end
            end
        end

        tempWarns[user_id][minIndx] = nil

        Citizen.Wait(500)
        local newWarns = table.len(tempWarns[user_id])

        if newWarns >= 1 then
            exports.oxmysql:execute("UPDATE users SET userWarns = @warns WHERE id = @id", {
                ['@warns'] = json.encode(tempWarns[user_id]),
                ['@id'] = user_id
            })
        else
            exports.oxmysql:execute("UPDATE users SET userWarns = NULL WHERE id = @id", {
                ['@id'] = user_id
            })
        end
    end
end

RegisterCommand("warn", function(player, args)
    local user_id = vRP.getUserId(player)
    if not vRP.isUserTrialHelper(user_id) then
        return vRPclient.denyAccess(player, {})
    end

    if not args[1] or not args[2] then
        return vRPclient.notify(player, {"^1Sintaxa: ^7/warn <user_id> <motiv>"})
    end

    local target_id = tonumber(args[1])
    local target_src = vRP.getUserSource(target_id)

    local name = target_id
    if target_src then
        name = GetPlayerName(target_src).." ("..name..")"
    end

    local reason = table.concat(args, " ", 2)
    local adminName = GetPlayerName(player)
    local adminId = user_id;

    vRPclient.sendNotification(-1, {"^eWarn: Adminul "..adminName.." i-a dat un warn lui "..name..", motiv: "..reason})

    exports.oxmysql:execute("INSERT INTO punishLogs (user_id, time, type, text) VALUES (@user_id, @time, @type, @text)", {
        ['@user_id'] = target_id,
        ['@time'] = os.time(),
        ['@type'] = "warn",
        ['@text'] = "A primit WARN de la "..GetPlayerName(player).." ("..adminId.."). Motiv: "..reason
    })

    vRP.addWarn(target_id, reason, adminName.." ("..adminId..")")
end)


RegisterCommand("unwarn", function(player, args)
    if player == 0 then
        if not args[1] then
            return print("^5Sintaxa: ^7/unwarn <id>")
        end

        vRP.removeWarn(tonumber(args[1]))
        print("^2Succes: ^7Warnul jucatorului a fost scos.")

        return
    end

    local user_id = vRP.getUserId(player)
    if not vRP.isUserMod(user_id) then
        return vRPclient.denyAccess(player, {})
    end
    
    if not args[1] then
        return vRPclient.notify(player, {"^1Sintaxa: ^7/unwarn <user_id>"})
    end
    
    local target_id = tonumber(args[1])
    local target_src = vRP.getUserSource(target_id)

    local name = target_id
    if target_src then
        name = GetPlayerName(target_src).." ("..name..")"
    end

    exports.oxmysql:execute("INSERT INTO punishLogs (user_id, time, type, text) VALUES (@user_id, @time, @type, @text)", {
        ['@user_id'] = target_id,
        ['@time'] = os.time(),
        ['@type'] = "unwarn",
        ['@text'] = "A primit UNWARN de la "..GetPlayerName(player).." ("..user_id..")"
    })

    vRPclient.sendNotification(-1, {"^eUnwarn: "..GetPlayerName(player).." i-a scos un warn lui "..name})
    vRP.removeWarn(target_id)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		tempWarns[user_id] = dbdata.userWarns or {}
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	tempWarns[user_id] = nil
end)