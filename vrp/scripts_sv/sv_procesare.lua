local cfg = module("cfg/procesare")

Citizen.CreateThread(function()
	Citizen.Wait(500)

	for key, data in pairs(cfg) do
		for tblId, tbl in pairs(data.tables) do
			if type(tbl.fnc) == "function" then
				local evt = "vrp-procesare:"..(math.random(1111, 9999) * math.random(2, 9))..":"..tblId

				RegisterServerEvent(evt, function(...)
					local user_id = vRP.getUserId(source)
					if not user_id then return end

					-- trigger table function
					tbl.fnc(user_id, source, tbl.recipe, tbl.result, tbl.icon, ...)
				end)

				-- add item labels
				for item in pairs(tbl.recipe) do
					local itemName = vRP.getItemName(item) or "Undefined"
					
					-- insert label into table
					cfg[key].tables[tblId].recipe[item].label = itemName
				end

				-- add result label
				if tbl.result then
					local itemName = vRP.getItemName(tbl.result.item) or "Undefined"
						
					-- insert label into table
					cfg[key].tables[tblId].result.label = itemName
				end

				-- register callback event
				cfg[key].tables[tblId].evt = evt
			end
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
		Citizen.Wait(1500)
		TriggerClientEvent("vRP:setProcesareCfg", source, cfg)	
	end
end)