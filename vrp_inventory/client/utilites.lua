local RVInv = Tunnel.getInterface("vrp_inventory", "vrp_inventory")

local TropicalINV = {}
Tunnel.bindInterface("vrp_inventory", TropicalINV)

local EquipedItems = {}
local ammo = {}
local hasToWait = false

TropicalINV.hasItemEquiped = function(item)
    for k, v in pairs(EquipedItems) do
        if v.name == item then
            return true
        end
    end
    return false
end

-- local lastAmmoUpdate = {}

-- AddEventHandler("CEventGunShot", function(_,eventEntity,_)
--     if eventEntity == PlayerPedId() then
--         local arma = GetSelectedPedWeapon(PlayerPedId())
--         if arma ~= 'WEAPON_UNARMED' then
--             for k,v in pairs(ammo) do
--                 if v.ammo then
--                     local hash = GetHashKey(k)
--                     if GetSelectedPedWeapon(PlayerPedId()) == hash then
--                         if not lastAmmoUpdate[k] then lastAmmoUpdate[k] = 0 end
--                         local ammo = GetAmmoInPedWeapon(PlayerPedId(), hash)
--                         v.ammo = ammo
--                         lastAmmoUpdate[k] = lastAmmoUpdate[k] + 1
--                         if lastAmmoUpdate[k] > 3 then
--                             TriggerServerEvent("vrp-inventory:setAmmo", v.weapon, v.ammo, false)
--                             lastAmmoUpdate[k] = 0
--                         end
--                         break
--                     end
--                 end
--             end
--         end
--     end
-- end)

local lastAmmoUpdate = {}

AddEventHandler("CEventGunShot", function(_,eventEntity,_)
    if eventEntity == PlayerPedId() then
        local arma = GetSelectedPedWeapon(PlayerPedId())
        if arma ~= 'WEAPON_UNARMED' then
            for k,v in pairs(ammo) do
                if v.ammo then
                    local hash = GetHashKey(k)
                    if GetSelectedPedWeapon(PlayerPedId()) == hash then
                        if not lastAmmoUpdate[k] then lastAmmoUpdate[k] = 0 end
                        local ammo = GetAmmoInPedWeapon(PlayerPedId(), hash)
                        v.ammo = ammo
                        lastAmmoUpdate[k] = lastAmmoUpdate[k] + 1
                        if lastAmmoUpdate[k] > 3 or (ammo - 1) <= 1 then
                            TriggerServerEvent("vrp-inventory:setAmmo", v.weapon, (v.ammo - 1), false)
                            lastAmmoUpdate[k] = 0
                        end
                        if ammo == 0 and eqqNow ~= "" then
                            EquipedItems[eqqNow] = nil
                            SendNUIMessage({action = "refreshUtilitati"})
                            eqqNow = ""
                        end
                        break
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 16, true)
        DisableControlAction(0, 17, true)
        DisableControlAction(0, 157, true)
        DisableControlAction(0, 158, true)
        DisableControlAction(0, 159, true)
        DisableControlAction(0, 160, true)
        DisableControlAction(0, 161, true)
        DisableControlAction(0, 162, true)
        DisableControlAction(0, 163, true)
        DisableControlAction(0, 164, true)
        DisableControlAction(0, 165, true)
    end
end)

RegisterCommand("slot1", function()
    if not hasToWait then
        if EquipedItems['slot-1'] then
            if Config.Weapons[EquipedItems['slot-1'].name] then
                local arma = Config.Weapons[EquipedItems['slot-1'].name].weapon
                local hash = GetHashKey(arma)
                if GetSelectedPedWeapon(PlayerPedId()) ~= hash then 
                    if Config.Weapons[EquipedItems['slot-1'].name].meele then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    else
                        RVInv.GetWeaponAmmo({EquipedItems['slot-1'].name}, function(nAmmo)
                            if nAmmo > 0 then
                                ammo[arma].ammo = nAmmo
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                                SetCurrentPedWeapon(PlayerPedId(), hash, true)
                                if ammo[arma].ammo then
                                    SetPedAmmo(PlayerPedId(), hash, ammo[arma].ammo)
                                end
                            end
                        end)
                    end
                else
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
                end
                hasToWait = true
                SetTimeout(2000, function()
                    hasToWait = false
                end)
            else 
                TriggerServerEvent("ad-inventory:useItem", EquipedItems['slot-1'].name)
            end 
        end
    end
end)

