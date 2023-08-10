-- define some basic inventory items

local items = {}
local inEating = {}

local function play_eat(player)
  local seq = {
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_enter",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_fp",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_exit_burger",1}
  }

  vRPclient.playAnim(player,{true,seq,false})
end

local function play_drink(player)
  local seq = {
    {"mp_player_intdrink","intro_bottle",1},
    {"mp_player_intdrink","loop_bottle",1},
    {"mp_player_intdrink","outro_bottle",1}
  }

  vRPclient.playAnim(player,{true,seq,false})
end

local function gen(ftype, vary_hunger, vary_thirst, onUse)
  local fgen = function(args)
    local idname = args[1]
    local choices = {}
    local name = vRP.getItemName(idname)

    choices["Foloseste"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id ~= nil then

        if (inEating[user_id] or 0) < os.time() then

          inEating[user_id] = os.time() + 10
 
          if vRP.tryGetInventoryItem(user_id,idname,1,false) then
            if vary_hunger ~= 0 then
              vRP.varyHunger(user_id,-vary_hunger)
            end
            
            if vary_thirst ~= 0 then
              vRP.varyThirst(user_id,-vary_thirst)
            end

            if ftype == "drink" then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 4000,
                text = "🥤 Bei "..name,
              })

              play_drink(player)
            elseif ftype == "eat" then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 4000,
                text = "🍴 Mananci "..name,
              })

              play_eat(player)
            end

            if onUse then
              onUse(player, user_id)
            end

            vRP.closeMenu(player)
          end
        else
          vRPclient.notify(player, {"Trebuie sa astepti "..inEating[user_id] - os.time().." secunde inainte sa poti efectua aceasta actiune!", "error"})
        end
      end
    end}

    return choices
  end

  return fgen
end

-- ==================== --
--        BAUTURI       --
-- ==================== --

items["fp_apa"] = {
  name = "Apa Plata",
  description = "",
  choices = gen("drink",0,40),
  weight = 0.5
}

items["fp_cola"] = {
  name = "Coca-Cola",
  description = "",
  choices = gen("drink",0,30),
  weight = 0.3,
}

items["fp_redbull"] = {
  name = "RedBull",
  description = "",
  choices = gen("drink",0,20,function(player, user_id)
    TriggerClientEvent("vRP:useRedbullOrCoffee", player)
  end),
  weight = 0.3,
}

items["fp_lipton"] = {
  name = "Lipton",
  description = "",
  choices = gen("drink",0,35),
  weight = 0.3
}

items["fp_vodka"] = {
  name = "Sticla Vodka",
  description = "",
  choices = gen("drink",0,40),
  weight = 0.7
}

items["fp_bere"] = {
  name = "Bere",
  description = "",
  choices = gen("drink",0,25),
  weight = 0.3,
}

items["fp_fanta"] = {
  name = "Fanta",
  description = "",
  choices = gen("drink",0,30),
  weight = 0.3,
}

items["fp_cafea"] = {
  name = "Cafea",
  description = "",
  choices = gen("drink",0,20,function(player, user_id)
    TriggerClientEvent("vRP:useRedbullOrCoffee", player)
  end),
  weight = 0.2,
}

items["fp_lapte"] = {
  name = "Lapte",
  description = "",
  choices = gen("drink",0,40),
  weight = 1,
}

items["fp_milkshake"] = {
  name = "Milkshake",
  description = "",
  choices = gen("drink",0,35),
  weight = 0.5,
}

items["fp_bloody_mary"] = {
  name = "Bloody Mary",
  description = "",
  choices = gen("drink",0,40),
  weight = 0.5,
}

items["fp_sticla_sampanie"] = {
  name = "Sticla Sampanie",
  description = "",
  choices = gen("drink",0,100),
}

items["fp_pahar_sampanie"] = {
  name = "Pahar Sampanie",
  description = "",
  choices = gen("drink",0,20),
}

items["fp_sticla_whiskey"] = {
  name = "Sticla Whiskey",
  description = "",
  choices = gen("drink",0,100),
}

items["fp_pahar_whiskey"] = {
  name = "Pahar Whiskey",
  description = "",
  choices = gen("drink",0,20),
}

items["fp_sticla_tequila"] = {
  name = "Sticla Tequila",
  description = "",
  choices = gen("drink",0,100),
}

items["fp_shot_tequila"] = {
  name = "Shot Tequila",
  description = "",
  choices = gen("drink",0,20),
}

items["fp_sticla_vin"] = {
  name = "Sticla Vin",
  description = "",
  choices = gen("drink",0,100),
}

items["fp_pahar_vin"] = {
  name = "Pahar Vin",
  description = "",
  choices = gen("drink",0,20),
}

items["fp_pina-colada"] = {
  name = "Pina-Colada",
  description = "",
  choices = gen("drink",0,40),
}

items["fp_martini"] = {
  name = "Martini",
  description = "",
  choices = gen("drink",0,30),
}
-- ==================== --
--        MANCARE       --
-- ==================== --

items["fp_shaorma"] = {
  name = "Shaorma",
  description = "",
  choices = gen("eat",60,-20),
  weight = 0.7,
}

items["fp_pepene_rosu"] = {
  name = "Pepene Rosu",
  description = "",
  choices = gen("eat",30,25),
  weight = 0.3,
}

items["fp_pleskavita"] = {
  name = "Pleskavita Banateana",
  description = "",
  choices = gen("eat", 40, -15),
  weight = 0.5,
}

items["fp_gogoasa_ciocolata"] = {
  name = "Gogoasa cu Ciocolata",
  description = "",
  choices = gen("eat",50,-30),
  weight = 0.2,
}

items["fp_gogoasa_capsuni"] = {
  name = "Gogoasa cu Capsuni",
  description = "",
  choices = gen("eat",50,-30),
  weight = 0.2,
}

items["fp_chipsuri_lays"] = {
  name = "Chipsuri Lays",
  description = "",
  choices = gen("eat", 20, -5),
  weight = 0.5,
}

items["fp_tacos"] = {
  name = "Taco",
  description = "",
  choices = gen("eat",20,-5),
  weight = 0.2,
}

items["fp_burger"] = {
  name = "Burger",
  description = "",
  choices = gen("eat", 30,-15),
  weight = 0.5,
}

items["fp_burrito"] = {
  name = "Burrito",
  description = "",
  choices = gen("eat", 25,-10),
  weight = 0.5,
}

items["fp_sandvis"] = {
  name = "Sandwich",
  description = "",
  choices = gen("eat", 25,-10),
  weight = 0.3,
}

items["fp_cookie"] = {
  name = "Cookie cu Ciocolata",
  description = "",
  choices = gen("eat", 35,-20),
  weight = 0.2,
}

items["fp_hotdog"] = {
  name = "Hotdog",
  description = "",
  choices = gen("eat", 25,-15),
  weight = 0.5,
}

items["fp_briosa"] = {
  name = "Briosa",
  description = "",
  choices = gen("eat", 35,-20),
  weight = 0.2,
}

items["fp_pizza"] = {
  name = "Pizza",
  description = "",
  choices = gen("eat", 30,-10),
  weight = 0.3,
}

return items
