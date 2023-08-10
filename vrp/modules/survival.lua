local cfg = module("cfg/survival")
-- api

function vRP.getHunger(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.hunger
  end

  return 0
end

function vRP.getThirst(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.thirst
  end

  return 0
end

function vRP.setHunger(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = value

    if data.hunger < 0 then
      data.hunger = 0
    end

    local source = vRP.getUserSource(user_id)
    TriggerClientEvent("fp-hud:setDependencies", source, (data.thirst or 0), (data.hunger or 0))
  end
end

function vRP.setThirst(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = value

    if data.thirst < 0 then
      data.thirst = 0
    end

    local source = vRP.getUserSource(user_id)
    TriggerClientEvent("fp-hud:setDependencies", source, (data.thirst or 0), (data.hunger or 0))
  end
end

function vRP.varyHunger(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = (data.hunger or 0) + variation

    local source = vRP.getUserSource(user_id)
    if data.hunger < 0 then
      data.hunger = 0
      vRPclient.notify(source, {"Nu mai poti manca!", "warning", false, "fas fa-utensils"})
    end

    TriggerClientEvent("fp-hud:setDependencies", source, (data.thirst or 0), (data.hunger or 0))

    -- apply overflow as damage
    local overflow = data.hunger-100
    if overflow > 0 then
      vRPclient.varyHealth(source,{-overflow*cfg.overflow_damage_factor})
    end
  end
end

function vRP.varyThirst(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = (data.thirst or 0) + variation

    local source = vRP.getUserSource(user_id)
    if data.thirst < 0 then
      data.thirst = 0
      vRPclient.notify(source, {"Nu mai poti bea!", "warning", false, "fas fa-whiskey-glass"})
    end

    TriggerClientEvent("fp-hud:setDependencies", source, (data.thirst or 0), (data.hunger or 0))

    -- apply overflow as damage
    local overflow = data.thirst-100
    if overflow > 0 then
      vRPclient.varyHealth(source,{-overflow*cfg.overflow_damage_factor})
    end
  end
end

-- tunnel api (expose some functions to clients)

function tvRP.varyHunger(variation)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.varyHunger(user_id,variation)
  end
end

function tvRP.varyThirst(variation)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.varyThirst(user_id,variation)
  end
end

-- hunger/thirst increase
function task_update()
  for k,v in pairs(vRP.users) do
    vRP.varyHunger(v,cfg.hunger_per_minute)
    vRP.varyThirst(v,cfg.thirst_per_minute)
  end

  SetTimeout(60000,task_update)
end
task_update()

-- init values
AddEventHandler("vRP:playerJoin",function(user_id,source,name)
  local data = vRP.getUserDataTable(user_id)
  if not data.hunger then
    data.hunger = 0
    data.thirst = 0
  elseif not data.thirst then
    data.hunger = 0
    data.thirst = 0
  end
end)

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  local data = vRP.getUserDataTable(user_id)

  if not first_spawn then
    data.hunger = 0
    data.thirst = 0
  end

  if data then
    vRP.setHunger(user_id, data.hunger)
    vRP.setThirst(user_id, data.thirst)
  end
end)