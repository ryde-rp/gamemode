-- api

function tvRP.varyHealth(variation)
  local ped = tempPed
  local n = math.floor(GetEntityHealth(ped)+variation)
  SetEntityHealth(ped,n)
end

function tvRP.getHealth()
  return GetEntityHealth(tempPed)
end

function tvRP.setHealth(health)
  local n = math.floor(health)
  SetEntityHealth(tempPed, n)
  CreateThread(function()
    Wait(1000)
    SetEntityHealth(tempPed, n)
  end)
end

function tvRP.setArmour(armour, vest)
  if vest then
    RequestAnimDict("clothingtie")

    while not HasAnimDictLoaded("clothingtie") do
      Wait(1)
    end
    
    TaskPlayAnim(tempPed, "clothingtie", "try_tie_negative_a", 3.0, 3.0, 2000, 01, 0, false, false, false)
  end

  local x = math.floor(armour)
  SetPedArmour(tempPed, x)
end

function tvRP.getArmour()
  return GetPedArmour(tempPed)
end

-- impact thirst and hunger when the player is running (every 5 seconds)
CreateThread(function()
  while true do
    Wait(5000)

    if IsPlayerPlaying(tempPlayer) then
      local ped = tempPed

      -- variations for one minute
      local vthirst = 0
      local vhunger = 0

      -- on foot, increase thirst/hunger in function of velocity
      if IsPedOnFoot(ped) and not tvRP.isNoclip() then
          local factor = math.min(tvRP.getSpeed(), 10)

          vthirst = vthirst + 0.5 * factor
          vhunger = vhunger + 0.5 * factor
      end

      -- in melee combat, increase
      if IsPedInMeleeCombat(ped) then
          vthirst = vthirst + 10
          vhunger = vhunger + 5
      end

      -- injured, hurt, increase
      if IsPedHurt(ped) or IsPedInjured(ped) then
          vthirst = vthirst + 2
          vhunger = vhunger + 1
      end

      -- do variation
      if vthirst ~= 0 and not tvRP.isAdminJailed() then
          vRPserver.varyThirst({vthirst / 12.0})
      end

      if vhunger ~= 0 and not tvRP.isAdminJailed() then
          vRPserver.varyHunger({vhunger / 12.0})
      end
    end
  end
end)

-- COMA SYSTEM
local in_coma = false
local coma_left = cfg.coma_duration*60
local setRespawnTime = false
local timeToRespawn = false

local function respawnThePlayer()
  local ped = tempPed
  if in_coma then -- get out of coma state
    tick = 0
    CreateThread(function()
      in_coma = false
      setRespawnTime = false

      while GetEntityHealth(ped)-1 <= cfg.coma_threshold do
        Wait(1)

        break
      end

      SetEntityInvincible(ped,false)
      tvRP.setRagdoll(false)
      tvRP.stopScreenEffect(cfg.coma_effect)
      TriggerEvent("vRP:interfaceFocus", false)
      SendNUIMessage({
        act = "interface",
        target = "deathscreen",
        event = "hide"
      })

      if coma_left <= 0 then -- get out of coma by death
        if GetEntityHealth(ped)-1 <= cfg.coma_threshold then
          SetEntityHealth(ped, 0)
          CreateThread(function()
            Wait(500)
            tvRP.notify("Tot sangele ti s-a scurs iar medicii nu te-au mai putut salva...", "warning")
            TriggerEvent("vRP:interfaceFocus", false)
            SendNUIMessage({
              act = "interface",
              target = "deathscreen",
              event = "hide"
            })
          end)
        end
      end

      SetTimeout(5000, function()  -- able to be in coma again after coma death after 5 seconds
        coma_left = cfg.coma_duration*60
      end)
    end)
  end
end

local function selfRespawn()
  if timeToRespawn then
    if timeToRespawn <= GetGameTimer() then
      tvRP.killComa()
      TriggerEvent("vRP:interfaceFocus", false)
    else
      local finalTime = math.floor((timeToRespawn - GetGameTimer()) / 1000)
      tvRP.notify(("Trebuie sa mai astepti %d minute, %d secunde pana vei putea evita ajutorul unui medic!"):format(math.floor(finalTime / 60), finalTime % 60), "error")
    end
  end
end

RegisterNUICallback("respawn", function(data, cb)
  selfRespawn()
  cb({"ok"})
end)

CreateThread(function() -- coma thread
  while true do
    tick = 500
    local ped = tempPed

    if in_coma then
      tick = 0

      if not setRespawnTime then
        setRespawnTime = true
        timeToRespawn = GetGameTimer() + (60 * 5 * 1000)
        TriggerEvent("vRP:onComaEntered")
      end

      SendNUIMessage({
        act = "interface",
        target = "deathscreen",
        event = "show",
      })

      if timeToRespawn > GetGameTimer() then
        SendNUIMessage({
          act = "interface",
          target = "deathscreen",
          event = "update",
          canRespawn = false,
          time = math.floor((timeToRespawn - GetGameTimer()) / 1000 / 60)..":"..math.floor((timeToRespawn - GetGameTimer()) / 1000 % 60),
          respawnTime = math.floor(coma_left / 60)..":"..coma_left % 60,
        })
      else
        TriggerEvent("vRP:interfaceFocus", true)
        SendNUIMessage({
          act = "interface",
          target = "deathscreen",
          event = "update",
          canRespawn = true,
          time = math.floor((timeToRespawn - GetGameTimer()) / 1000),
          respawnTime = math.floor(coma_left / 60)..":"..coma_left % 60,
        })
      end

		  DisableControlAction(0,24, true) -- disable attack
	    DisableControlAction(0,25, true) -- disable aim
    elseif timeToRespawn then
      timeToRespawn = false
      -- TriggerEvent("ui$hideUserElement", false)
      -- DisplayRadar(true)
    end
    
    local health = GetEntityHealth(ped) or 0
    if health <= cfg.coma_threshold and coma_left > 0 then
      tick = 0
      if not in_coma then -- go to coma state
        if IsEntityDead(ped) then -- if dead, resurrect
          local x,y,z = tvRP.getPosition()
          NetworkResurrectLocalPlayer(x, y, z, true, true, false)
          Wait(0)
        end

        -- coma state
        in_coma = true
        vRPserver.updateHealth({cfg.coma_threshold}) -- force health update
        SetEntityHealth(ped, cfg.coma_threshold)
        SetEntityInvincible(ped,true)
        tvRP.playScreenEffect(cfg.coma_effect,-1)
        tvRP.ejectVehicle()
        tvRP.setRagdoll(true)
      else -- in coma
        -- maintain life
        if health < cfg.coma_threshold then 
          SetEntityHealth(ped, cfg.coma_threshold) 
        end
      end
    else
      respawnThePlayer()
    end
    Wait(tick)
  end
end)

function tvRP.isInComa()
  return in_coma
end

-- kill the player if in coma
function tvRP.killComa()
  if in_coma then
    coma_left = 0
  end
end

CreateThread(function() -- coma decrease thread  
  while true do
    Wait(1000)
    SetPlayerHealthRechargeMultiplier(tempPlayer, 0.0)
    
    if in_coma then
      coma_left = coma_left-1
    end
  end
end)
