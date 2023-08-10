-- periodic player state update

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(15000)

    if IsPlayerPlaying(PlayerId()) then
      TriggerServerEvent("vRP:updatePlayerState")
    end
  end
end)

function tvRP.savePlayerCoords()
  vRPserver.updatePos({pedPos.x,pedPos.y,pedPos.z})
end

local isFrozen = false
function tvRP.loadFreeze(flag)
	isFrozen = flag
  Citizen.CreateThread(function()
    while isFrozen do
      SetEntityInvincible(tempPed,true)
      SetEntityVisible(tempPed,false)
      FreezeEntityPosition(tempPed,true)
      Citizen.Wait(1)
    end
    SetEntityInvincible(tempPed,false)
    SetEntityVisible(tempPed,true)
    FreezeEntityPosition(tempPed,false)
  end)
end

function tvRP.setFreeze(bool, ignoreVisibility)
  isFrozen = bool

  if not ignoreVisibility then
    SetEntityVisible(tempPed, not bool)
  end
  
  FreezeEntityPosition(tempPed, isFrozen)
  SetEntityInvincible(tempPed, isFrozen)

  CreateThread(function()
    while isFrozen do
      DisableControlAction(0, 311, true) -- K
      DisableControlAction(0, 24, true) -- Click
      DisableControlAction(0, 22, true) -- Space
      DisableControlAction(0, 288, true) -- F1 vMenu
      DisableControlAction(0, 289, true) -- F2 NoClip
      DisableControlAction(0, 37, true) -- TAB

      DisableControlAction(0,19,true)
      DisableControlAction(0,21,true)
      DisableControlAction(0,22,true)
      DisableControlAction(0,25,true)
      DisableControlAction(0,47,true)
      DisableControlAction(0,58,true)
      DisableControlAction(0,263,true)
      DisableControlAction(0,264,true)
      DisableControlAction(0,257,true)
      DisableControlAction(0,140,true)
      DisableControlAction(0,141,true)
      DisableControlAction(0,142,true)
      DisableControlAction(0,143,true)
      DisableControlAction(0,170,true)
      
      Citizen.Wait(1)
    end
  end)
end

local function parse_part(key)
  if type(key) == "string" and string.sub(key,1,1) == "p" then
    return true,tonumber(string.sub(key,2))
  else
    return false,tonumber(key)
  end
end

function tvRP.getDrawables(part)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropDrawableVariations(tempPed,index)
  else
    return GetNumberOfPedDrawableVariations(tempPed,index)
  end
end

function tvRP.getDrawableTextures(part,drawable)
  local isprop, index = parse_part(part)
  if isprop then
    return GetNumberOfPedPropTextureVariations(tempPed,index,drawable)
  else
    return GetNumberOfPedTextureVariations(tempPed,index,drawable)
  end
end

function tvRP.getCustomization()
  local ped = tempPed

  local custom = {}

  custom.modelhash = GetEntityModel(ped)

  -- ped parts
  for i=0,20 do -- index limit to 20
    custom[i] = {GetPedDrawableVariation(ped,i), GetPedTextureVariation(ped,i), GetPedPaletteVariation(ped,i)}
  end

  -- props
  for i=0,10 do -- index limit to 10
    custom["p"..i] = {GetPedPropIndex(ped,i), math.max(GetPedPropTextureIndex(ped,i),0)}
  end

  return custom
end

-- partial customization (only what is set is changed)
function tvRP.setCustomization(custom) -- indexed [drawable,texture,palette] components or props (p0...) plus .modelhash or .model
  
  local exit = TUNNEL_DELAYED() -- delay the return values

  CreateThread(function() -- new thread
    if custom then
      local ped = tempPed
      local mhash = nil

      -- model
      if custom.modelhash ~= nil then
        mhash = custom.modelhash
      elseif custom.model ~= nil then
        mhash = GetHashKey(custom.model)
      end

      if mhash ~= nil then
        local i = 0
        while not HasModelLoaded(mhash) and i < 10000 do
          RequestModel(mhash)
          Citizen.Wait(10)
        end

        if HasModelLoaded(mhash) then
          SetPlayerModel(PlayerId(), mhash)
          SetModelAsNoLongerNeeded(mhash)
        end
      end

      ped = tempPed

      -- parts
      for k,v in pairs(custom) do
        if k ~= "model" and k ~= "modelhash" then
          local isprop, index = parse_part(k)
          if isprop then
            if v[1] < 0 then
              ClearPedProp(ped,index)
            else
              SetPedPropIndex(ped,index,v[1],v[2],v[3] or 2)
            end
          else
            SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
          end
        end
      end
    end

    exit({})
  end)
end

function tvRP.getWeaponInHand()
  return GetSelectedPedWeapon(tempPed)
end

function tvRP.giveWeapons(weapons,clear_before)
  local player = GetPlayerPed(-1)

  -- give weapons to player

  if clear_before then
    RemoveAllPedWeapons(player,true)
    canBeEmpty = true
  end

  for k,weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0
    if ammo >= 0 then
	    GiveWeaponToPed(player, hash, ammo, false)
	end
  end
  
end

function tvRP.giveWeaponAmmo(weapon, amt)
  AddAmmoToPed(tempPed, weapon, amt)
end

function tvRP.clearWeapons(save_task)
  RemoveAllPedWeapons(tempPed, true)
end