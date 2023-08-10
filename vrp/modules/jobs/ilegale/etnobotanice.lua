local inDelivery = {}
local deliveryPoints = {
	vec3(-1068.0782470703,-1163.3913574219,2.7451763153076),
	vec3(-1048.109375,-1123.2292480469,2.1585969924927),
	vec3(-1024.5578613281,-1139.5115966797,2.744325876236),
	vec3(-1063.5823974609,-1160.3526611328,2.7469606399536),
	vec3(-991.67694091797,-1103.7155761719,2.1503081321716),
	vec3(-986.16839599609,-1121.8833007813,4.5454845428467),
	vec3(-952.47906494141,-1077.5708007813,2.6723504066467),
	vec3(-959.84240722656,-1109.78125,2.1503133773804),
	vec3(-921.42211914063,-1095.2028808594,2.1503105163574),
	vec3(-1063.5467529297,-1054.8621826172,2.1503558158875),
	vec3(-1068.3758544922,-1049.4953613281,6.4116554260254),
	vec3(-1108.767578125,-1040.9169921875,2.1503553390503),
	vec3(-1114.3983154297,-1069.01953125,2.1503562927246),
	vec3(-1127.7772216797,-1080.9554443359,4.2226891517639),
	vec3(-1054.2366943359,-1000.387512207,6.4104909896851),
	vec3(-1056.2152099609,-1000.9592895508,2.1501913070679),
	vec3(-1041.6354980469,-1025.7574462891,2.7449781894684),
	vec3(-1022.8419189453,-998.34265136719,2.150191783905),
	vec3(-990.265625,-975.63348388672,4.2226958274841),
}

local possibleItems = {
	{"fp_special_gold", "Special Gold", 270000},
	{"fp_pulse", "Pulse", 270000},
}

function tvRP.setEtnobotanicsTask()
	local user_id = vRP.getUserId(source)
	if not user_id then return end
	
	math.randomseed(os.time() * user_id)

	if vRP.getUserJob(user_id) ~= "Traficant de Etnobotanice" then
		return vRP.banPlayer(0, user_id, -1, "Injection detected [vrp][etnobotanicsTask]")
	end

	local items = {}

	for i=1, 2 do
		local item = possibleItems[i]
		
		if item then
			table.insert(items, {
				name = item[2],
				item = item[1],
				onePrice = item[3] or 0,
				amount = math.random(4,8),
			})
		end
	end

	inDelivery[user_id] = items

	return {
		pos = table.rnd(deliveryPoints),
		items = items,
	}
end

function tvRP.finishEtnobotanicsTask()
	local player = source
	local user_id = vRP.getUserId(player)
	local function ban()
		return vRP.banPlayer(0, user_id, -1, "Injection detected [vrp][etnobotanicsTask]")
	end

	if vRP.getUserJob(user_id) ~= "Traficant de Etnobotanice" then
		return ban()
	end

	local taskItems = inDelivery[user_id]
	if not taskItems then
		return ban()
	end

	local reward = 0
	for key, data in pairs(taskItems) do
		if vRP.tryGetInventoryItem(user_id, data.item, data.amount, true) then
			reward = reward + (data.amount * data.onePrice)
		end
	end

	if reward > 0 then
		vRPclient.notify(player, {"💶 Ai castigat $"..reward, "info"})
		vRP.giveMoney(user_id, reward)
		--vRPclient.giveInventoryItem(user_id, "bani_murdari", reward, true)
	end

	inDelivery[user_id] = nil
end

AddEventHandler("vRP:playerLeave", function(user_id)
	inDelivery[user_id] = nil
end)

local itemsTable = {
	["fp_ingrasamant_chimic"] = 3000,
	["fp_otrava_sobolani"] = 1000,
	["fp_acetona"] = 1000,
}

RegisterServerEvent("fp-traficantEtnobotanice:cumparaItem")
AddEventHandler("fp-traficantEtnobotanice:cumparaItem", function(item)
	local player = source
	local user_id = vRP.getUserId(source)
	local price = itemsTable[item]

	if price then
		vRP.prompt(player, "BUY ITEMS", {
			{field = "amt", title = "Cantitate", number = true, text = 1}
		}, function(player, res)
			local amt = res["amt"] or 0

			if amt > 0 then
				price = amt * price
				
				if vRP.canCarryItem(user_id, item, amt, true) then
					if vRP.tryPayment(user_id, price, true) then
						vRP.giveInventoryItem(user_id, item, amt, true)
					end
				end
			end
		end)
	end
end)