local cam = false
local JobBlips = {}

-- x : left/ right
-- y : front / back
-- z : up / down
function SpawnVehicle(model, coords)
    local mhash = GetHashKey(model)

	local i = 0
	while not HasModelLoaded(mhash) and i < 1000 do
		RequestModel(mhash)
		Citizen.Wait(10)
		i = i+1
	end

    if HasModelLoaded(mhash) then
        local x,y,z = table.unpack(coords)
		local nveh = CreateVehicle(mhash, x,y,z+0.5, GetEntityHeading(GetPlayerPed(-1)), true, false)
        NetworkFadeInEntity(nveh, 0)
        SetPedIntoVehicle(GetPlayerPed(-1), nveh, -1)

        SetVehicleOnGroundProperly(nveh)

        local vehCoords = GetEntityCoords(nveh)
        local px, py, pz = table.unpack(vehCoords)
        local x, y, z = px - GetEntityForwardX(nveh) * 6, py - GetEntityForwardY(nveh) * 6, pz + 0.90
        local rx = GetEntityRotation(nveh, 2)

        local camRotation = rx + vector3(0.0, 0.0, 0.0)
        local camCoords = vector3(x, y, z)

        ClearFocus()
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())

        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, true, false)

        SetTimeout(1000, function()
            RenderScriptCams(false, true, 1000, true, false)
            SetCamActive(cam, false)
            DestroyCam(cam, true)
            cam = false
        end)

        return nveh
    end
    return false
end


local boxAnim = false
function setBoxAnimation(state, canRun, lockIdle)
	boxAnim = state
	if boxAnim then
		Citizen.CreateThread(function()
			RequestAnimDict("anim@heists@box_carry@")
			while not HasAnimDictLoaded("anim@heists@box_carry@") do
				Citizen.Wait(1)
			end
			local ped = PlayerPedId()

			Citizen.CreateThread(function()
				while boxAnim do
					if not canRun then
						DisableControlAction(0, 21, true)
					end
					DisableControlAction(0, 22, true)
					DisableControlAction(0, 55, true) 
					DisableControlAction(0, 23, true)
					DisableControlAction(0, 24, true)
					DisableControlAction(0, 25, true)
					DisableControlAction(0, 44, true)
					DisableControlAction(0, 140, true)
					Citizen.Wait(1)
				end
			end)

			while boxAnim do
				local neededAnim = "idle"

				if not lockIdle then
					if IsPedWalking(ped) then
						neededAnim = "walk"
					elseif IsPedRunning(ped) or IsPedSprinting(ped) then
						neededAnim = "run"
					end
				end

				if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", neededAnim, 3) then
					TaskPlayAnim(ped, "anim@heists@box_carry@", neededAnim, 8.0, 8.0, -1, 49, 0, 0, 0, 0)
				end

				Citizen.Wait(500)
				ped = PlayerPedId()
			end

			ClearPedTasksImmediately(ped)
		end)
	end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(500)
    end
end

function DrawText3D(x,y,z, text, scl, font) 
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)
    local scale = (1/dist*scl)*(1/GetGameplayCamFov()*100);
   
    if onScreen then
      SetTextScale(0.0*scale, 1.1*scale)
      SetTextFont((font or 0))
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 255)
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(_x,_y)
    end
  end

Citizen.CreateThread(function()
    Wait(500)
    for k, v in pairs(Config.JobBlips) do
        Wait(100)
        
        local blip = AddBlipForCoord(v[1], v[2], v[3])
        SetBlipSprite(blip, v[4])
        SetBlipColour(blip, v[5])
        SetBlipScale(blip,v[6])
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(k)
        EndTextCommandSetBlipName(blip)

        JobBlips[#JobBlips+1] = blip
    end
end)

local userJob = false
RegisterNetEvent("FairPlay:JobChange")
AddEventHandler("FairPlay:JobChange", function(job, skill)
  userJob = job
end)

RegisterNUICallback("job:quit", function(data, cb)
  TriggerServerEvent("FairPlay:QuitJob")
  cb("ok")
end)