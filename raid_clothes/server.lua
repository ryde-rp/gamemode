local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vRP_skins")

RegisterServerEvent("vRPclothes:insertClothes")
AddEventHandler("vRPclothes:insertClothes", function(data)
    if not data then
        return
    end

    local player = source
    local user_id = vRP.getUserId({player})
    
    if not user_id then
        return
    end

    local values = {
        user_id = user_id,
        model = data.model,
        drawables = data.drawables,
        props = data.props,
        drawtextures = data.drawtextures,
        proptextures = data.proptextures
    }

    vRP.setUData({user_id, "userClothes", json.encode(values)})
end)

RegisterServerEvent("vRPclothes:insertFaceData")
AddEventHandler("vRPclothes:insertFaceData",function(data)
    if not data then return end
    local player = source
    local user_id = vRP.getUserId({player})

    if not user_id then return end
    if data.headBlend == "null" or data.headBlend == nil then
        data.headBlend = {}
    else
        data.headBlend = data.headBlend
    end

    local values = {
        user_id = user_id,
        hairColor = data.hairColor,
        headBlend = data.headBlend,
        headOverlay = data.headOverlay,
        headStructure = data.headStructure
    }

    vRP.setUData({user_id, "userFace", json.encode(values)})
end)

RegisterServerEvent("vRPclothes:getFaceData")
AddEventHandler("vRPclothes:getFaceData",function(pSrc)
    local player = (not pSrc and source or pSrc)
    local user_id = vRP.getUserId({player})
    
    if not user_id then
        return
    end
    
    vRP.getUData({user_id, "userFace", function(preFace)
        local result = json.decode(preFace) or {}
        vRP.getUData({user_id, "userClothes", function(preClothes)
            local cc = json.decode(preClothes) or {}
            for k, v in pairs(cc) do result[k] = v end

            if #result > 0 then
                local temp_data = {
                    hairColor = result.hairColor,
                    headBlend = result.headBlend,
                    headOverlay = result.headOverlay,
                    headStructure = result.headStructure,
                }

                local model = tonumber(result.model)
                if model == 1885233650 or model == -1667301416 then
                    TriggerClientEvent("vRPclothes:setPedData", player, temp_data)
                end
            else
                TriggerClientEvent("vRPclothes:setPedData", player, false)
            end
        end})
    end})
end)

RegisterServerEvent("vRPclothes:loadPedData")
AddEventHandler("vRPclothes:loadPedData", function(pSrc)
    local player = pSrc
    if not pSrc and source then
        player = source
    end

    if player then
        local user_id = vRP.getUserId({player})
        vRP.getUData({user_id, "userFace", function(preFace)
            local result = json.decode(preFace) or {}
            if preFace:len() < 2 then
                result = {}
            end
            
            vRP.getUData({user_id, "userClothes", function(preClothes)
                local cc = json.decode(preClothes) or {}
                for k, v in pairs(cc) do
                    result[k] = v
                end

                local cnt = 0
    			for k, v in pairs(result) do
                    cnt = cnt + 1
                end

                if cnt > 0 then
                    local temp_data = {
                        model = result.model,
                        drawables = result.drawables or {},
                        props = result.props or {},
                        drawtextures = result.drawtextures or {},
                        proptextures = result.proptextures or {},
                        hairColor = result.hairColor or {1, 1},
                        headBlend = result.headBlend or {},
                        headOverlay = result.headOverlay or {},
                        headStructure = result.headStructure or {},
                    }

                    TriggerClientEvent("vRPclothes:loadSkin", player, temp_data)
                else
                	vRP.getUserIdentity({user_id, function(identity)
                		local temp_data = pickStartSkin(identity.sex)
                    	TriggerClientEvent("vRPclothes:loadSkin", player, temp_data)
                	end})
                end
            end})
        end})
    end
end)

RegisterServerEvent("vRPclothes:getClothes")
AddEventHandler("vRPclothes:getClothes",function(pSrc)
    local player = (not pSrc and source or pSrc)
    local user_id = vRP.getUserId({player})

    if not user_id then return end
    vRP.getUData({user_id, "userClothes", function(preClothes)
        local result = json.decode(preClothes) or {}
        if #result > 0 then
            local temp_data = {
                model = result.model,
                drawables = result.drawables,
                props = result.props,
                drawtextures = result.drawtextures,
                proptextures = result.proptextures
            }
            TriggerClientEvent("vRPclothes:setClothes", player, temp_data)
        end
    end})
end)

RegisterServerEvent("vRPclothes:checkMoney")
AddEventHandler("vRPclothes:checkMoney", function(menu, askingPrice)
    local player = source
    local user_id = vRP.getUserId({player})

    if not askingPrice then
        askingPrice = 0
    end

    if vRP.tryFullPayment({user_id, askingPrice, true}) then
        TriggerClientEvent("vRPclothes:openClothing",player,menu)
    end
end)

function pickStartSkin(sex)
	local startSkin = module(GetCurrentResourceName(), "startSkins")
    data = json.decode(startSkin.masculin)

	if sex == "F" then -- feminin
	    data = json.decode(startSkin.feminin)
	end

    return data
end

local fixSkinCooldown = {}

local function updatePlayerClothes(user_id)
    local player = vRP.getUserSource({user_id})
    if player then
        if (fixSkinCooldown[user_id] or 0) <= os.time() then
            fixSkinCooldown[user_id] = os.time() + 30
            TriggerEvent("vRPclothes:loadPedData", player)
            return true
        else
            vRPclient.notify(player, {"Ai cooldown "..(fixSkinCooldown[user_id] - os.time()).." (de) secunde", "error", false, "fas fa-shirt"})
        end
    end
    
    return false
end

RegisterCommand("fixskin", function(source)
    local user_id = vRP.getUserId({source})

    vRPclient.isInComa(source, {}, function(inComa)
        if inComa then
            return vRPclient.notify(source, {"Nu poti folosii aceasta functie mort!", "error", false, "fas fa-shirt"})
        end

        vRPclient.isFalling(source, {}, function(uFalling)
            if uFalling then
                return vRPclient.notify(source, {"Nu poti folosii aceasta functie acum!", "error", false, "fas fa-shirt"})
            end

            vRPclient.getPosition(source, {}, function(x, y, z)
                vRPclient.getArmour(source, {}, function(lastArmour)
                    if updatePlayerClothes(user_id) then
                        Citizen.Wait(500)

                        vRPclient.teleport(source, {x, y, z})
                        if lastArmour > 0 then
                            vRPclient.setArmour(source, {lastArmour,false})
                        end
                    end
                end)
            end)
        end)
    end)
end)

RegisterServerEvent("fp-clothing:requestSkin")
AddEventHandler("fp-clothing:requestSkin", function(user_id)
    updatePlayerClothes(user_id)
end)

RegisterServerEvent("player$requestSkin")
AddEventHandler("player$requestSkin", function()
    local player = source
    local user_id = vRP.getUserId({player})
    updatePlayerClothes(user_id)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    Citizen.Wait(500)
    updatePlayerClothes(user_id)
end)

if false then
    AddEventHandler("onResourceStart", function(res)
        if res == GetCurrentResourceName() then
            local users = vRP.getUsers({})
            for user_id, source in pairs(users) do
                updatePlayerClothes(user_id)
            end
        end
    end)
end