
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRPCase")

radio.RegisterServerCallback('qb-radio:server:GetItem', function(source, cb, item)
    local _src = source
    local user_id = vRP.getUserId({_src})
    local player = vRP.getUserSource({user_id}) 
    if user_id then
        vRPclient.isInComa({player,{}, function(in_coma)
            local RadioItem = vRP.getInventoryItemAmount({user_id,"radio"}) > 0
            if RadioItem  and not in_coma then
                cb(true)
            else
                cb(false)
            end
        end})
    else
        cb(false)
    end
end)

vRP.defInventoryItem({"radio","Radio 📻","Statie Radio",function(args)
	local choices = {}
  
	choices["Scoate statia"] = {function(player,choice)
        local user_id = vRP.getUserId({player})
        local _source = vRP.getUserSource({user_id})
	  if user_id then
			TriggerClientEvent('qb-radio:use', _source)
		  vRP.closeMenu({player})
	  end
	end}
  
	return choices
end,0.1})
