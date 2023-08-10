local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP", "vrp_jafpacific")

local RVUtils = {}
Tunnel.bindInterface("vrp_jafpacific", RVUtils)
Proxy.addInterface("vrp_jafpacific", RVUtils)

local CristianCallback13 = 0

local ActiveRobbery = false;
local RobberyTime = 0; 
local CurrentFaction = false
local RobbingBank = {}

local Doorlocked = {
    {coords = vector3(257.10, 220.30, 106.28), he = 339.733, objModel = GetHashKey("hei_v_ilev_bk_gate_pris"), h1 = "hei_v_ilev_bk_gate_pris", h2 = "hei_v_ilev_bk_gate_molten", locked = true},
    {coords = vector3(236.91, 227.50, 106.29), he = 340.000, objModel = GetHashKey("v_ilev_bk_door"), locked = true},
    {coords = vector3(262.35, 223.00, 107.05), he = 249.731, objModel = GetHashKey("hei_v_ilev_bk_gate2_pris"), locked = true},
    {coords = vector3(252.72, 220.95, 101.68), he = 160.278, objModel = GetHashKey("hei_v_ilev_bk_safegate_pris"), h1 = "hei_v_ilev_bk_safegate_pris", h2 = "hei_v_ilev_bk_safegate_molten", locked = true},
    {coords = vector3(261.01, 215.01, 101.68), he = 250.082, objModel = GetHashKey("hei_v_ilev_bk_safegate_pris"), h1 = "hei_v_ilev_bk_safegate_pris", h2 = "hei_v_ilev_bk_safegate_molten", locked = true},
    {coords = vector3(253.92, 224.56, 101.88), he = 160.000, objModel = GetHashKey("v_ilev_bk_vaultdoor"), locked = true}
}

RegisterServerEvent("FP:BankRobbery:SV:SpawnProps", function()
    local player = source
    local user_id = vRP.getUserId({player})
    local userFaction = vRP.getUserFaction({user_id})

    local hasUserFaction = vRP.hasUserFaction({user_id})
    if not hasUserFaction then
        return DropPlayer(player, "Injection Detected")
    end

    vRP.doFactionFunction({userFaction, function(src)
        TriggerClientEvent("FP:BankRobbery:CL:SpawnProps", src)
    end})
end)

local function CloseVault()
    vRP.doFactionFunction({CurrentFaction, function(src)
        vRPclient.notify(src, {"Usa seifului se inchide! Iesi repede pana nu ramai inauntru!", "info"})
    end})
    SetTimeout(2000, function()
        vRP.doFactionFunction({CurrentFaction, function(src)
            TriggerClientEvent("FP:BankRobbery:CL:GAS", src, true)
        end})
        TriggerClientEvent("FP:BankRobbery:ChangeVaultState", -1, false)
        SetTimeout(20000, function()
            vRP.doFactionFunction({CurrentFaction, function(src)
                TriggerClientEvent("FP:BankRobbery:CL:GAS", src, false)
                SetTimeout(10000, function()
                    TriggerClientEvent("FP:BankRobbery:ResetSystem", -1)
                    for k, v in pairs(Doorlocked) do
                        v.locked = true
                    end
                    TriggerClientEvent("FP:BankRobbery:UpdateDoors", -1, Doorlocked)
                    ActiveRobbery = false;
                    CurrentFaction = false;
                end)
            end})
        end)
    end)
end

RegisterServerEvent("FP:BankRobbery:SV:StartLooting", function()
    local player = source
    local user_id = vRP.getUserId({player})
    local userFaction = vRP.getUserFaction({user_id})
    
    local hasUserFaction = vRP.hasUserFaction({user_id})
    if not hasUserFaction then
        return DropPlayer(player, "Injection Detected")
    end

    RobberyTime = 4;
    CurrentFaction = userFaction;
    ActiveRobbery = true;

    vRP.doFactionFunction({"Politia Romana", function(src)
        TriggerClientEvent("vrp-robbing:showAlert", src, "A fost activata alarma bancii Pacific. Toate unitatile sunt rugate sa se deplaseze de urganta la locatia incidentului.")
    end})

    TriggerClientEvent("FP:BankRobbery:ChangeVaultState", -1, true)
    vRP.doFactionFunction({userFaction, function(src)
        RobbingBank[src] = true;
        TriggerClientEvent("FP:BankRobbery:StartLooting", src, true)
        TriggerClientEvent("FP:BankRobbery:ShowUI", src)
        TriggerClientEvent("FP:BankRobbery:UpdateTime", src, RobberyTime)
    end})

    while RobberyTime > 0 do
        Wait(60 * 1000)
        RobberyTime = RobberyTime - 1
    end

    SetTimeout(1500, function()
        CloseVault()
        TriggerClientEvent("FP:BankRobbery:StartLooting", -1, false)
        TriggerClientEvent("FP:BankRobbery:CloseUI", -1)
    end)
end)

RegisterServerEvent("FP:BankRobbery:ChangeDoorState", function(door, state)
    Doorlocked[door].locked = state
    TriggerClientEvent("FP:BankRobbery:UpdateDoors", -1, Doorlocked)
end)

