local inFishing = {}
local inWorm = {}

local fishPrices = {
    ["somnmic"] = 38500,
	["somnmediu"] = 77000,
	["somnmare"] = 154000,
	["platicamica"] = 31500,
	["platicamedie"] = 63000,
	["platicamare"] = 126000,
	["somonmic"] = 38500,
	["somonmediu"] = 77000,
	["somonmare"] = 154000,
	["stiucamica"] = 35000,
	["stiucamedie"] = 70000,
	["stiucamare"] = 140000,
	["carasmic"] = 35000,
	["carasmediu"] = 70000,
	["carasmare"] = 160000,
	["crapmic"] = 35000,
	["crapmediu"] = 70000,
	["crapmare"] = 140000,
	["salaumic"] = 35000,
	["salaumediu"] = 70000,
	["salaumare"] = 140000,
	["bibanmic"] = 38500,
	["bibanmediu"] = 77000,
	["bibanmare"] = 154000,
	["rosioaramica"] = 31500,
	["rosioaramedie"] = 63000,
	["rosioaramare"] = 126000,
	["guvid"] = 28000,
	["pestisorauriu"] = 1250000, 
}

function tvRP.useFishingWorm()
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id, "ramapescar", 1, true) then
		inFishing[user_id] = os.time() + 20
		return true
	end

	return false
end

function tvRP.collectOneWorm()
	local user_id = vRP.getUserId(source)
	local uTime = inWorm[user_id]

	local function ban()
		return vRP.banPlayer(0, user_id, -1, "Injection detected [vrp][fisherTask]")
	end

	local function finishTask()
		vRP.giveInventoryItem(user_id, "ramapescar", 1, true)
	end

	if not uTime then
		finishTask()
		inWorm[user_id] = os.time() + 10
	elseif uTime > os.time() then
		inWorm[user_id] = nil
		return ban()
	else
		finishTask()
		inWorm[user_id] = nil
	end
end

function tvRP.sellTheFish(fType)
	local user_id = vRP.getUserId(source)
	
	if fType == "fish" then
		local theReward = 0
		
		for nfish, fishPrice in pairs(fishPrices) do
			local amt = vRP.getInventoryItemAmount(user_id, nfish)

			if amt > 0 and vRP.tryGetInventoryItem(user_id, nfish, amt, true) then
				theReward = theReward + (amt * fishPrice)
			end
		end

		if theReward == 0 then
			return vRPclient.notify(source, {"Nu ai peste pentru a vinde!", "error", false, "fas fa-fish"})
		end
		
		vRP.giveMoney(user_id, theReward)
		vRPclient.notify(source, {"💵 Ai castigat $"..theReward, "info"})
	elseif fType == "worms" then
		local amt = vRP.getInventoryItemAmount(user_id, "ramapescar")

		if amt == 0 then
			return vRPclient.notify(source, {"Nu ai momeala pentru a vinde!", "error", false, "fas fa-fish"})
		end

		if vRP.tryGetInventoryItem(user_id, "ramapescar", amt, true) then
			local theReward = amt * 10
			
			vRP.giveMoney(user_id, theReward)
			vRPclient.notify(source, {"💵 Ai castigat $"..theReward, "info"})
		end
	end
end