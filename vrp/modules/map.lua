local client_areas = {}
local function deleteClientAreas(user_id, source)
  client_areas[source] = nil
end

AddEventHandler("vRP:playerLeave", deleteClientAreas)

function vRP.setArea(source, name, x, y, z, radius, text, execAtJoin, execAtLeave)
  if not name then return end
  local areas = client_areas[source] or {}
  client_areas[source] = areas

  areas[name] = {enter = execAtJoin, leave = execAtLeave}
  vRPclient.setArea(source, {name, x, y, z, radius, text})
end

function vRP.removeArea(source, name)
  if not name then return end
  vRPclient.removeArea(source,{name})

  local areas = client_areas[source]
  if areas then
    areas[name] = nil
  end
end

function tvRP.enterArea(name)
  local areas = client_areas[source]
  if areas then
    local area = areas[name] 
    if area and area.enter then
      area.enter(source,name)
    end
  end
end

function tvRP.leaveArea(name)
  local areas = client_areas[source]
  if areas then
    local area = areas[name] 
    if area and area.leave then
      area.leave(source,name)
    end
  end
end

function vRP.createNPC(source, name, x, y, z, heading, model, freeze, scenario)
	vRPclient.createNPC(source, {name, x, y, z, heading, model, freeze, scenario})
end

function vRP.removeNPC(source, name)
  vRPclient.removeNPC(source, {name})
end