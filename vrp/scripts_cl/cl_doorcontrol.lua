local DoorsData = {}

RegisterNetEvent("vrp-doorlock:populateDoors", function(doors)
    DoorsData = doors
end)

RegisterNetEvent("vrp-doorlock:setOneStatus", function(door, status)
    DoorsData[door].locked = status
end)


Citizen.CreateThread(function()
	local txd = CreateRuntimeTxd("doorlock")
	CreateRuntimeTextureFromImage(txd, "lock", "gui/assets/locked.png")
	CreateRuntimeTextureFromImage(txd, "unlock", "gui/assets/unlocked.png")
end)


local function findOneDoor()
    for k, v in pairs(DoorsData) do
        if #(pedPos - v.doorCoords) <= v.distance then
            return k
        end
    end

    return 0
end

RegisterCommand("deschideusa", function()
    local id = findOneDoor()
    
    if id ~= 0 then
        TriggerServerEvent("vrp-doorlock:tryOpen", id)
    end
end)

RegisterKeyMapping("deschideusa", "Deschide cea mai apropiata usa", "keyboard", "E")

local function DrawImage3D(name, x, y, z, width, height, rot) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, true)
	
    if onScreen then
		local width = (1/dist)*width
		local height = (1/dist)*height
		local fov = (1/GetGameplayCamFov())*100
		local width = width*fov
		local height = height*fov
	
		DrawSprite("doorlock", name, _x, _y, width, height, rot, 255, 255, 255, 255)
	end
end

Citizen.CreateThread(function()
    while true do
        Wait(1)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(DoorsData) do
            if #(playerCoords - v.doorCoords) <= 10 then
                local door = GetClosestObjectOfType(v.doorCoords[1], v.doorCoords[2], v.doorCoords[3], 1.0, v.objModel ,false, false, false)
                if door ~= 0 then
                    SetEntityCanBeDamaged(door, false)
                    if not v.locked then
                      NetworkRequestControlOfEntity(door)
                      FreezeEntityPosition(door, false)
                      DrawImage3D("unlock", v.doorCoords[1], v.doorCoords[2], v.doorCoords[3], 0.04, 0.09, 0.0)
                    else
                        local locked, heading = GetStateOfClosestDoorOfType(v.objModel, v.doorCoords[1], v.doorCoords[2],v.doorCoords[3], locked, heading)
                        if heading > -0.02 and heading < 0.02 then
                            NetworkRequestControlOfEntity(door)
                            FreezeEntityPosition(door, true)
                            DrawImage3D("lock", v.doorCoords[1], v.doorCoords[2], v.doorCoords[3], 0.04, 0.09, 0.0)
                        end
                    end
                end
            end
        end
    end
end)