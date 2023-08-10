
local findingDoor, allDoors = false, {
  {"seat_dside_f", -1},
  {"seat_pside_f", 0},
  {"seat_dside_r", 1},
  {"seat_pside_r", 2}
}

RegisterCommand("getnextdoortoenter", function()
  if findingDoor or GVEHICLE ~= 0 then
    return
  end

  local vehicle = tvRP.getVehicleInFront()
  if vehicle then
    findingDoor = true
    local nDistances = {}
    local pCds = GetEntityCoords(tempPed)
    
    for _, theDoor in pairs(allDoors) do
      local doorBone = GetEntityBoneIndexByName(vehicle, theDoor[1])
      local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
      local dist = #(doorPos - pCds)

      table.insert(nDistances, dist)
    end

    local doorIndx, minIndx = 1, nDistances[1]
    for newDoor, newIndx in ipairs(nDistances) do
      if nDistances[newDoor] < minIndx then
        doorIndx, minIndx = newDoor, newIndx
      end
    end
    
    TaskEnterVehicle(tempPed, vehicle, -1, allDoors[doorIndx][2], 1.0, 1, 0)
    findingDoor = false
  end
end)

RegisterKeyMapping("getnextdoortoenter", "Nu schimba!!", "keyboard", "F")