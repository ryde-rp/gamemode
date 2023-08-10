local inspectingPlayers = {}
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

local function inspectPlayer(player, user_id)
  if inspectingPlayers[user_id] then
    return vRPclient.notify(player, {"Inspectezi deja un jucator!", "error"})
  end

  vRPclient.getNearestPlayer(player,{1.5},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)

    if not nuser_id then
      return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
    end

    vRPclient.notify(nplayer, {"🔦 Ai fost perchezitionat!", "warning"})
    local money = vRP.getMoney(nuser_id)
    local items = ""
    local weapons = ""
    local data = vRP.getUserDataTable(nuser_id)
    local hasBag, theBag = checkIfBag(nuser_id)

    if data and data.inventory then
      local itemId = 0
      for k,v in pairs(data.inventory) do
        local item_name = vRP.getItemName(k)
        if item_name then
          itemId = itemId + 1
          items = items.."<br /> "..itemId..". "..item_name.." [x"..v.amount.."]"
        end
      end
    end

    if hasBag then
      if theBag == "Borseta" or theBag == "Ghiozdan Mic" then
        hasBag = false
      end
    end

    vRPclient.getWeapons(nplayer, {}, function(uWeapons)
      local weaponId = 0
      for _, weaponData in pairs(uWeapons) do
        local theWeapon = weaponData.model

        if theWeapon:find("PISTOL") or theWeapon:find("REVOLVER") or meeleeItems[theWeapon] then
          weaponId = weaponId + 1
          weapons = weapons.."<br /> "..weaponId..". "..(theWeapon:gsub("WEAPON_", ""):gsub("_", " ")).." - "..weaponData.ammo.." gloante"
        elseif hasBag then
          weaponId = weaponId + 1
          weapons = weapons.."<br /> "..weaponId..". "..(theWeapon:gsub("WEAPON_", ""):gsub("_", " ")).." - "..weaponData.ammo.." gloante"
        end
      end

      inspectingPlayers[user_id] = true
      vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},true})
      vRPclient.setDiv(player,{"perchezitioneaza",".div_perchezitioneaza{     background-color: #00000020; border: 2px solid #ffffff20; box-shadow: inset 0 0 .8vw #ffffff15; border-radius: .45vw; color: white; font-weight: bold; width: 25vw; padding: 2.5vh; margin: auto; margin-top: 10%; }","<center>📃 Rezultatele perchezitiei 📃<br><br><hr style='opacity: .5; width: 85%'><br><em><span style='font-style: normal;'>💵 Bani jucator:</span> </em>$"..vRP.formatMoney(money).."<br /><br /><em><span style='font-style: normal;'>🎒</span> Inventarul jucatorului <span style='font-style: normal;'>🎒</span></em><br />"..items.."<br /><br /><em><span style='font-style: normal;'>🔫</span> Armele jucatorului <span style='font-style: normal;'>🔫</span></em><br />"..weapons.."</center>"})
      
      Citizen.CreateThread(function()
        Citizen.Wait(10000)
        inspectingPlayers[user_id] = nil
        vRPclient.stopAnim(player, {true})
        vRPclient.removeDiv(player, {"perchezitioneaza"})
      end)
    end)
  end)
end

AddEventHandler("vRP:playerLeave", function(user_id)
  if inspectingPlayers[user_id] then
    inspectingPlayers[user_id] = nil
  end
end)