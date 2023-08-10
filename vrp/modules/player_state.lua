local deathPosition = vector3(-801.65026855469,-1232.1672363281,7.3374271392822)
local policeRespawn = vector3(456.93060302734,-969.48297119141,30.709787368774)

-- updates
local playerPositions = {}
local playerHealth = {}
local playerArmor = {}
local playerJobSkill =  {}
local RoutingBucketOn = false

RegisterCommand("protection", function(player)
	if player == 0 then
		if RoutingBucketOn then
			SetRoutingBucketEntityLockdownMode(0, "inactive")
			print("^4RYDE-SYSTEM: ^1SERVER IS NOW SET ON INACTIVE MODE")
			RoutingBucketOn = false
		else
			SetRoutingBucketEntityLockdownMode(0, "strict")
			print("^4RYDE-SYSTEM: ^2SERVER IS NOT SET ON STRICT MODE")
			RoutingBucketOn = true
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	local data = vRP.getUserDataTable(user_id)
	local tmpdata = vRP.getUserTmpTable(user_id)
	local player = player

	if first_spawn then -- first spawn
		local rows = exports.oxmysql:querySync("SELECT x,y,z,userHealth,armour,jobSkill FROM users WHERE id = @id", {['@id'] = user_id})
		if #rows > 0 then
			Citizen.Wait(2500)

			--local coords = rows[1].userCoords or {x = -1276.8514404297, y = 310.49853515625, z = 65.511672973633}
			vRPclient.teleport(player, {rows[1].x, rows[1].y, rows[1].z + 1})

			TriggerClientEvent("getOnlinePly", -1, GetNumPlayerIndices())
			TriggerClientEvent("vRP:setClientId", player, user_id)

			local healthAsNum = tonumber(rows[1].userHealth or 200)
			vRPclient.setHealth(player, {healthAsNum})
	
			local armourAsNum = tonumber(rows[1].armour or 0)
			if armourAsNum > 0 then
			vRPclient.setArmour(player, {armourAsNum, false})
			end

			playerJobSkill[user_id] = {}

			if type(json.decode(rows[1].jobSkill)) == "table" then
				for k, data in pairs(json.decode(rows[1].jobSkill)) do
					if data.job then
						playerJobSkill[user_id][data.job] = data
					end
				end
			end

			-- notify last login
			Citizen.SetTimeout(1500, function()
				vRPclient.notify(player, {"Bine ai venit pe Ryde!"})
			end)

			Player(player).state.user_id = tonumber(user_id)
		else -- not first spawn (player died)
			Citizen.CreateThread(function()
				vRP.clearInventory(user_id)
				vRP.setMoney(user_id, 0)

				Citizen.Wait(150)
				task_save_oneUser(user_id)
			end)

			SetPlayerRoutingBucket(player, 0)

			vRPclient.setHealth(player, {200})
		
			TriggerClientEvent("vrp-inventory:forceUnequipAll", player)

			-- disable handcuff
			vRPclient.setHandcuff(player,{false})

			local x, y, z = deathPosition.x, deathPosition.y, deathPosition.z
			if vRP.isUserPolitist(user_id) then
				x, y, z = policeRespawn.x, policeRespawn.y, policeRespawn.z
			end

			playerPositions[user_id] = {x, y, z}

			vRPclient.teleport(player, {x, y, z})
		end
		Citizen.SetTimeout(3500, function()
			refreshUserTattoos(user_id, player)
		end)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, thePlayer)
	vRPclient.savePlayerCoords(thePlayer, {})
	TriggerClientEvent("getOnlinePly", -1, GetNumPlayerIndices())
	Citizen.Wait(1500)

	if playerPositions[user_id] then
		local x, y, z = table.unpack(playerPositions[user_id])
		exports.oxmysql:execute("UPDATE users SET x = @x,y = @y,z = @z WHERE id = @id",{
			['@id'] = user_id,
			['@x'] = x,
			['@y'] = y,
			['@z'] = z
		})

		playerPositions[user_id] = nil
	end

	if type(playerJobSkill[user_id]) == "table" then
		if next(playerJobSkill[user_id]) then
			exports.oxmysql:execute("UPDATE users SET jobSkill = @jobSkill WHERE id = @id",{
				['@id'] = user_id,
				['@jobSkill'] = json.encode(playerJobSkill[user_id])
			})
		end

		playerJobSkill[user_id] = nil
	end

	if playerHealth[user_id] then
		exports.oxmysql:execute("UPDATE users SET userHealth = @userHealth, armour = @armour WHERE id = @id",{
			['@id'] = user_id,
			['@userHealth'] = tonumber(playerHealth[user_id]),
			['@armour'] = tonumber(playerArmor[user_id])
		})

		playerHealth[user_id] = nil
	end
