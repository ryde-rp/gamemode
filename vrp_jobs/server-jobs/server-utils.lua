local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

local FairPlayJOBS = {}
Tunnel.bindInterface("vrp_jobs", FairPlayJOBS)
Proxy.addInterface("vrp_jobs", FairPlayJOBS)


function FairPlayJOBS.hasItemAmount(item, amm, take)
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        local itmAmount = vRP.getInventoryItemAmount({user_id, item})
        if take then
            return vRP.tryGetInventoryItem({user_id, item, amm, false})
        else
            return (itmAmount >= amm)
        end
    end
    return true
end

function LogToDiscord(name, message)
    local DiscordWebHook = "https://discord.com/api/webhooks/1055955285665136670/JBrcrm8UAB_8uvvNebEtiAgyeC7zXue1zBfCfw-yvDv9EPHSTY75m8o3PNuaR5mGPpSA"             
    local embed = {
        {
            ["color"] = "56921", 
            ["type"] = "rich",
            ["title"] = name,                                                             
            ["description"] = message, 
            ["footer"] = {
                ["text"] = "Aceste loguri nu sunt 100% precise!"
            }
        } 
    }
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({username = "FairPlay Logs", embeds = embed, avatar_url = "", tts = false}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("FairPlay:QuitJob", function()
  local player = source
  local user_id = vRP.getUserId({player})
  vRP.SaveUserJobSkill({user_id})
  TriggerClientEvent("FairPlay:JobChange", player, "Somer", 0)
end)

function table.randomData(x, regenSeed)
    if regenSeed then
      math.randomseed(os.time())
    end
    
    return x[math.random(1, #x)]
  end
  
  function table:count(x)
    return table.countEntires(x)
  end
  
  function table:random(x, y)
    return table.randomData(x, y)
  end