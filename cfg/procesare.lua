local cfg = {}
local function checkIfItems(user_id, itemsTbl)
	local result = true
	local inventory = vRP.getInventoryItems(user_id)

	for item, data in pairs(itemsTbl) do
		if not inventory[item] then
			result = false
			break
		elseif data.amount > inventory[item].amount then 
			result = false
			break
		end
	end

	return result
end

cfg["Traficant de Etnobotanice"] = {
	pos = vec3(1439.5046386719,-1487.5140380859,63.702831268311),
	icon = "fas fa-pills",

	tables = {
		["Special Gold"] = {
			pos = vec3(1436.1057128906,-1488.9468994141,66.619338989258),
			time = "2 secunde",
			wait = 2000,
			recipe = {
				["fp_acetona"] = {
					amount = 20,
				},
				
				["fp_ingrasamant_chimic"] = {
					amount = 20,
				},
			},
			result = {
				item = "fp_special_gold",
				amount = 1,
			},
			fnc = function(user_id, source, recipe, result)
				if checkIfItems(user_id, recipe) then
					if vRP.canCarryItem(user_id, result.item, result.amount, true) then
						
						TriggerClientEvent("vRP:progressBar", source, {
							duration = 10000,
							text = "Procesezi "..result.label,
							anim = {
								dict = "mp_arresting",
								name = "a_uncuff",
							}
						})

						async(function()
							Citizen.Wait(10000)
							vRP.giveInventoryItem(user_id, result.item, result.amount, true)
							
							for item, v in pairs(recipe) do
								vRP.tryGetInventoryItem(user_id, item, v.amount, true)
							end
						end)

					end

					return
				end

				vRPclient.notify(source, {"Nu ai materialele necesare pentru a procesa.", "error", false, icon})
			end
		},

		["Pulse"] = {
			pos = vec3(1438.0666503906,-1490.1634521484,66.61937713623),
			time = "2 secunde",
			wait = 2000,
			recipe = {
				["fp_otrava_sobolani"] = {
					amount = 20,
				},

				["fp_ingrasamant_chimic"] = {
					amount = 20,
				},
			},
			result = {
				item = "fp_pulse",
				amount = 1,
			},
			fnc = function(user_id, source, recipe, result)
				if checkIfItems(user_id, recipe) then
					if vRP.canCarryItem(user_id, result.item, result.amount, true) then
						
						TriggerClientEvent("vRP:progressBar", source, {
							duration = 10000,
							text = "Procesezi "..result.label,
							anim = {
								dict = "mp_arresting",
								name = "a_uncuff",
							}
						})

						async(function()
							Citizen.Wait(10000)
							vRP.giveInventoryItem(user_id, result.item, result.amount, true)
							
							for item, v in pairs(recipe) do
								vRP.tryGetInventoryItem(user_id, item, v.amount, true)
							end
						end)

					end

					return
				end

				vRPclient.notify(source, {"Nu ai materialele necesare pentru a procesa.", "error", false, icon})
			end
		},
	},
}

cfg["Traficant de Tigari"] = {
	pos = vec3(1604.6962890625,3569.7373046875,38.775196075439),
	icon = "fas fa-smoking",

	tables = {
		["Țigări"] = {
			pos = vec3(1602.1561279297,3568.0830078125,38.775196075439),
			time = "2 secunde",
			wait = 2000,
			recipe = {
				["fp_tutun_procesat"] = {
					amount = 20,
				},
				
				["fp_foite"] = {
					amount = 20,
				},

				["fp_filtre"] = {
					amount = 20,
				}
			},
			result = {
				item = "fp_tigara",
				amount = 20,
			},
			fnc = function(user_id, source, recipe, result)
				if checkIfItems(user_id, recipe) then
					if vRP.canCarryItem(user_id, result.item, result.amount, true) then
						
						TriggerClientEvent("vRP:progressBar", source, {
							duration = 10000,
							text = "Procesezi "..result.label,
							anim = {
								dict = "mp_arresting",
								name = "a_uncuff",
							}
						})

						async(function()
							Citizen.Wait(10000)
							vRP.giveInventoryItem(user_id, result.item, result.amount, true)
							
							for item, v in pairs(recipe) do
								vRP.tryGetInventoryItem(user_id, item, v.amount, true)
							end
						end)

					end

					return
				end

				vRPclient.notify(source, {"Nu ai materialele necesare pentru a procesa.", "error", false, icon})
			end
		},

		["Pachet Camel Turcesc"] = {
			pos = vec3(1603.6694335938,3570.9733886719,38.775196075439),
			time = "2 secunde",
			wait = 2000,
			recipe = {
				["fp_tigara"] = {
					amount = 20,
				},
			},
			result = {
				item = "fp_camel_turcesc",
				amount = 1,
			},
			fnc = function(user_id, source, recipe, result)
				if checkIfItems(user_id, recipe) then
					if vRP.canCarryItem(user_id, result.item, result.amount, true) then
						
						TriggerClientEvent("vRP:progressBar", source, {
							duration = 10000,
							text = "Procesezi "..result.label,
							anim = {
								dict = "mp_arresting",
								name = "a_uncuff",
							}
						})

						async(function()
							Citizen.Wait(10000)
							vRP.giveInventoryItem(user_id, result.item, result.amount, true)
							
							for item, v in pairs(recipe) do
								vRP.tryGetInventoryItem(user_id, item, v.amount, true)
							end
						end)

					end

					return
				end

				vRPclient.notify(source, {"Nu ai materialele necesare pentru a procesa.", "error", false, icon})
			end
		},

		["Pachet Kent Turcesc"] = {
			pos = vec3(1608.6728515625,3570.9072265625,38.775253295898),
			time = "2 secunde",
			wait = 2000,
			recipe = {
				["fp_tigara"] = {
					amount = 20,
				},
			},
			result = {
				item = "fp_kent_turcesc",
				amount = 1,
			},
			fnc = function(user_id, source, recipe, result)
				if checkIfItems(user_id, recipe) then
					if vRP.canCarryItem(user_id, result.item, result.amount, true) then
						
						TriggerClientEvent("vRP:progressBar", source, {
							duration = 10000,
							text = "Procesezi "..result.label,
							anim = {
								dict = "mp_arresting",
								name = "a_uncuff",
							}
						})

						async(function()
							Citizen.Wait(10000)
							vRP.giveInventoryItem(user_id, result.item, result.amount, true)
							
							for item, v in pairs(recipe) do
								vRP.tryGetInventoryItem(user_id, item, v.amount, true)
							end
						end)

					end

					return
				end

				vRPclient.notify(source, {"Nu ai materialele necesare pentru a procesa.", "error", false, icon})
			end
		},
	},
}

return cfg