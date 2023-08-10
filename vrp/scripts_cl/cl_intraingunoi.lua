local canHide = true
local inTrash = false

local theDumpsters = {
    "prop_dumpster_01a", 
    "prop_dumpster_02a", 
    "prop_dumpster_02b", 
    "prop_dumpster_4a", 
    "prop_dumpster_4b"
}

CreateThread(function()
    while true do
        for i=1, #theDumpsters do
            local theObj = GetClosestObjectOfType(pedPos.x, pedPos.y, pedPos.z, 1.0, theDumpsters[i], false, false, false)
            
            if theObj ~= 0 then
                local objPos = GetEntityCoords(theObj)

                while #(objPos - pedPos) <= 1.8 and not LocalPlayer.state.faceGunoier do
                    if not inTrash then
                        DrawText3D(objPos.x, objPos.y, objPos.z + 1.0, "~b~E ~w~- Ascunde-te in gunoi", 0.650)

                        if IsControlJustReleased(0, 51) then
                            if not IsEntityAttached(tempPed) then
                                AttachEntityToEntity(tempPed, theObj, -1, 0.0, -0.3, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)  
                                RequestAnimDict("timetable@floyd@cryingonbed@base")
                                
                                while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                                    Wait(1)
                                end

                                TaskPlayAnim(tempPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                                Wait(50)
                                SetEntityVisible(tempPed, false, false)
                                
                                inTrash = true

                                while inTrash do

                                    local theObj = GetEntityAttachedTo(tempPed)
                                    local objPos = GetEntityCoords(theObj)

                                    if DoesEntityExist(theObj) or not tvRP.isInComa() then
                                        SetEntityCollision(tempPed, false, false)
                                        DrawText3D(objPos.x, objPos.y, objPos.z + 1.0, "~b~E ~w~- Iesi din gunoi", 0.650)

                                        if not IsEntityPlayingAnim(tempPed, 'timetable@floyd@cryingonbed@base', 3) then
                                            RequestAnimDict("timetable@floyd@cryingonbed@base")
                                            
                                            while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                                                Wait(1)
                                            end

                                            TaskPlayAnim(tempPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end

                                        if IsControlJustReleased(0, 51) then
                                            SetEntityCollision(tempPed, true, true)
                                            inTrash = false

                                            DetachEntity(tempPed, true, true)
                                            SetEntityVisible(tempPed, true, false)

                                            ClearPedTasks(tempPed)
                                            SetEntityCoords(tempPed, GetOffsetFromEntityInWorldCoords(tempPed, 0.0, -0.7, -0.75))
                                        end
                                    else
                                        SetEntityCollision(tempPed, true, true)
                                        DetachEntity(tempPed, true, true)
                                        SetEntityVisible(tempPed, true, false)
                                        ClearPedTasks(tempPed)
                                        SetEntityCoords(tempPed, GetOffsetFromEntityInWorldCoords(tempPed, 0.0, -0.7, -0.75))
                                    end

                                    Wait(1)
                                end

                            else
                                tvRP.notify("Cineva se ascunde deja in acest tomberon!", "error", false, "fas fa-trash")
                            end
                        end
                    end

                    Wait(1)
                end
            end
        end

        Wait(1000)
    end
end)

RegisterCommand("fixgunoi", function()
    if not inTrash then
        return tvRP.notify("Nu esti ascuns in gunoi!", "error", false, "fas fa-trash")
    end

    inTrash = false
    DetachEntity(tempPed, true, true)
    SetEntityVisible(tempPed, true, false)
    ClearPedTasks(tempPed)
    SetEntityCoords(tempPed, GetOffsetFromEntityInWorldCoords(tempPed, 0.0, -0.5, -0.75))
end)