RegisterCommand("slot2", function()
    if not hasToWait then
        if EquipedItems['slot-2'] then
            if Config.Weapons[EquipedItems['slot-2'].name] then
                local arma = Config.Weapons[EquipedItems['slot-2'].name].weapon
                local hash = GetHashKey(arma)
                if GetSelectedPedWeapon(PlayerPedId()) ~= hash then 
                    if Config.Weapons[EquipedItems['slot-2'].name].meele then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    else
                        RVInv.GetWeaponAmmo({EquipedItems['slot-2'].name}, function(nAmmo)
                            if nAmmo > 0 then
                                ammo[arma].ammo = nAmmo
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                                SetCurrentPedWeapon(PlayerPedId(), hash, true)
                                if ammo[arma].ammo then
                                    SetPedAmmo(PlayerPedId(), hash, ammo[arma].ammo)
                                end
                            end
                        end)
                    end
                else
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
                end
                hasToWait = true
                SetTimeout(2000, function()
                    hasToWait = false
                end)
            else
                TriggerServerEvent("ad-inventory:useItem", EquipedItems['slot-2'].name)
            end 
        end
    end
end)

RegisterCommand("slot3", function()
    if not hasToWait then
        if EquipedItems['slot-3'] then
            if Config.Weapons[EquipedItems['slot-3'].name] then
                local arma = Config.Weapons[EquipedItems['slot-3'].name].weapon
                local hash = GetHashKey(arma)
                if GetSelectedPedWeapon(PlayerPedId()) ~= hash then 
                    if Config.Weapons[EquipedItems['slot-3'].name].meele then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    else
                        RVInv.GetWeaponAmmo({EquipedItems['slot-3'].name}, function(nAmmo)
                            if nAmmo > 0 then
                                ammo[arma].ammo = nAmmo
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                                SetCurrentPedWeapon(PlayerPedId(), hash, true)
                                if ammo[arma].ammo then
                                    SetPedAmmo(PlayerPedId(), hash, ammo[arma].ammo)
                                end
                            end
                        end)
                    end
                else
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
                end
                hasToWait = true
                SetTimeout(2000, function()
                    hasToWait = false
                end)
            else
                TriggerServerEvent("ad-inventory:useItem", EquipedItems['slot-3'].name)
            end
        end
    end
end)

RegisterCommand("slot4", function()
    if not hasToWait then
        if EquipedItems['slot-4'] then
            if Config.Weapons[EquipedItems['slot-4'].name] then
                local arma = Config.Weapons[EquipedItems['slot-4'].name].weapon
                local hash = GetHashKey(arma)
                if GetSelectedPedWeapon(PlayerPedId()) ~= hash then 
                    if Config.Weapons[EquipedItems['slot-4'].name].meele then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    else
                        RVInv.GetWeaponAmmo({EquipedItems['slot-4'].name}, function(nAmmo)
                            if nAmmo > 0 then
                                ammo[arma].ammo = nAmmo
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                                SetCurrentPedWeapon(PlayerPedId(), hash, true)
                                if ammo[arma].ammo then
                                    SetPedAmmo(PlayerPedId(), hash, ammo[arma].ammo)
                                end
                            end
                        end)
                    end
                else
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
                end
                hasToWait = true
                SetTimeout(2000, function()
                    hasToWait = false
                end)
            else
                TriggerServerEvent("ad-inventory:useItem", EquipedItems['slot-4'].name)
            end
        end
    end
end)

RegisterCommand("slot5", function()
    if not hasToWait then
        if EquipedItems['slot-5'] then
            if Config.Weapons[EquipedItems['slot-5'].name] then
                local arma = Config.Weapons[EquipedItems['slot-5'].name].weapon
                local hash = GetHashKey(arma)
                if GetSelectedPedWeapon(PlayerPedId()) ~= hash then 
                    if Config.Weapons[EquipedItems['slot-5'].name].meele then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                        SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    else
                        RVInv.GetWeaponAmmo({EquipedItems['slot-5'].name}, function(nAmmo)
                            if nAmmo > 0 then
                                ammo[arma].ammo = nAmmo
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                                SetCurrentPedWeapon(PlayerPedId(), hash, true)
                                if ammo[arma].ammo then
                                    SetPedAmmo(PlayerPedId(), hash, ammo[arma].ammo)
                                end
                            end
                        end)
                    end
                else
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
                end
                hasToWait = true
                SetTimeout(2000, function()
                    hasToWait = false
                end)
            else
                TriggerServerEvent("ad-inventory:useItem", EquipedItems['slot-5'].name)
            end
        end
    end
end)