end)

RegisterCommand("savepos", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.isUserDeveloper(user_id) then
		vRPclient.getPosition(player, {}, function(x, y, z)
			exports.oxmysql:execute("UPDATE users SET x = @x,y = @y,z = @z WHERE id = @id",{
				['@id'] = user_id,
				['@x'] = x,
				['@y'] = y,
				['@z'] = z
			})
			vRPclient.notify(player, {"Pozitia ti-a fost salvata!", "info"})
		end)
	else
		vRPclient.notify(player, {"Nu ai acces la aceasta comanda", "error"})
	end
end)

function tvRP.updatePos(x,y,z)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		playerPositions[user_id] = {x, y, z}
	end
end

function tvRP.updateWeapons(weapons)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.weapons = weapons
    end
  end
end

function tvRP.updateCustomization(customization)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.customization = customization
    end
  end
end

function tvRP.updateHealth(health)
 	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		playerHealth[user_id] = tonumber(health)
	end
end

function tvRP.updateArmour(armor)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
  	playerArmor[user_id] = tonumber(armor)
  end
end

RegisterServerEvent("vRP:updatePlayerState", function()
	local player = source
	local user_id = vRP.getUserId(player)
	local playerPed = GetPlayerPed(player)

	local newPos = GetEntityCoords(playerPed)
	local newHealth = GetEntityHealth(playerPed)
	local newArmour = GetPedArmour(playerPed)

	if not user_id then
		return DropPlayer(player, "A aparut o eroare la incarcarea contului tau.")
	end

	playerPositions[user_id] = {newPos.x, newPos.y, newPos.z}
	playerHealth[user_id] = newHealth
	playerArmor[user_id] = newArmour
end)

-- [PLAYER JOB SKILLS]

function vRP.SaveUserJobSkill(user_id)
    if type(playerJobSkill[user_id]) == "table" then
        if next(playerJobSkill[user_id]) then
			exports.oxmysql:execute("UPDATE users SET jobSkill = @jobSkill WHERE id = @id",{
				['@id'] = user_id,
				['@jobSkill'] = json.encode(playerJobSkill[user_id])
			})
        end
    end
end

function vRP.GetUserJobExperience(user_id, job)
    if playerJobSkill[user_id] then
        if playerJobSkill[user_id][job] then
            return playerJobSkill[user_id][job].experience
        end
    end
    return 0
end

function vRP.UpdateUserJobExperience(user_id, job, experience)
    if playerJobSkill[user_id] then
        if playerJobSkill[user_id][job] then
            playerJobSkill[user_id][job].experience = experience
        else 
            playerJobSkill[user_id][job] = {job = job, experience = experience}
        end
    end
end

function vRP.IncreaseUserJobExperience(user_id, job, experience)
    if playerJobSkill[user_id] then
        if playerJobSkill[user_id][job] then
            playerJobSkill[user_id][job].experience = playerJobSkill[user_id][job].experience + experience
        else
            playerJobSkill[user_id][job] = {job = job, experience = experience}
        end
    end
end

function vRP.setUserJobSkill(user_id, job, experience)
    if playerJobSkill[user_id] then
        if playerJobSkill[user_id][job] then
            playerJobSkill[user_id][job].experience = experience
        else
            playerJobSkill[user_id][job] = {experience = experience}
        end
    end
end