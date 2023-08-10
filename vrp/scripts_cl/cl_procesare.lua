local cfgProcesare = {}
local usedTbl = false
local inProcessing = false

RegisterNetEvent("vRP:setProcesareCfg")
AddEventHandler("vRP:setProcesareCfg", function(x)
	cfgProcesare = x
end)

local requestTbl = {}
Citizen.CreateThread(function()
	while true do

		for key, data in pairs(cfgProcesare) do
			while #(data.pos - pedPos) <= 10 do

				for item, tbl in pairs(data.tables) do
					local dist = #(tbl.pos - pedPos)

					if dist <= 5 then

						if dist <= 1 then
							if not requestTbl[item] then
								requestTbl[item] = true
								TriggerEvent("vRP:requestKey", {key = "E", text = "Proceseaza "..item})
							end

							if IsControlJustReleased(0, 51) then
								TriggerEvent("vRP:interfaceFocus", true)
								SendNUIMessage({
									act = "interface",
									target = "procesare",
									recipe = tbl.recipe,
									result = tbl.result,
									title = key,
									icon = data.icon,
									time = tbl.time or "Instant",
								})

								usedTbl = tbl
								usedTbl.tableId = item
							end
						elseif requestTbl[item] then
							TriggerEvent("vRP:requestKey", false)
							requestTbl[item] = nil
						end

						if tbl.addMarker then
							DrawMarker(20, tbl.pos, 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 255, 255, 255, 155, false, true, false, true)
						end
					end
				end

				Wait(1)
			end
		end

		Wait(1000)
	end
end)

RegisterNUICallback("processItem", function(data, cb)
	if inProcessing then
		return tvRP.notify("Procesezi deja un item, ai rabdare sa termini!", "error")
	end

	if type(usedTbl) ~= "table" then
		return cb("ok")
	end

	if usedTbl.evt then
		TriggerServerEvent(usedTbl.evt, table.unpack(usedTbl.eventArgs or {}))
	end

	inProcessing = true
	TriggerEvent("vRP:requestKey", false)
	async(function()
		if usedTbl.wait then
			Wait(usedTbl.wait)
		end
		
		requestTbl[usedTbl.tableId] = nil
		usedTbl = false
		inProcessing = false
	end)

	cb("ok")
end)

RegisterNUICallback("procesare:exit", function(data, cb)
	TriggerEvent("vRP:interfaceFocus", false)
	cb("ok")
end)