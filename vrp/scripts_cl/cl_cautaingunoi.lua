local searchingOne = false
local trashList = {
    GetHashKey('prop_bin_01a'),
    GetHashKey('prop_bin_03a'),
	GetHashKey('prop_bin_07b'),
	GetHashKey('prop_bin_07c'),
	GetHashKey('prop_bin_07a'),
	GetHashKey('prop_bin_08a'),
	GetHashKey('prop_cs_bin_02'),
    GetHashKey('prop_bin_05a'),
}

function tvRP.searchedInTrash()
    return searchingOne
end

CreateThread(function()
    while true do
        for _, theTrash in pairs(trashList) do
            local trashObj = GetClosestObjectOfType(pedPos, 1.0, theTrash, true, true, true)

            if trashObj ~= 0 then
                SetEntityAsMissionEntity(trashObj, true, true)

                if DoesEntityExist(trashObj) then
                    local objPos = GetEntityCoords(trashObj)
                    PlaceObjectOnGroundProperly(trashObj)

                    while #(objPos - pedPos) <= 3.5 and (GVEHICLE == 0) do
                        objPos = GetEntityCoords(trashObj) -- follow trash

                        DrawText3D(objPos.x, objPos.y, objPos.z+1.4, "~y~G ~w~ - Cauta in gunoi", 0.5)
                        DrawMarker(20, objPos.x, objPos.y, objPos.z+1.150, 0, 0, 0, 0, 0, 0, 0.25, 0.25, -0.25, 209, 174, 70, 125, true, true)

                        if #(objPos - pedPos) <= 1.5 then
                            if IsControlJustReleased(0, 47) and not tvRP.isInComa() then
                                if not searchingOne then
                                    searchingOne = true
                                    CreateThread(function()
                                        Wait(5000)
                                        ExecuteCommand("me ~y~miroase foarte urat")
                                    end)

                                    TriggerEvent("vRP:progressBar", {
                                        duration = 15000,
                                        text = "🗑️ Cauti in gunoi..",
                                        anim = {
                                            scenario = "PROP_HUMAN_BUM_BIN",
                                        }
                                    }, function()
                                        math.randomseed(GetGameTimer())

                                        local isWinner = math.random(1, 15) > 10
                                        if not isWinner then
                                            tvRP.varyHealth(-5)
                                            tvRP.notify("Te-a muscat un sobolan...", "warning", false, "fas fa-bugs")
                                        else
                                            vRPserver.winTrashSearch({})
                                        end

                                        Wait(1000)
                                        searchingOne = false
                                    end)
                                end
                            end
                        end

                        Wait(1)
                    end
                end
            end
        end

        Wait(1000)
    end
end)