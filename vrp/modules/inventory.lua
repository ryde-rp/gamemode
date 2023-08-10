local trashNotify = "Ai aruncat %d %s";
local recievedNotify = "Ai primit %d %s";
local missingNotify = "Lipsesc %d %s";
local givenNotify = "Ai oferit %d %s";

local cfg = module("cfg/inventory")
local AmmoTable = module('cfg/item/ammo')

vRP.items = {}

local activeBags = {}
local bagsData = {
  ["Ghiozdan Mic"] = {
    space = 20,
    item = "ghiozdanMic",
  },

  ["Ghiozdan Mediu"] = {
    space = 35,
    item = "ghiozdanMediu",
  },

  ["Ghiozdan Mare"] = {
    space = 50,
    item = "ghiozdanMare",
  },

  ["Borseta"] = {
    space = 5,
    item = "borsetaMica",
  },

  ["Geanta"] = {
    space = 35,
    item = "geanta",
  },
}

local function checkBackpack(user_id)
  local bag = activeBags[user_id]
  if bag then
    return tonumber(bagsData[bag].space)
  end

  return 0
end

function checkIfBag(user_id)
  if activeBags[user_id] then
    return true, activeBags[user_id]
  end
  
  return false, ""
end

vRP.hasAnyBagEquipped = checkIfBag

function getBackpack(user_id)
  return activeBags[user_id]
end

function updateBackpack(user_id, backpack)
  if not backpack then
    if vRP.hasInventoryItem(user_id, "ghiozdanMare") then
      activeBags[user_id] = "Ghiozdan Mare"
    elseif vRP.hasInventoryItem(user_id, "geanta") then
      activeBags[user_id] = "Geanta"
    elseif vRP.hasInventoryItem(user_id, "ghiozdanMediu") then
      activeBags[user_id] = "Ghiozdan Mediu"
    elseif vRP.hasInventoryItem(user_id, "ghiozdanMic") then
      activeBags[user_id] = "Ghiozdan Mic"
    elseif vRP.hasInventoryItem(user_id, "borsetaMica") then
   	  activeBags[user_id] = "Borseta"
    end
  else
    activeBags[user_id] = backpack
  end

  local source = vRP.getUserSource(user_id)
  if source and activeBags[user_id] then
    TriggerClientEvent("vRP:setBackpackProp", source, activeBags[user_id])
  end
end

function removeBackpack(source, user_id)
  local currentBag = activeBags[user_id]

  if currentBag then
    local userInventory = vRP.getInventoryWeight(user_id)
    local userWeight = vRP.getInventoryMaxWeight(user_id)

    if userInventory > (userWeight - bagsData[currentBag].space) then
      vRPclient.notify(source, {"Nu ai destul spatiu pentru a-ti dezechipa ghiozdanul!", "warning"})
      return false;
    end

    activeBags[user_id] = nil
    TriggerClientEvent("vRP:setBackpackProp", source, false)
    vRPclient.notify(source, {"Ai dezechipat "..currentBag})
  end
  return true;
end

function vRP.hasInventoryItem(user_id, item, amount)
  if not amount then
    amount = 1
  end

  local itemData = vRP.getInventoryItemAmount(user_id, item)
  if itemData >= amount then
    return true
  end

  return false
end

function vRP.defInventoryItem(idname,name,description,choices,weight,category)
  if not weight then weight = 0 end
  if not category then category = "pocket" end
  
  local item = {name=name,description=description,choices=choices,weight=weight,category=category}
  vRP.items[idname] = item

  item.ch_give = function(player,choice) end

  item.ch_trash = function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      vRP.prompt(player, "DROP ITEM", {
        {field = "amount", title = "CANTITATE ARUNCATA", number = true},
      }, function(player,res)
        local amount = res["amount"]

        if vRP.tryGetInventoryItem(user_id,idname,amount,false) then
          vRPclient.notify(player,{trashNotify:format(amount,vRP.getItemName(idname)), "warning"})
          vRPclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
        else
          vRPclient.notify(player,{"Valoare invalida!", "error"})
        end
      end)
    end
  end
end

