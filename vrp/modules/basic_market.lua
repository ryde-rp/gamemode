local mapMarkets = {}
local market_items = {}

local market_types = module("cfg/markets")
local blipFormat = "Magazin %s"

AddEventHandler("onResourceStart", function(res)
	if res == GetCurrentResourceName() then
		
		Citizen.CreateThread(function()
			exports.oxmysql:query("SELECT * FROM markets", function(result)
				mapMarkets = result or {}
			end)
		
			Citizen.Wait(1000)
			for gtype, items in pairs(market_types) do
				market_items[gtype] = {}

				for k, v in pairs(items) do
					if type(v) == "number" then
						local item_name = vRP.getItemName(k)

						if item_name then
							market_items[gtype][k] = {
								label = item_name,
								price = v,
							}
						end
					end
				end
			end

		end)

	end
end)

function vRP.createMarket(thePlayer, x, y, z, gtype)
  Citizen.Wait(500)
  local theMarket = (#mapMarkets or 0) + 1
  if theMarket ~= 0 then
    local group = market_types[gtype]
	local items = market_items[gtype]
    if group then
        local gcfg = group._config
		exports.oxmysql:execute("INSERT INTO markets (x,y,z,type) VALUES(@x,@y,@z,@type)",{
			['@x'] = x,
			['@y'] = y,
			['@z'] = z,
			['@type'] = gtype
		})

        table.insert(mapMarkets, {x = x, y = y, z = z, type = gtype})

		local gcfg = group._config

		local function market_enter(source)
			local user_id = vRP.getUserId(source)
			local identity = vRP.getIdentity(user_id)
			TriggerClientEvent("vrp-markets:openShop", source, gtype, items, vRP.getMoney(user_id), identity.firstname.." "..identity.name)
		end

		if gcfg.blip_id and gcfg.blip_color then
			vRPclient.createBlip(-1, {"vRP:blip_market:"..theMarket, x, y, z, gcfg.blip_id, gcfg.blip_color, blipFormat:format(gtype), gcfg.blip_size or 0.7})
		end

	    local users = vRP.getUsers()
	    for _, theSrc in pairs(users) do
			vRP.setArea(theSrc, "vRP:market"..theMarket, x, y, z, 2.0, {
				key = "E",
				text = gcfg.text or "Magazin "..gtype
			}, market_enter, function() end)
	    end
        
        vRPclient.notify(thePlayer, {("Ai creat un magazin de tip: %s"):format(gtype), "success"})
    else
      vRPclient.notify(thePlayer, {("Nu exista grupa de magazine numita: %s"):format(gtype), "error"})
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
	  local user_id = vRP.getUserId(source)

	  if user_id then
	  	Citizen.Wait(1500)
	    for k,v in pairs(mapMarkets) do
	      	local gtype,x,y,z = v.type, v.x, v.y, v.z
	      	local group = market_types[gtype]
	      	local items = market_items[gtype]

			if group then
			    local gcfg = group._config

			    local function market_enter()
					local identity = vRP.getIdentity(user_id)
					TriggerClientEvent("vrp-markets:openShop", source, gtype, items, vRP.getMoney(user_id), identity.firstname.." "..identity.name)
			    end

			    if gcfg.blip_id and gcfg.blip_color then
			    	vRPclient.createBlip(source, {"vRP:blip_market:"..k, x, y, z, gcfg.blip_id, gcfg.blip_color, blipFormat:format(gtype), gcfg.blip_size or 0.7})
			    end

			    vRP.setArea(source, "vRP:market"..k, x, y, z, 2.0, {
					key = "E",
					text = gcfg.text or "Magazin "..gtype
				}, market_enter, function() end)
		    end
	    end
	  end
  end
end)

function vRP.getItemPrice(item, theType)
	for gtype, shop_items in pairs(market_types) do
		if gtype == theType then
			for k,v in pairs(shop_items) do
				if k == item then
					return true, math.max(v,0)
				end
			end
		end
	end
	return false, 0
end

function tvRP.tryBuyItem(item, gtype)
	local player = source
	local user_id = vRP.getUserId(player)
	local ok, price = vRP.getItemPrice(item, gtype)

	if ok then
		vRP.prompt(source, "BUY ITEMS", {
			{field = "amount", title = "CANTITATE DORITA", number = 1, text = 1},
		}, function(_, res)
			local amount = res["amount"]

			if amount and (amount > 0) then
			
				if vRP.canCarryItem(user_id, item, amount) then
					if vRP.tryFullPayment(user_id, price*amount) then
						vRP.giveInventoryItem(user_id, item, amount, true)
					else
						vRPclient.notify(player, {"Nu ai "..vRP.formatMoney(price*amount).." $", "error"})
					end
				else
					vRPclient.notify(player, {"Nu mai ai loc in inventar.", "error"})
				end

			end

			TriggerClientEvent("fp-markets:refreshCursor", source)
		end)
	end
end

RegisterNetEvent('fp-gunshop:checkHours', function()
	local src = source
	local user_id = vRP.getUserId(src)
	if vRP.getUserHoursPlayed(user_id) > 10 then
		TriggerClientEvent('fp-gunshop:viewItems', src)
	else
		vRPclient.notify(src, {'Nu ai destule ore!', 'error'})
	end
end)

RegisterServerEvent("vrp-markets:payBasket")
AddEventHandler("vrp-markets:payBasket", function(basket, method, gtype)
	local player = source
	local user_id = vRP.getUserId(player)

	if gtype and market_items[gtype] then

		for k, data in pairs(basket or {}) do
			local pricePerOne = market_items[gtype][data.item].price or 1
			local totalPrice = (data.amount or 1) * pricePerOne
			local boughtItem = false

			if totalPrice > 1 then
				if vRP.canCarryItem(user_id, data.item, (data.amount or 1), true) then
					if method == "cash" then
						boughtItem = vRP.tryPayment(user_id, totalPrice, true)
					elseif method == "card" then
						boughtItem = vRP.tryBankPayment(user_id, totalPrice, true)
					end

					if boughtItem then
						vRP.giveInventoryItem(user_id, data.item, (data.amount or 1), true)	
					end

				end
			end
		end

	end
end)

