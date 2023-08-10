vRP = Proxy.getInterface("vrp")

local open = false

function SetOpened(state) 
    SetNuiFocus(state, state)
    open = state
end

RegisterNetEvent('slots:client:updateSlots', function(bet)
	SetOpened(true)
	SendNUIMessage({ action = 'open', amount = bet })
end)

RegisterNUICallback('setCoins', function(data, cb)
	cb('ok')
    SetOpened(false)
    TriggerServerEvent('slots:server:checkForMoney', tonumber(data.amount) or 0)
end)

RegisterNetEvent('slots:client:enter', function ()
    SetOpened(true);
	TriggerServerEvent('slots:server:enterSl')
	SendNUIMessage({ action = 'openAmount' })
end)

RegisterNUICallback('close', function(data, cb)
	cb('ok')
    SetOpened(false)
	TriggerServerEvent('slots:server:payRewards', data.amount)
end)

RegisterCommand('test1', function (souce)
	SetOpened(true)
	SendNUIMessage({ action = 'open', amount = 1000 })
end)

CreateThread(function()
	while true do
		Wait(1)

		local playerCoords = GetEntityCoords(PlayerPedId(), false)

		for i, v in ipairs(Config.Slots) do 
			local slotsCoords = vector3(v.x, v.y, v.z)

			if #(playerCoords - slotsCoords) <= 2.5 then
			    subtitleText('~m~E~w~ - Deschide 20 Burning Hot')

				if IsControlJustReleased(0, 38) then
					TriggerEvent('slots:client:enter')
				end
			end
		end
	end
end)

CreateThread(function ()
	while true do
		Wait(1)

		if open then
			local ped = PlayerPedId()
			
			DisableControlAction(0, 1, true) 
			DisableControlAction(0, 2, true)
			DisableControlAction(0, 24, true)
			DisablePlayerFiring(ped, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 106, true)
		end
	end
end)

function subtitleText(f)
    SetTextFont(2)
    SetTextProportional(0)
    SetTextScale(0.25, 0.3)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(40, 5, 5, 5, 255)
    SetTextEdge(30, 5, 5, 5, 255)
    SetTextDropShadow()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(f)
    DrawText(0.5, 0.95)
end
