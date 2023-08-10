
local isPlayerCrouched, lockCrouch, lastUserCam, crouchCam = false, false, 0, false

local function resetCrouchWalk()
  local Player = tempPed

  SetPedMaxMoveBlendRatio(Player, 1.0)
  ResetPedMovementClipset(Player, 0.55)
  ResetPedStrafeClipset(Player)
  SetPedCanPlayAmbientAnims(Player, true)
  SetPedCanPlayAmbientBaseAnims(Player, true)
  ResetPedWeaponMovementClipset(Player)
  isPlayerCrouched = false
end

local function isCrouchFree()
  local PlayerPed = tempPed

  if IsPedOnFoot(PlayerPed) and not IsPedJumping(PlayerPed) and not IsPedFalling(PlayerPed) and not IsPedDeadOrDying(PlayerPed) then
    return true
  else
    return false
  end
end

local function checkIfAimed()
  if IsPlayerFreeAiming(GetPlayerIndex()) then
    return true
  elseif IsAimCamActive() then
    return true
  elseif IsAimCamThirdPersonActive() then
    return true
  end

  return false
end

Citizen.CreateThread(function()
  while not HasAnimSetLoaded('move_ped_crouched') do
    Wait(5)
    RequestAnimSet('move_ped_crouched')
  end

  while true do 
    DisableControlAction(0, 36, true)
  
    if lockCrouch then
      local crouchDone = isCrouchFree()
      if checkIfAimed() then
        resetCrouchWalk()
      elseif crouchDone and (not isPlayerCrouched) then
        local Player = tempPed

        SetPedUsingActionMode(Player, false, -1, "DEFAULT_ACTION")
        SetPedMovementClipset(Player, 'move_ped_crouched', 0.55)
        SetPedStrafeClipset(Player, 'move_ped_crouched_strafing')
        SetWeaponAnimationOverride(Player, "Ballistic")

        isPlayerCrouched = true
      elseif not crouchDone and isPlayerCrouched then
        lockCrouch = false
        resetCrouchWalk()
      end

      local currentCamera = GetFollowPedCamViewMode()
      if crouchDone and isPlayerCrouched and currentCamera == 4 then
        SetFollowPedCamViewMode(lastUserCam)
      elseif crouchDone and isPlayerCrouched and currentCamera ~= 4 then
        lastUserCam = currentCamera
      end
    elseif isPlayerCrouched then
      resetCrouchWalk()
    end
  
    Wait(5)
  end
end)

RegisterCommand('useCrouch', function()
  if crouchTime then
    return
  end

  lockCrouch = not lockCrouch
  crouchTime = true

  Citizen.CreateThread(function()
    Wait(500)
    crouchTime = false
  end)
end, false)

RegisterKeyMapping('useCrouch', 'Intra in modul crouch', 'keyboard', 'LCONTROL')