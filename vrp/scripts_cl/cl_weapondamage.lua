-- RegisterNetEvent("f8:showDamage",function(attacker,receiver,damage)
--     print(attacker,"-",receiver,"^1"..damage)
-- end)

-- AddEventHandler('gameEventTriggered', function (name, args)
--     if name == "CEventNetworkEntityDamage" then
--         print(json.encode(args))
--     end
-- end)
local lastHealthPoint = 200

AddEventHandler('gameEventTriggered', function (name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        if victim == PlayerPedId() then
            local attacker_o = NetworkGetEntityOwner(attacker)
            local damage_p = (lastHealthPoint - GetEntityHealth(PlayerPedId()))
            local s_id = GetPlayerServerId(attacker_o)
            local s_user_id = Player(s_id).state.user_id
            if s_user_id == nil then return end
            Citizen.Trace("^1DMG ^7-> ^1"..damage_p.."^7 | Jucator: "..(GetPlayerName(attacker_o) or "NU E JUCATOR").."["..s_user_id.."]\n")
            lastHealthPoint = GetEntityHealth(PlayerPedId())
        end
    end
end)