local bizs = {}
local bps = {}

RegisterNetEvent("vRP:setWashersData")
AddEventHandler("vRP:setWashersData", function(x, rebuildBlips)
	bizs = x

	if rebuildBlips then
		for _, bid in pairs(bps) do
			RemoveBlip(bid)
		end
		
		bps = {}
	end

	if (#bps == 0) then
		for _, biz in pairs(bizs) do
			local id = AddBlipForCoord(biz.pos)
			SetBlipScale(id, 0.650)
			SetBlipSprite(id, biz.sprite or 500)
			SetBlipColour(id, 6)
			SetBlipAsShortRange(id, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Afacere")
			EndTextCommandSetBlipName(id)
			table.insert(bps, id)
		end
	end
end)

Citizen.CreateThread(function()
	local interact = false
	while true do
		local ticks = 1024

		for oneBiz, biz in pairs(bizs) do

			local dist = #(biz.pos - pedPos)
			if dist <= 10 then
				ticks = 1

				if dist <= 2.5 then
					if not interact and dist <= 1 then
						interact = true
						TriggerEvent("vRP:requestKey", {key = "E", text = "Administreaza afacere"})
					end

					if IsControlJustReleased(0, 51) then
						SendNUIMessage({
							act = "interface",
							target = "moneyWasher",
							bizData = biz,
							bizId = oneBiz,
						})

						TriggerEvent("vRP:interfaceFocus", true)
					end

				elseif interact then
					TriggerEvent("vRP:requestKey", false)
					interact = false
				end

			end
		end

		Citizen.Wait(ticks)

	end
end)

function tvRP.getNearestWasher()
	local minDst = 2.5
	local bizIndx = 0

	for id, data in pairs(bizs) do
		if #(data.pos - pedPos) < minDst then
			bizIndx = id
		end
	end

	return bizIndx
end

local inWashing = false
RegisterNetEvent("vRP:washMoney")
AddEventHandler("vRP:washMoney", function(cbData, sum)
	TriggerEvent("vRP:requestKey", false)
	tvRP.playAnim(false, {{"mp_arresting", "a_uncuff"}}, true)
	inWashing = true

	TriggerEvent("vRP:progressBar", {
        text = "Speli banii murdari...",
        disableControls = {Player = true},
        duration = 6500,
	}, function()

	    TriggerServerEvent("vRP:checkWashSkill", cbData, sum)
	    tvRP.stopAnim()
	    inWashing = false

	end)
end)

RegisterNUICallback("payWasher", function(data, cb)
	TriggerServerEvent("vRP:payWasherBiz", data.biz)
	cb("ok")
end)

RegisterNUICallback("washMoney", function(data, cb)
	if not inWashing then
		TriggerServerEvent("vRP:washMoney", data.biz)
	end

	cb("ok")
end)