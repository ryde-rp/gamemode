
local function build_client_cams(player)
    local function createCams(player)
        local user_id = vRP.getUserId(player)
        
        if not vRP.isUserPolitist(user_id) then
            return vRPclient.notify(player, {"Doar politisti pot accesa camerele!", "error"})
        end

        TriggerClientEvent("vRP:connectCams", player, 1)
    end

    local function destroyCams() end

    vRP.setArea(player, "vRP_policeCams:1", 442.65536499023,-998.85577392578,34.970149993896, 2.5, {key = "E", text = "Acceseaza camerele"}, createCams, destroyCams)
    vRP.setArea(player, "vRP_policeCams:2", 447.22241210938,-998.81317138672,34.970108032227, 1.650, {key = "E", text = "Acceseaza camerele"}, createCams, destroyCams)
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        build_client_cams(source)
    end
end)