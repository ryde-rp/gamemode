

local hadJailCPThisSession = {}
local jailCp = {}
local jailSecret = {}
local jailPos = {-789.779296875,5431.1713867188,35.567169189454}
local jailCps = {
	{-632.82604980468,5466.498046875,53.448699951172},
	{-629.67559814454,5470.3315429688,53.47996520996},
	{-619.75103759766,5498.4638671875,51.25910949707},
	{-633.2583618164,5505.517578125,51.258392333984},
	{-534.4076538086,5536.7827148438,64.075645446778},
	{-536.50775146484,5547.630859375,62.5750389099120},
	{-525.09844970704,5559.9301757812,66.144233703614},
	{-507.47482299804,5565.2412109375,70.315612792968},
	{-475.95309448242,5588.1049804688,69.697151184082},
	{-503.79119873046,5610.1865234375,64.747482299804},
	{-462.80221557618,5614.9067382812,65.934608459472},
	{-492.52575683594,5394.7163085938,77.290298461914},
	{-505.12530517578,5391.1440429688,75.43529510498},
	{-625.814453125,5526.9780273438,46.502990722656}
}

local function getOutOfJail(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		SetPlayerRoutingBucket(player, 0)
		vRPclient.teleport(player, {-490.60980224609,-691.02087402344,33.206745147705})
		TriggerClientEvent("fp-jail:setState", player, false)
	end
end

RegisterCommand("checkjail", function(player, args)
	if vRP.isUserTrialHelper(vRP.getUserId(player)) then
		local target = tonumber(args[1])
		if target then
			vRPclient.sendInfo(player, {"^1Utilizatorul "..GetPlayerName(vRP.getUserSource(target)).." ["..target.."] are "..(jailCp[target] or 0).." copaci ramasi."})
		else
			vRPclient.cmdUse(player, {"/checkjail <user_id>"})
		end
	else
		vRPclient.denyAcces(player)
	end
end)

RegisterServerEvent("fp-jail:checkCheckpoint")
AddEventHandler("fp-jail:checkCheckpoint", function(cpData)
	local player = source
	local user_id = vRP.getUserId(player)

	if jailSecret[user_id] then

		if jailCps[jailSecret[user_id]][1] == cpData[1] then
			jailCp[user_id] = jailCp[user_id] - 1

			if jailCp[user_id] <= 0 then
				getOutOfJail(user_id)
			else
				local newRnd = math.random(1, #jailCps)
				while newRnd == jailSecret[user_id] do
					newRnd = math.random(1, #jailCps)
					Citizen.Wait(1)
				end

				jailSecret[user_id] = newRnd
				TriggerClientEvent("fp-jail:sendCoords", player, jailCps[jailSecret[user_id]], jailCp[user_id])
			end
		else
			vRP.banPlayer(0, user_id, -1, "Injection detected [vrp][aJailTask]")
		end
	end
end)

local function jailTick()

	for uid, cps in pairs(jailCp) do
		local src = vRP.getUserSource(uid)
		if src then
			if cps > 0 then
				
				local playerPed = GetPlayerPed(src)
				local playerPos = GetEntityCoords(playerPed)

				local dist = #(playerPos - vec3(jailPos[1], jailPos[2], 0))

				if dist >= 750.0 then
					SetPlayerRoutingBucket(src, uid)
					SetEntityCoords(playerPed, vec3(jailPos[1], jailPos[2], jailPos[3]))
				end
				TriggerClientEvent("fp-jail:setState", src, true)

			else
				jailCp[uid] = nil
			end
		else
			jailCp[uid] = nil
		end
	end

	Citizen.CreateThread(function()
		Citizen.Wait(60000)
		jailTick()
	end)
end
jailTick()

local function checkJail(user_id, player)
	if (jailCp[user_id] or 0) > 0 then
		Citizen.Wait(1000)
		SetPlayerRoutingBucket(player, user_id)
		vRPclient.teleport(player, jailPos)

		jailSecret[user_id] = math.random(1, #jailCps)
		TriggerClientEvent("fp-jail:sendCoords", player, jailCps[jailSecret[user_id]], jailCp[user_id])
		TriggerClientEvent("fp-jail:setState", player, true)
	end
end

function vRP.removeAdminJail(user_id)
	jailCp[user_id] = nil
	getOutOfJail(user_id)
end

function vRP.isInAdminJail(user_id)
	return (jailCp[user_id] or 0) > 0
end

function vRP.setInAdminJail(user_id, cps, admin, reason)
	if (jailCp[user_id] or 0) == 0 then
		if cps > 0 then
			local player = vRP.getUserSource(user_id)
			local adminTag = "Ryde-Team"
			if admin ~= 0 then
				adminTag = (GetPlayerName(admin) or "Necunoscut").." ("..vRP.getUserId(admin)..")"
			end
			
			if player then
				hadJailCPThisSession[player] = true
				jailCp[user_id] = cps
				checkJail(user_id, player)
				vRPclient.msg(-1, {"^3Jail: Adminul "..adminTag.." i-a dat "..cps.." (de) copaci lui "..GetPlayerName(player).." ("..user_id.."), motiv: "..reason})
			else
				vRPclient.msg(-1, {"^3Jail: Adminul "..adminTag.." i-a dat "..cps.." (de) copaci lui ID "..user_id..", motiv: "..reason})
			end

			exports.oxmysql:execute("INSERT INTO punishLogs (user_id,time,text) VALUES(@user_id,@time,@text)",{
				['@user_id'] = user_id,
				['@time'] = os.time(),
				['@text'] = "Admin jail de la "..adminTag..": "..reason
			})

			exports.oxmysql:execute("UPDATE users SET ajail = @ajail WHERE id = @id",{
				['@id'] = user_id,
				['@ajail'] = cps
			})
		end
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		local rows = exports.oxmysql:querySync("SELECT ajail FROM users WHERE id = @id", {['@id'] = user_id})
		if #rows > 0 then

			Citizen.Wait(1000)
			local jailCheckpoints = rows[1].ajail or 0

			if jailCheckpoints > 0 then
				hadJailCPThisSession[player] = true
				jailCp[user_id] = jailCheckpoints
				Citizen.Wait(200)
				checkJail(user_id, player)
			end
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, isSpawned)
	if isSpawned and hadJailCPThisSession[player] then
		if jailCp[user_id] then
			exports.oxmysql:execute("UPDATE users SET ajail = @ajail WHERE id = @id",{
				['@id'] = user_id,
				['@ajail'] = jailCp[user_id]
			})
			Citizen.Wait(5000)
			jailCp[user_id] = nil
		else
			exports.oxmysql:execute("UPDATE users SET ajail = @ajail WHERE id = @id",{
				['@id'] = user_id,
				['@ajail'] = 0
			})
		end
	end

	jailCp[user_id] = nil
	hadJailCPThisSession[player] = nil
	jailSecret[user_id] = nil
end)

RegisterCommand("jail", function(source, args)
	local target_id = tonumber(args[1])
	local jailTrees = tonumber(args[2])

	if source == 0 then
		if not target_id or not jailTrees or not args[3] then
			return print("^5Sintaxa: ^7/jail <id> <copaci> <motiv>")
		end

		local jailReason = table.concat(args, " ", 3)
		return vRP.setInAdminJail(target_id, jailTrees, source, jailReason)
	end

	local user_id = vRP.getUserId(source)
	if not vRP.isUserHelper(user_id) then
		return vRPclient.denyAcces(source, {})
	end

	if not target_id or not jailTrees or not args[3] then
		return vRPclient.cmdUse(source, {"/jail <id> <copaci> <motiv>"})
	end

	if jailTrees < 1 then
		return vRPclient.showError(source, {"Trebuie sa specifici un numar valid de copaci."})
	end

	local jailReason = table.concat(args, " ", 3)
	vRP.setInAdminJail(target_id, jailTrees, source, jailReason)
end)

RegisterCommand("unjail", function(source, args)
	local target_id = tonumber(args[1])
	if source == 0 then

		if not target_id then
			return print("^5Sintaxa: ^7/unjail <id>")
		end

		local target_src = vRP.getUserSource(target_id)
		local name = "^3Unjail: Adminul Ryde-Team"

		if target_src then
			vRPclient.msg(-1, {name.." i-a scos jailul lui "..GetPlayerName(target_src).." ("..target_id..")"})
		else
			vRPclient.msg(-1, {name.." i-a scos jailul lui ID "..target_id})
		end

		vRP.removeAdminJail(target_id)
		exports.oxmysql:execute("UPDATE users SET ajail = @ajail WHERE id = @id",{
			['@id'] = target_id,
			['@ajail'] = 0
		})
		return
	end

	local user_id = vRP.getUserId(source)
	if not vRP.isUserAdministrator(user_id) then
		return vRPclient.denyAcces(source)
	end

	if not target_id then
		return vRPclient.cmdUse(source, {"/unjail <id>"})
	end

	local target_src = vRP.getUserSource(target_id)
	local name = "^3Unjail: Adminul "..GetPlayerName(source).." ("..user_id..")"

	if target_src then
		vRPclient.msg(-1, {name.." i-a scos jailul lui "..GetPlayerName(target_src).." ("..target_id..")"})
	else
		vRPclient.msg(-1, {name.." i-a scos jailul lui ID "..target_id})
	end

	vRP.removeAdminJail(target_id)
	exports.oxmysql:execute("UPDATE users SET ajail = @ajail WHERE id = @id",{
		['@id'] = target_id,
		['@ajail'] = 0
	})
end)