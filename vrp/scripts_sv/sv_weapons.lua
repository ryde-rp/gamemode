local ServerAmmo = module("cfg/item/ammo")
local ServerWeapons = module("cfg/item/weapons")

for k, v in pairs(ServerWeapons) do
    vRP.defInventoryItem(k, v.nume, "", function(args)
        local choices = {}
        local itemName = args[1]
  
        choices["Echipeaza"] = {function(player, choice)
            local user_id = vRP.getUserId(player)
            if vRP.tryGetInventoryItem(user_id, itemName, 1, true) then
                local weapons = {}
                weapons[ServerWeapons[itemName].weapon] = {ammo = 0}
                vRPclient.giveWeapons(player, {weapons})
                vRPclient.notify(player, {"Ai echipat "..ServerWeapons[itemName].nume.." !", "info", false, "fas fa-gun"})
            end
        end}
  
        return choices
    end, 0.75, "gun")
  end
  
  for k, v in pairs(ServerAmmo) do
    vRP.defInventoryItem(k, v.nume, "", function(args)
        local choices = {}
        local itemName = args[1]
  
    choices["Echipeaza"] = {function(player, choice)
      local user_id = vRP.getUserId(player)
  
      local amount = vRP.getInventoryItemAmount(user_id, itemName)
      vRP.prompt(player, "EQUIP AMMO", {
        {field = "ramount", title = "Cat incarci ? (max "..amount..")", text = amount, number = true},
      }, function(player,res)
        local ramount = res["ramount"]
        if not ramount then return end

        vRPclient.getWeaponInHand(player, {}, function(uWeapon)
            if uWeapon == GetHashKey(ServerAmmo[itemName].weapon) then
              if vRP.tryGetInventoryItem(user_id, itemName, tonumber(ramount), true) then
                    local weapons = {}
                    weapons[ServerAmmo[itemName].weapon] = {ammo = ramount}
                    vRPclient.giveWeapons(player, {weapons,false})
                end
            else
              vRPclient.notify(player, {"Trebuie sa ai arma in mana pentru a putea incarca gloante!", "error"})
            end
          end)
      end)
    end}
        return choices
    end, 0.01, "gun")
  end
  
-- Strange Armele

local weaponAttachments = {
	["Suppressor"] = "suppressor",
	["Grip"] = "grip",
	["Flashlight"] = "lanterna",
	["Scope"] = "scope",
	["Extended Clip"] = "extended_clip",
}

local StrangeArmeleCooldown = {}

function vRP.storeWeapons(user_id)
    local player = vRP.getUserSource(user_id)
    if vRP.isUserPolitist(user_id) or vRP.isUserMedic(user_id) then return vRPclient.notify(player, {"Nu poti depozita armele!", "error"}) end

    if (StrangeArmeleCooldown[user_id] or 0) <= os.time() then
        vRPclient.isInComa(player, {}, function(inComa)
            if inComa then return vRPclient.notify(player, {"Nu iti poti strange armele mort!", "error"}) end;

            StrangeArmeleCooldown[user_id] = os.time() + 60 * 3
    
            vRPclient.getWeapons(player, {}, function(uWeapons)
                if #uWeapons == 0 then
                    return vRPclient.notify(player, {"Nu ai arme echipate!", "error", false, "fas fa-gun"})
                end
        
                Citizen.CreateThread(function()
                    vRPclient.clearWeapons(player, {true})
                    vRPclient.notify(player, {"🔫 Urmeaza sa primesti armele in inventar dupa 5 secunde...", false, "fas fa-gun"})
                    Citizen.Wait(5000)
        
                    vRPclient.getAvailableAttachments(player, {}, function(theAttachments)
                        for _, weaponData in pairs(uWeapons) do
                            if weaponData.ammo > 0 then
                                for k, v in pairs(ServerAmmo) do
                                    if weaponData.model == v.weapon then
                                        vRP.giveInventoryItem(user_id, k, tonumber(weaponData.ammo), true)
                                    end
                                end
                            end
        
                            local wAttachments = weaponData.attach
                            if table.notEmpty(wAttachments) then
                                local givenAttachments = {}
                                for _, attachment in pairs(wAttachments) do
                                    local attachmentName = theAttachments[attachment]
        
                                    if attachmentName then
                                        if not givenAttachments[attachmentName] then
                                            givenAttachments[attachmentName] = true
                                            vRP.giveInventoryItem({user_id, weaponAttachments[attachmentName], 1, true})
                                        end
                                    end
                                end
                            end
        
                            for k, v in pairs(ServerWeapons) do
                                if weaponData.model == v.weapon then
                                    vRP.giveInventoryItem(user_id, k, 1, true)
                                end
                            end
                        end
                    end)
        
                    vRPclient.notify(player, {"Ti-ai strans armele!", "success", false, "fas fa-gun"})
                end)
            end)
        end)
    else
        vRPclient.notify(player, {"Trebuie sa astepti "..StrangeArmeleCooldown[user_id] - os.time().." secunde inainte sa poti efectua aceasta actiune", "error", false, "fas fa-gun"})
    end
end

RegisterServerEvent("fp-inventory:storeWeapons", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if user_id then
        vRP.storeWeapons(user_id)
    end
end)