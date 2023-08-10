local canHolster, weapsToHolster = true, {
  [GetHashKey("WEAPON_DAGGER")] = true,
  [GetHashKey("WEAPON_KNIFE")] = true,
  [GetHashKey("WEAPON_BOTTLE")] = true,
  [GetHashKey("WEAPON_HATCHET")] = true,
  [GetHashKey("WEAPON_MACHETE")] = true,
  [GetHashKey("WEAPON_WRENCH")] = true,
  -- [GetHashKey("WEAPON_SWITCHBLADE")] = true,
  [GetHashKey("WEAPON_KNUCKLE")] = true,
  [GetHashKey("WEAPON_BATTLEAXE")] = true,
  [GetHashKey("WEAPON_FLASHLIGHT")] = true,
  [GetHashKey("WEAPON_NIGHTSTICK")] = true,
  [GetHashKey("WEAPON_HAMMER")] = true,
  [GetHashKey("WEAPON_BAT")] = true,
  [GetHashKey("WEAPON_GOLFCLUB")] = true,
  [GetHashKey("WEAPON_POOLCUE")] = true,
  [GetHashKey("WEAPON_CROWBAR")] = true,

  [GetHashKey("WEAPON_COMBATPISTOL")] = true,
  [GetHashKey("WEAPON_DOUBLEACTION")] = true,
  [GetHashKey("WEAPON_HEAVYPISTOL")] = true,
  [GetHashKey("WEAPON_PISTOL_MK2")] = true,
  [GetHashKey("WEAPON_PISTOL50")] = true,
  [GetHashKey("WEAPON_SNSPISTOL")] = true,
  [GetHashKey("WEAPON_STUNGUN")] = true,
  [GetHashKey("WEAPON_VINTAGEPISTOL")] = true,
  [GetHashKey("WEAPON_STUNGUN_MP")] = true,

  [GetHashKey("WEAPON_ASSAULTSMG")] = true,
  [GetHashKey("WEAPON_COMBATMG")] = true,
  [GetHashKey("WEAPON_COMBATPDW")] = true,
  [GetHashKey("WEAPON_GUSENBERG")] = true,
  [GetHashKey("WEAPON_MACHINEPISTOL")] = true,
  [GetHashKey("WEAPON_MG")] = true,
  [GetHashKey("WEAPON_GADGETPISTOL")] = true,
  [GetHashKey("WEAPON_NAVYREVOLVER")] = true,
  [GetHashKey("WEAPON_MILITARYRIFLE")] = true,

  [GetHashKey("WEAPON_ASSAULTRIFLE_MK2")] = true,
  [GetHashKey("WEAPON_BULLPUPRIFLE_MK2")] = true,
  [GetHashKey("WEAPON_CARBINERIFLE")] = true,
  [GetHashKey("WEAPON_COMPACTRIFLE")] = true,
  [GetHashKey("WEAPON_SPECIALCARBINE_MK2")] = true,

  [GetHashKey("WEAPON_DBSHOTGUN")] = true,
  [GetHashKey("WEAPON_PUMPSHOTGUN_MK2")] = true,
  [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = true,

  [GetHashKey("WEAPON_STICKYBOMB")] = true,
  [GetHashKey("WEAPON_SMOKEGRENADE")] = true,
  [GetHashKey("WEAPON_MOLOTOV")] = true,
  [GetHashKey("WEAPON_FIREEXTINGUISHER")] = true,
  [GetHashKey("WEAPON_PETROLCAN")] = true,
  [GetHashKey("WEAPON_DIGISCANNER")] = true,
  [GetHashKey("WEAPON_BRIEFCASE")] = true,
  [GetHashKey("WEAPON_BRIEFCASE_02")] = true,
  [GetHashKey("WEAPON_BALL")] = true,
}

local function checkIfHolster()
  local uWeap = GetSelectedPedWeapon(tempPed)

  if weapsToHolster[uWeap] then
    return true
  end

  return false
end

Citizen.CreateThread(function()
  Citizen.Wait(500)
  loadAnimDict("reaction@intimidation@1h")
  loadAnimDict("weapons@pistol_1h@gang")

  while true do
    while (GVEHICLE == 0) and not tvRP.isInComa() do
      local foundWeap = checkIfHolster()

      if foundWeap then
        if canHolster then
          canHolster = false
          
          TaskPlayAnim(tempPed, "reaction@intimidation@1h", "intro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
          Citizen.CreateThread(function()
            local expTask = GetGameTimer() + 2500
            
            while expTask > GetGameTimer() do
              DisableControlAction(1, 37, true)
              DisableControlAction(0,24)
              DisableControlAction(0,69)
              DisableControlAction(0,70)
              DisableControlAction(0,92)
              DisableControlAction(0,114)
              DisableControlAction(0,257)
              DisableControlAction(0,331)
              Citizen.Wait(1)
            end
          end)
          Citizen.Wait(2500)

          ClearPedTasks(tempPed)
          Citizen.Wait(100) 
        end
      else
        if not canHolster then
          TaskPlayAnim(tempPed, "reaction@intimidation@1h", "outro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
          Citizen.Wait(1500)

          ClearPedTasks(tempPed)
          canHolster = true
        end
      end

      Citizen.Wait(500)
    end

    Citizen.Wait(1000)    
  end
end)