local function ch_give(idname, player, choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    vRPclient.getNearestPlayer(player, {8}, function(target)
      local pID = vRP.getUserId(target)
      if pID then
      
        vRP.prompt(player, "GIVE ITEM", {
          {field = "amount", title = "CANTITATE OFERITA", number = true},
        }, function(player,res)
          local amount = res["amount"]
          local new_weight = vRP.getInventoryWeight(pID)+vRP.getItemWeight(idname)*amount

          if new_weight <= vRP.getInventoryMaxWeight(pID) then
            if vRP.tryGetInventoryItem(user_id,idname,amount,true) then
              vRP.giveInventoryItem(pID,idname,amount,true)
              
              vRPclient.playAnim(player,{true,{{"mp_common","givetake1_a",1}},false})
              vRPclient.playAnim(target,{true,{{"mp_common","givetake2_a",1}},false})
            else
              vRPclient.notify(player,{"Valoare invalida.", "error"})
            end
          else
            vRPclient.notify(player,{"Inventarul este plin.", "error"})
          end
        end)

      else
        vRPclient.notify("Nu au fost gasiti jucatori in apropiere!", "error")
      end
    end)
  end
end

local function ch_trash(idname, player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRP.prompt(player, "DROP ITEM", {
      {field = "amount", title = "CANTITATE ARUNCATA", number = true},
    }, function(player,res)
      local amount = res["amount"]

      if vRP.tryGetInventoryItem(user_id,idname,amount,false) then

        vRPclient.notify(player,{trashNotify:format(amount, vRP.getItemName(idname)), "warning"})
        vRPclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
      
      else
        vRPclient.notify(player,{"Valoare invalida.", "error"})
      end
    end)
  end
end

function vRP.computeItemName(item,args)
  if type(item.name) == "string" then return item.name
  else return item.name(args) end
end

function vRP.computeItemDescription(item,args)
  if type(item.description) == "string" then return item.description
  else return item.description(args) end
end

function vRP.computeItemChoices(item,args)
  if item.choices ~= nil then
    return item.choices(args)
  else
    return {}
  end
end

function vRP.computeItemWeight(item,args)
  if type(item.weight) == "number" then return item.weight
  else return item.weight(args) end
end

function vRP.computeItemCategory(item,args)
  if type(item.category) == "string" then return item.category
  elseif item.category == nil then return "pocket"
  else return item.category(args) end
end

function vRP.parseItem(idname)
  -- return splitString(idname,"|")
  return {idname}
end

function vRP.getBagName(item)
	for bag, bagData in pairs(bagsData) do
		if bagData.item == item then
			return bag
		end
	end
end

function vRP.getItemDefinition(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  if item ~= nil then
    return vRP.computeItemName(item,args), vRP.computeItemDescription(item,args), vRP.computeItemWeight(item,args), vRP.computeItemCategory(item,args)
  end

  return nil,nil,nil,nil
end

function vRP.getItemName(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  if item ~= nil then
    return vRP.computeItemName(item,args)
  end

  return args[1]
end

function vRP.getItemDescription(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  if item ~= nil then
    return vRP.computeItemDescription(item,args)
  end

  return ""
end

function vRP.getItemChoices(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  local choices = {}
  if item ~= nil then
    local cchoices = vRP.computeItemChoices(item,args)
    if cchoices then
      for k,v in pairs(cchoices) do
        choices[k] = v
      end
    end

    choices["Ofera"] = {function(player,choice) ch_give(idname, player, choice) end}
    choices["Arunca"] = {function(player, choice) ch_trash(idname, player, choice) end}
  end

  return choices
end

function vRP.getItemWeight(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  if item ~= nil then return vRP.computeItemWeight(item,args) end
  return 0
end

function vRP.canCarryItem(user_id, theItem, amount, notify)
  local source = vRP.getUserSource(user_id)
  local new_weight = vRP.getInventoryWeight(user_id)+vRP.getItemWeight(theItem)*amount
  if (new_weight <= vRP.getInventoryMaxWeight(user_id)) then
    return true
  else
    if notify then
      vRPclient.notify(source, {"Nu ai destul spatiu in inventar!", "error"})
    end
  end
  return false
end

function vRP.canChestCarryItem(chestWeight, chestTotalWeight, theItem, amount, notify)
  local new_weight = chestWeight + vRP.getItemWeight(theItem) * amount
  if (new_weight <= chestTotalWeight) then
    return true
  else
    if notify then
      vRPclient.notify(source, {"Cufarul este plin!", "error"})
    end
  end
  return false
end

function vRP.canCarryNoBag(user_id, bag, notify)
    local currentBag = bag or activeBags[user_id]
    if currentBag then
    	local userInventory = vRP.getInventoryWeight(user_id)
    	local userWeight = vRP.getInventoryMaxWeight(user_id)
    	local source = vRP.getUserSource(user_id)

    	if userInventory > (userWeight - bagsData[currentBag].space) then
    		if notify then
      		vRPclient.notify(source, {"Nu ai destul spatiu pentru a efectua aceasta actiune!", "warning"})
    		end

    		return false
    	end
	end
    return true
end

function vRP.getKeyDesc(idname)
  local args = vRP.parseItem(idname)
  if(args[2] ~= nil)then
    return args[2]
  end
  return nil
end

function vRP.getItemCategory(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[args[1]]
  if item ~= nil then return vRP.computeItemCategory(item,args) end
  return ""
end

function vRP.computeItemsWeight(items)
  local weight = 0

  for k,v in pairs(items) do
    local iweight = vRP.getItemWeight(k)
    weight = weight+iweight*v.amount
  end

  return weight
end

function vRP.giveInventoryItem(user_id,idname,amount,notify,desc)
  if notify == nil then notify = true end
  if desc == nil then desc = nil end
  local data = vRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then
      entry.amount = entry.amount+amount
      entry.desc = desc
      if AmmoTable[idname] then
        local player = vRP.getUserSource(user_id)
        TriggerClientEvent("vrp-inventory:UpdateClientBullets", player, idname, entry.amount)
      end
    else
      data.inventory[idname] = {amount=amount,desc=desc}
      entry = data.inventory[idname]
    end
    task_save_oneUser(user_id)
    if notify then
      local player = vRP.getUserSource(user_id)
      if player ~= nil then
        vRPclient.notify(player,{recievedNotify:format(amount, vRP.getItemName(idname))})
      end
    end
  end
end


function vRP.setInventoryItemAmount(user_id, idname, amount)
  local data = vRP.getUserDataTable(user_id)
  if data then
    local entry = data.inventory[idname]

    if amount > 0 then
      if entry then
        entry.amount = amount
      else
        data.inventory[idname] = {amount = amount}
      end
    else
      data.inventory[idname] = nil
    end

    task_save_oneUser(user_id)
  end
end

local function IsThatItemUserBag(user_id, idname)
  local hasBag = activeBags[user_id]
  local isItemBag = false
  if hasBag then
    for k,v in pairs(bagsData) do
      if v.item == idname then
        isItemBag = true;
      end
    end
    if not isItemBag then return false end;
    if bagsData[hasBag].item == idname then return true end;
  end
  return false
end

function vRP.tryGetInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end
  local player = vRP.getUserSource(user_id)
  local data = vRP.getUserDataTable(user_id)
  local hasBag  = activeBags[user_id]

  if data and amount > 0 then
    if idname then
      local entry = data.inventory[idname]
      if entry and entry.amount >= amount then
        if IsThatItemUserBag(user_id, idname) then
          local canRemove = removeBackpack(player, user_id)

          if not canRemove then return false end;

          if entry.amount <= 0 then
            data.inventory[idname] = nil 
          end

          entry.amount = entry.amount-amount
      
          if notify then
              vRPclient.notify(player,{givenNotify:format(amount,vRP.getItemName(idname)), "success"})
          end
  
          task_save_oneUser(user_id)
          return true
        end

        entry.amount = entry.amount-amount
        if entry.amount <= 0 then
          data.inventory[idname] = nil 
        end
    
        if notify then
            vRPclient.notify(player,{givenNotify:format(amount,vRP.getItemName(idname)), "success"})
        end

        task_save_oneUser(user_id)
        return true
      else
        if notify then
          local player = vRP.getUserSource(user_id)
          if player ~= nil then
            local entry_amount = 0
            if entry then
              entry_amount = entry.amount
            end

            vRPclient.notify(player,{missingNotify:format(amount-entry_amount,vRP.getItemName(idname)), "warning"})
          end
        end
      end
    end
  end
  return false
end

function vRP.getInventoryItemAmount(user_id,idname)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

function vRP.getInventoryItemDesc(user_id,idname)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.desc
    end
  end

  return ""
end

function vRP.getInventoryWeight(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    return vRP.computeItemsWeight(data.inventory)
  end

  return 0
end

function vRP.getInventoryMaxWeight(user_id)
  local uAptitude = cfg.inventory_weight_per_strength
  local addedWeight = checkBackpack(user_id)

  return math.floor(uAptitude) + addedWeight
end

function vRP.removeBag(user_id)
	local source = vRP.getUserSource(user_id)
	if source then
		removeBackpack(source, user_id)
	end
end

function vRP.clearInventory(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end

function vRP.getInventoryItems(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.inventory or {}
  end

  return {}
end


local chests = {}

RegisterCommand("fixchests", function(player)
  if player == 0 then
    chests = {}
    print("FP:SYSTEM: Chest-urile au fost resetate cu success")
  end
end)


function vRP.openChest(player, name, max_weight,chest_name,isVehicle, cb_close)
  if not chests[name] then
    chests[name] = true
    vRP.closeMenu(player)

    exports['vrp_inventory']:openChest(player, name, max_weight, chest_name,isVehicle, function()
      chests[name] = nil
      if type(cb_close) == "function" then
        cb_close();
      end
    end)
  else
    vRPclient.notify(player, {"Acest cufar este deja folosit de catre altcineva", "error"})
  end
end


AddEventHandler("vRP:playerJoin", function(user_id,source,name)
  local data = vRP.getUserDataTable(user_id)
  if data.inventory == nil then
    data.inventory = {}
  end
end)


AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
  if not first_spawn then
    return
  end

  Citizen.CreateThread(function()
    Citizen.Wait(1500)
    updateBackpack(user_id)
  end)
end)

Citizen.CreateThread(function()
  local theItems = module("cfg/items")

  for item, itemData in pairs(theItems.items) do
    vRP.defInventoryItem(item, itemData.name, itemData.description, itemData.choices, itemData.weight, itemData.category)
  end
end)