RegisterNUICallback("EquipItem", function(data, cb)
    EquipedItems[data.tip] = {
        name = data.name,
        amount = 1,
    }
    if Config.Weapons[data.name] then
        if Config.Weapons[data.name].meele then
            local hash = GetHashKey(arma)
            GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
            SetCurrentPedWeapon(PlayerPedId(), hash, true)
        else
            RVInv.GetWeaponAmmo({EquipedItems[data.tip].name}, function(nAmmo)
                if nAmmo > 0 then
                    local arma = Config.Weapons[EquipedItems[data.tip].name].weapon
                    local usedAmmo = Config.Weapons[EquipedItems[data.tip].name].ammoUsed
                    ammo[arma] = {
                        ammo = nAmmo,
                        weapon = data.name,
                        usedAmmo = usedAmmo,
                    }
                    SetPedAmmo(PlayerPedId(), GetHashKey(arma), tonumber(nAmmo))
                    local hash = GetHashKey(arma)
                    GiveWeaponToPed(PlayerPedId(), hash, 0, false, true)
                    SetCurrentPedWeapon(PlayerPedId(), hash, true)
                    SetPedAmmo(PlayerPedId(), hash, ammo[Config.Weapons[EquipedItems[data.tip].name].weapon].ammo)
                end
            end)
        end
    end
    cb(true)
end)

local function GetItemSlot(item)
    for k, v in pairs(EquipedItems) do
        if v.name == item then
            return k
        end
    end
    return false
end

RegisterNetEvent("vrp-inventory:RemoveWeapon", function(weapon)
    local itemType = GetItemSlot(weapon)
    if itemType then
        local hash = GetHashKey(Config.Weapons[EquipedItems[tostring(itemType)]].weapon)
        SetPedAmmo(PlayerPedId(), hash, 0)
        ammo[Config.Weapons[EquipedItems[tostring(itemType)].name].weapon] = nil
        RemoveWeaponFromPed(PlayerPedId(), hash)
        SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
        EquipedItems[tostring(itemType)] = nil
        SendNUIMessage({action = "refreshUtilitati"})
    end
end)

RegisterNetEvent("Tropical:UnequipItem", function(item)
    local itemType = tostring(GetItemSlot(item))
    EquipedItems[itemType] = nil
    SendNUIMessage({action = "refreshUtilitati"})
end)

RegisterNUICallback("UnequipItem", function(data, cb)
    if Config.Weapons[data.name] then
        if Config.Weapons[data.name].meele then
            EquipedItems[data.tip] = nil
            SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
            RemoveAllPedWeapons(PlayerPedId(), true)
        else
            if ammo[Config.Weapons[data.name].weapon] then
                TriggerServerEvent("vrp-inventory:unequipWeapon", ammo[Config.Weapons[data.name].weapon].ammo, data.name)
                local hash = GetHashKey(Config.Weapons[data.name].weapon)
                SetPedAmmo(PlayerPedId(), hash, 0)
                ammo[Config.Weapons[data.name].weapon] = nil
            end
            RemoveWeaponFromPed(PlayerPedId(), hash)
            SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
            EquipedItems[data.tip] = nil
        end
    else
        EquipedItems[data.tip] = nil
        SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
        RemoveAllPedWeapons(PlayerPedId(), true)
    end
    cb(true)
end)
RegisterNetEvent("vrp-inventory:UpdateClientBullets", function(ammoType, number)
    for k, v in pairs(ammo) do
        if v.usedAmmo == ammoType then
            v.ammo = number
            local arma = GetSelectedPedWeapon(PlayerPedId())
            if arma ~= 'WEAPON_UNARMED' then
                SetPedAmmo(PlayerPedId(), GetHashKey(Config.Weapons[v.weapon].weapon), number)
            end
        end
    end
end)

RegisterNetEvent("vrp-inventory:forceUnequipAll", function()
    EquipedItems = {}
    SetCurrentPedWeapon(PlayerPedId(), 'WEAPON_UNARMED', true)
    RemoveAllPedWeapons(PlayerPedId(), true)
    SendNUIMessage({action = "refreshUtilitati"})
end)

RegisterNUICallback("GetItems", function(data, cb)
    if data then
        cb(EquipedItems)
    end
end)

RegisterKeyMapping('slot1', 'Obiect [1]', 'keyboard', "1")
RegisterKeyMapping('slot2', 'Obiect [2]', 'keyboard', "2")
RegisterKeyMapping('slot3', 'Obiect [3]', 'keyboard', "3")
RegisterKeyMapping('slot4', 'Obiect [4]', 'keyboard', "4")
RegisterKeyMapping('slot5', 'Obiect [5]', 'keyboard', "5")