RegisterServerEvent("FP:BankRobbery:SV:Loot", function(id)
    vRP.doFactionFunction({CurrentFaction, function(src)
        TriggerClientEvent("FP:BankRobbery:CL:Loot", src, id)
    end})
end)

RegisterServerEvent("FP:BankRobbery:TableReward", function(reward)
    local player = source
    local user_id = vRP.getUserId({player})
    local userFaction = vRP.getUserFaction({user_id})

    if not RobbingBank[player] then
        return DropPlayer(player, "Injection Detected [1]")
    end

    local hasUserFaction = vRP.hasUserFaction({user_id})
    if not hasUserFaction then
        return DropPlayer(player, "Injection Detected [2]")
    end

    if not CurrentFaction then return end;
    if not ActiveRobbery then return vRP.kickPlayer({player, "[RVAnticheat] Incearca alta data amice!"}) end;
    if userFaction ~= CurrentFaction then return vRP.kickPlayer({user_id, "[RVAnticheat] Nice try!"}) end;

    if reward == "money" then
        vRP.giveInventoryItem({user_id, "bani_murdari", 500000})
    elseif reward == "gold" then
        vRP.giveInventoryItem({user_id, "aur_stantat", 100})
    elseif reward == "argint" then
        vRP.giveInventoryItem({user_id, "argint_stantat", 100})
    end
end)

RegisterServerEvent("FP:BankRobbery:SellLingouri", function()
    local player = source
    local user_id = vRP.getUserId({player})
    local pretAur = 600000;
    local pretArgint = 500000;
    local money =  0;

    local aur = vRP.getInventoryItemAmount({user_id, "aur_stantat"})
    local argint = vRP.getInventoryItemAmount({user_id, "argint_stantat"})

    money = money + (tonumber(aur) * pretAur);
    money =  money + (tonumber(argint) * pretArgint)

    vRP.request({player, "Vinde Lingourile<br> Vrei sa iti vinzi lingourile pentru "..tonumber(money).."$ ?", false, function(_, ok)
        if ok then
            if aur >= 1 then
                vRP.tryGetInventoryItem({user_id, "aur_stantat", aur, true})
            end
            if argint >= 1 then
                vRP.tryGetInventoryItem({user_id, "argint_stantat", argint, true})
            end
            vRP.giveInventoryItem({user_id, "bani_murdari", money, true})
        end
    end})
end)

Citizen.CreateThread(function()
    Wait(3000)
    TriggerClientEvent("FP:BankRobbery:UpdateDoors", -1, Doorlocked)
end)

RegisterServerEvent("vRP:alertThePolice", function()
    vRP.doFactionFunction({"Politia Romana", function(src)
        TriggerClientEvent("vrp-robbing:showAlert", src, "A fost activata alarma bancii Pacific. Toate unitatile sunt rugate sa se deplaseze de urganta la locatia incidentului.")
    end})
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if first_spawn then
        SetTimeout(3000, function()
            TriggerClientEvent("FP:BankRobbery:UpdateDoors", source, Doorlocked)
        end)
    end
end)


-- [FUNCTIONS]

function RVUtils.CanRobBank(prop)
    local player = source
    local user_id = vRP.getUserId({player})
    local cops = vRP.getOnlineUsersByFaction({"Politia Romana"})

    if #cops < 0 then return false, "Nu sunt suficienti politisti online! Minimul este de 12, iar momentan sunt doar "..#cops.. " !" end

    if CristianCallback13 >= os.time() then return false, "Este cooldown activ, o sa poti da jaf in "..math.floor((CristianCallback13 - os.time()) / 60).." minute" end
    
    if not vRP.hasUserFaction({user_id}) then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end
    local userFaction = vRP.getUserFaction({user_id})
    if vRP.getFactionType({userFaction}) ~= "Mafie" then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end

    if vRP.tryGetInventoryItem({user_id, "proximity_mine", 1, false}) then
        CristianCallback13 = os.time() + (60 * 30)
        RobbingBank[player] = true
        return true, "Ai inceput sa jefuiesti banca!"
    else
        return false, "Nu ai o bomba termica"
    end
end

function RVUtils.CanHackTerminal()
    local player = source
    local user_id = vRP.getUserId({player})

    if not vRP.hasUserFaction({user_id}) then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end
    local userFaction = vRP.getUserFaction({user_id})
    if vRP.getFactionType({userFaction}) ~= "Mafie" then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end

    if vRP.getInventoryItemAmount({user_id, "hacking_device"}) >= 1 then
        return true, "Ai inceput sa jefuiesti banca!"
    else
        return false, "Nu ai un dispozitiv de hacking"
    end
end

function RVUtils.CanPlantTermicBomb()
    local player = source
    local user_id = vRP.getUserId({player})

    if not vRP.hasUserFaction({user_id}) then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end
    local userFaction = vRP.getUserFaction({user_id})
    if vRP.getFactionType({userFaction}) ~= "Mafie" then return false, "Trebuie sa faci parte dintr-o mafie pentru a putea da jaf" end

    if vRP.tryGetInventoryItem({user_id, "proximity_mine", 1, false}) then
        return true, "Ai inceput sa topesti incuietoarea!"
    else
        return false, "Nu ai o bomba termica"
    end
end